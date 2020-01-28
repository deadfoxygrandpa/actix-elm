use actix_web::{web, App, HttpServer, Responder, Result};
use actix_files as fs;
use actix_identity::{Identity, CookieIdentityPolicy, IdentityService};
use serde::{Serialize};
use std::thread;

#[macro_use]
extern crate lazy_static;

#[allow(dead_code)]
mod database;
mod email;

// API

#[derive(Serialize)]
struct Lol {
    msg: String,
}

async fn hello(db: web::Data<database::DB>, id: Identity) -> impl Responder {
    match database::select_hello(db).await {
        Ok(x) => web::Json(Lol { msg: format!("{}: {}", x, id.identity().unwrap_or_else(|| "idk".to_string())) }),
        Err(e) => web::Json(Lol { msg: e.to_string() })
    }
}

async fn login(info: web::Json<database::Login>, id: Identity, db: web::Data<database::DB>) -> impl Responder {
    
    let login_info = info.into_inner();

    match database::authenticate(db, login_info.clone()).await {
        Ok(s) => { id.remember(login_info.username); web::Json(Lol { msg: s }) },
        Err(e) => web::Json(Lol { msg: e.to_string() })
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
                Ok(_) => web::Json(Lol { msg: "Verification email sent!".to_string() }),
                Err(e) => web::Json(Lol { msg: e })
            }},
        Err(e) => web::Json(Lol { msg: e.to_string() })
    }
}

async fn confirm(info: web::Path<String>, db: web::Data<database::DB>) -> impl Responder {
    match database::confirm(db, info.into_inner()).await {
        Ok(s) => web::Json(Lol { msg: s }),
        Err(e) => web::Json(Lol { msg: e.to_string() })
    }
}

// STATIC FILES

async fn index() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/index.html")?)
}

async fn favicon() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/favicon.ico")?)
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
            .wrap(IdentityService::new(
                CookieIdentityPolicy::new(SECRET_KEY.as_bytes())
                    .name("auth-cookie")
                    .max_age(60)
                    .secure(false)))
            .data(db.clone())
            .service(web::scope("/api")
                .route("/hello", web::get().to(hello))
                .route("/login", web::post().to(login))
                .route("/register", web::post().to(register)) 
                .route("/confirm/{token}", web::get().to(confirm))
            )
            .service(web::scope("")
                .route("/", web::get().to(index))
                .route("/favicon.ico", web::get().to(favicon))
            )
    })
    .bind("0.0.0.0:5000")?
    .run()
    .await
}
