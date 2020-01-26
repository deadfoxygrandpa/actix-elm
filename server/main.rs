use actix_web::{web, App, HttpServer, HttpResponse, Responder, Result};
use actix_files as fs;
use actix_identity::{Identity, CookieIdentityPolicy, IdentityService};
use serde::{Serialize, Deserialize};
use std::env;

#[macro_use]
extern crate lazy_static;

#[allow(dead_code)]
mod database;


// API

#[derive(Serialize)]
struct Lol {
    msg: String,
}

#[derive(Serialize, Deserialize, PartialEq)]
struct Login {
    username: String,
    password: String,
}

async fn hello(db: web::Data<database::DB>, id: Identity) -> impl Responder {
    match database::select_hello(db).await {
        Ok(x) => web::Json(Lol { msg: format!("{}: {}", x, id.identity().unwrap_or_else(|| "idk".to_string())) }),
        Err(e) => web::Json(Lol { msg: e.to_string() })
    }
}

async fn login(info: web::Json<Login>, id: Identity, db: web::Data<database::DB>) -> impl Responder {
    id.remember(info.into_inner().username);
    hello(db, id).await
}

// STATIC FILES

async fn index() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/index.html")?)
}

async fn favicon() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/favicon.ico")?)
}

// PROGRAM LOGIC

lazy_static! {
    static ref SECRET_KEY: String = std::env::var("SECRET_KEY").unwrap_or_else(|_| "7890".repeat(8));
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {

    let postgres_url = std::env::var("DATABASE_URL").unwrap();
    let db = database::get_pool(&postgres_url).unwrap();

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
                .route("/login", web::post().to(login)))
            .service(web::scope("")
                .route("/", web::get().to(index))
                .route("/favicon.ico", web::get().to(favicon)))
    })
    .bind("0.0.0.0:5000")?
    .run()
    .await
}
