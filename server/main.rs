use actix_web::{web, App, HttpServer, Responder, Result};
use actix_files as fs;
use serde::{Serialize};

#[derive(Serialize)]
struct Lol {
    msg: String,
}


async fn hello() -> impl Responder {
    web::Json(Lol { msg: "lol im using rust and elm. and now i can deploy from github".to_string() })
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
