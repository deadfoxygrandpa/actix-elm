use actix_web::{web, App, HttpServer, HttpResponse, Responder, Result};
use actix_web::middleware::Logger;
use actix_files as fs;
use actix_identity::{Identity, CookieIdentityPolicy, IdentityService};
use serde::{Serialize};
use serde_json;
use std::thread;
use env_logger;

#[macro_use]
extern crate lazy_static;

#[allow(dead_code)]
mod database;
mod email;
mod html;
mod identity;

// API

#[derive(Serialize)]
struct Msg {
    msg: String,
}

async fn hello(db: web::Data<database::DB>, id: Identity) -> impl Responder {
    match database::select_hello(db).await {
        Ok(x) => web::Json(Msg { msg: format!("{}: {}", x, id.identity().unwrap_or_else(|| "idk".to_string())) }),
        Err(e) => web::Json(Msg { msg: e.to_string() })
    }
}

async fn login(info: web::Json<database::Login>, id: Identity, db: web::Data<database::DB>) -> impl Responder {
    
    let login_info = info.into_inner();

    match database::authenticate(db, login_info.clone()).await {
        Ok((credentials, msg)) => { 
            // explicitly unwrap to null string if json fails, because this will show up in Elm as not logged in
            id.remember(serde_json::to_string(&credentials).unwrap_or_else(|_| "null".to_string())); 
            web::Json(Msg { msg: msg }) 
        },
        Err(e) => web::Json(Msg { msg: e.to_string() })
    }
}

async fn register(info: web::Json<database::Register>, db: web::Data<database::DB>) -> impl Responder {
    
    let register_info = info.into_inner();

    match database::register(db, register_info.clone()).await {
        Ok(s) => {
            let mailer = email::create_mail_client(MAILGUN_KEY.to_string(), EMAIL_DOMAIN.to_string());
            let mail = email::create_email(
                        format!("{}/api/confirm", SITE_DOMAIN.to_string()), 
                        EMAIL_DOMAIN.to_string(),
                        register_info.username,
                        s);
            match email::send_verification_email(mailer, mail).await {
                Ok(_) => web::Json(Msg { msg: "Verification email sent!".to_string() }),
                Err(e) => web::Json(Msg { msg: e })
            }},
        Err(e) => web::Json(Msg { msg: e.to_string() })
    }
}

async fn confirm(info: web::Path<String>, db: web::Data<database::DB>) -> impl Responder {
    match database::confirm(db, info.into_inner()).await {
        Ok(s) => web::Json(Msg { msg: s }),
        Err(e) => web::Json(Msg { msg: e.to_string() })
    }
}

async fn logout(id: Identity) -> impl Responder {
    id.forget();
    HttpResponse::Ok().finish()
}

async fn articles(db: web::Data<database::DB>) -> impl Responder {
    match database::get_articles(db).await {
        Ok(article_list) => web::Json(article_list),
        Err(_) => web::Json(vec![])
    }
}

async fn article(db: web::Data<database::DB>, id: web::Path<i32>) -> impl Responder {
    match database::get_article(db, id.into_inner()).await {
        Ok(article) => web::Json(Some(article)),
        Err(_) => web::Json(None)
    }
}

// async fn write_article(db: web::Data<database::DB>, id: Identity) -> impl Responder {
//     if identity::can_write_article(id) {
//         let uuid = Uuid::new_v4().to_simple().to_string();
//         Some(uuid)
//     } else {
//         None
//     }
// }

async fn articles_in_progress(db: web::Data<database::DB>, id: Identity) -> impl Responder {
    if identity::can_write_article(id) {
        unimplemented!()
    } else {
        HttpResponse::Unauthorized().finish()
    }
}

async fn index(id: Identity) -> impl Responder {
    let name = id.identity();
    HttpResponse::Ok().body(html::elm_page(&name))
}

// STATIC FILES

async fn favicon() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/favicon.ico")?)
}

async fn elm() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/elm.js")?)
}

async fn style() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/style.css")?)
}

async fn font(info: web::Path<String>) -> Result<fs::NamedFile> {
    let name = info.into_inner();
    Ok(fs::NamedFile::open(format!("static/fonts/{}", name))?)
}

async fn image(info: web::Path<String>) -> Result<fs::NamedFile> {
    let name = info.into_inner();
    match fs::NamedFile::open(format!("static/images/{}", name)) {
        Ok(img) => Ok(img),
        Err(_) => Ok(fs::NamedFile::open("static/images/placeholder.jpg")?) 
    }
}


// PROGRAM LOGIC


// REQUIRED ENV VARIABLES
lazy_static! {
    static ref SECRET_KEY: String = std::env::var("SECRET_KEY").unwrap_or_else(|_| "7890".repeat(8));
    static ref MAILGUN_KEY: String = std::env::var("MAILGUN_KEY").unwrap_or_else(|_| "0000".repeat(8));
    static ref EMAIL_DOMAIN: String = std::env::var("EMAIL_DOMAIN").unwrap_or_else(|_| "example.com".to_string());
    static ref SITE_DOMAIN: String = std::env::var("SITE_DOMAIN").unwrap_or_else(|_| "example.com".to_string());
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {

    //  set up logging... already have timestamps so don't need them twice
    std::env::set_var("RUST_LOG", "info");
    env_logger::builder()
        .format_timestamp(None)
        .init();

    let postgres_url = std::env::var("DATABASE_URL")
            .unwrap_or_else(|_| "host=192.168.99.100 user=postgres password=docker"
            .parse().unwrap());
    let db = database::get_pool(&postgres_url).unwrap();

    // Make sure the DB is set up
    let db2 = database::get_pool(&postgres_url).unwrap();
    thread::spawn(move || { 
        let x: String = database::set_up(db2.get().unwrap()); 
        println!("{}", x);
    });

    // Run the server
    HttpServer::new(move || { 
        App::new()
            .wrap(Logger::new("FROM: %a\tTO: %r\tSTATUS: %s\tTIME: %D\tBYTES: %b\tREFERER: %{Referer}i\tUSER AGENT: %{User-Agent}i"))
            .wrap(IdentityService::new(
                CookieIdentityPolicy::new(SECRET_KEY.as_bytes())
                    .name("auth-cookie")
                    .max_age(60*60*24*7)
                    .secure(false)))
            .data(db.clone())
            .service(web::scope("/api")
                .route("/hello", web::get().to(hello))
                .route("/login", web::post().to(login))
                .route("/register", web::post().to(register)) 
                .route("/confirm/{token}", web::get().to(confirm))
                .route("/logout", web::post().to(logout))
                .route("/articles", web::get().to(articles))
                .route("/article/{id}", web::get().to(article))
            )
            .service(web::scope("/fonts")
                .route("/{name}", web::get().to(font))
            )
            .service(web::scope("")
                .route("/", web::get().to(index))
                .route("/favicon.ico", web::get().to(favicon))
                .route("/elm.js", web::get().to(elm))
                .route("/style.css", web::get().to(style))
                .route("/image/{filename}", web::get().to(image))
            )
            .default_service(
                web::route().to(index))
    })
    .bind("0.0.0.0:5000")?
    .run()
    .await
}
