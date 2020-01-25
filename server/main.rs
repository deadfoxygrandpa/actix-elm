use actix_web::{web, App, HttpServer, Responder, Result};
use actix_files as fs;
use serde::{Serialize};
use std::env;

#[allow(dead_code)]
mod database;

#[derive(Serialize)]
struct Lol {
    msg: String,
}


async fn hello() -> impl Responder {
    match std::env::var("DATABASE_URL") {
        Ok(x) => web::Json(Lol { msg: x }),
        Err(_) => web::Json(Lol { msg: "error".to_string() })
    }
}

async fn index() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/index.html")?)
}

async fn favicon() -> Result<fs::NamedFile> {
    Ok(fs::NamedFile::open("static/favicon.ico")?)
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| { 
        App::new()
            .service(web::scope("/api")
                .route("/hello", web::get().to(hello)))
            .service(web::scope("")
                .route("/", web::get().to(index))
                .route("/favicon.ico", web::get().to(favicon)))
    })
    .bind("0.0.0.0:5000")?
    .run()
    .await
}
