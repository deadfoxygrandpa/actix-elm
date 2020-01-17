use actix_web::{get, web, App, HttpServer, Responder};
use serde::{Serialize};

#[derive(Serialize)]
struct Lol {
    msg: String,
}


async fn index() -> impl Responder {
    web::Json(Lol { msg: "lol im using rust. and stingent sucks".to_string() })
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| { 
        App::new()
            .route("/", web::get().to(index))
    })
    .bind("0.0.0.0:5000")?
    .run()
    .await
}
