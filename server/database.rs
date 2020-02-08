use std::fmt;
use std::error;
use std::fs;
use postgres::{NoTls};
use tokio_postgres;
use r2d2_postgres::PostgresConnectionManager;
use actix_web::{web};
use serde::{Serialize, Deserialize};
use glob::glob;


pub type DB = r2d2::Pool<PostgresConnectionManager<NoTls>>;
pub type DBPool = r2d2::PooledConnection<PostgresConnectionManager<NoTls>>;

#[derive(Debug)]
pub enum DBError {
    PoolError(r2d2::Error),
    PostgresError(postgres::error::Error),
    TokioPostgresError(tokio_postgres::error::Error),
    AuthenticationError(String),
    OtherError(String),
}

#[derive(Serialize, Deserialize, PartialEq, Clone)]
pub struct Login {
    pub username: String,
    pub password: String,
}

#[derive(Serialize, Deserialize, PartialEq, Clone)]
pub struct Register {
    pub username: String,
    pub password: String,
    pub confirm: String,
}

#[derive(Serialize, Deserialize, PartialEq, Clone)]
pub struct Credentials {
    pub username: String,
    pub roles: Vec<i32>,
}

//  roles spec
#[derive(Copy, Clone)]
enum Role {
    Admin = 1,
    Author = 2,
    Reviewer = 3,
    Publisher = 4,
}


impl fmt::Display for DBError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            DBError::PoolError(ref e) => ::std::fmt::Display::fmt(e, f),
            DBError::PostgresError(ref e) => ::std::fmt::Display::fmt(e, f),
            DBError::TokioPostgresError(ref e) => ::std::fmt::Display::fmt(e, f),
            DBError::AuthenticationError(ref e) => ::std::fmt::Display::fmt(e, f),
            DBError::OtherError(ref e) => ::std::fmt::Display::fmt(e, f),
        }
    }
}

impl error::Error for DBError {
    fn source(&self) -> Option<&(dyn error::Error + 'static)> {
        None
    }
}

pub fn get_pool(connection_str: &str) -> Result<DB, DBError> {
    let manager = PostgresConnectionManager::new(connection_str.parse().unwrap(), NoTls);
    r2d2::Pool::new(manager).map_err(|e| DBError::PoolError(e))
}

pub async fn select_hello(db: web::Data<DB>) -> Result<String, actix_web::error::BlockingError<DBError>> {
    web::block(move || {
        let x: Result<String, DBError> = db.get()
            .map_err(|e| DBError::PoolError(e))
            .and_then(|c| get_row(c, "SELECT 'hello';", &[]))
            .and_then(|row| get_from_row(row))
            .and_then(|x: String| Ok(x.clone()));
        x
    })
    .await
    .map(|x| x)
}

// USER MANAGEMENT

pub async fn authenticate(db: web::Data<DB>, info: Login) -> Result<(Credentials, String), actix_web::error::BlockingError<DBError>> {
    web::block(move || {
        let x: Result<(Credentials, String), DBError> = db.get()
            .map_err(|e| DBError::PoolError(e))
            .and_then(|c| get_row(c, "SELECT success, message, roles FROM authenticate($1, $2);", &[&info.username, &info.password]))
            .and_then(|row| 
                match row.get(0) {
                    true => Ok((Credentials { username: info.username.clone(), roles: row.get(2)}, row.get(1))),
                    false => Err(DBError::AuthenticationError(row.get(1)))
                })
            .and_then(|x: (Credentials, String)| Ok(x.clone()));
        x
    })
    .await
    .map(|x| x)
}

// returns invitation code
pub async fn register(db: web::Data<DB>, info: Register) -> Result<String, actix_web::error::BlockingError<DBError>> {
    web::block(move || {
        let x: Result<String, DBError> = db.get()
            .map_err(|e| DBError::PoolError(e))
            .and_then(|c| get_row(c, "SELECT success, message, invitation FROM register($1, $2, $3);", &[&info.username, &info.password, &info.confirm]))
            .and_then(|row| 
                match row.get(0) {
                    true => Ok(row.get(2)),
                    false => Err(DBError::AuthenticationError(row.get(1)))
                })
            .and_then(|x: String| Ok(x.clone()));
        x
    })
    .await
    .map(|x| x)
}

pub async fn confirm(db: web::Data<DB>, info: String) -> Result<String, actix_web::error::BlockingError<DBError>> {
    web::block(move || {
        let x: Result<String, DBError> = db.get()
            .map_err(|e| DBError::PoolError(e))
            .and_then(|c| get_row(c, "SELECT success, message FROM confirm($1);", &[&info]))
            .and_then(|row| 
                match row.get(0) {
                    true => Ok(row.get(1)),
                    false => Err(DBError::AuthenticationError(row.get(1)))
                })
            .and_then(|x: String| Ok(x.clone()));
        x
    })
    .await
    .map(|x| x)
}


// ARTICLE MANAGEMENT

#[derive(Serialize, PartialEq, Clone)]
pub struct Article {
    pub id: i32,
    pub headline_cn: String,
    pub date_created: std::time::SystemTime,
    pub article_body: String,
    pub summary: String,
    pub author: String,
    pub image: Option<String>,
}

#[derive(Serialize, PartialEq, Clone)]
pub struct ArticleSummary {
    pub id: i32,
    pub headline_cn: String,
    pub date_created: std::time::SystemTime,
    pub summary: String,
    pub author: String,
    pub image: Option<String>,
}

pub fn summarize(article: Article) -> ArticleSummary {
    ArticleSummary {
        id: article.id,
        headline_cn: article.headline_cn,
        date_created: article.date_created,
        summary: article.summary,
        author: article.author,
        image: article.image,
    }
}

pub async fn get_articles(db: web::Data<DB>) -> Result<Vec<ArticleSummary>, actix_web::error::BlockingError<DBError>> {
    web::block(move || {
        let x: Result<Vec<ArticleSummary>, DBError> = db.get()
            .map_err(|e| DBError::PoolError(e))
            .and_then(|c| get(c, "SELECT articles.id, headlineCN, dateCreated, articleBody, abstract, users.username, image, users.display_name FROM articles JOIN users ON articles.author = users.id;", &[]))
            .and_then(|rows| 
                Ok(rows
                .iter()
                .map(|row| {
                    let display_name: Option<String> = row.get(7);
                    ArticleSummary 
                        { id: row.get(0)
                        , headline_cn: row.get(1)
                        , date_created: row.get(2)
                        , summary: row.get(4)
                        , author: display_name.unwrap_or_else(|| row.get(5))
                        , image: row.get(6)
                        }
                    })
                .collect())
            );
        x
    })
    .await
    .map(|x| x)
}

pub async fn get_article(db: web::Data<DB>, id: i32) -> Result<Article, actix_web::error::BlockingError<DBError>> {
    web::block(move || {
        let x: Result<Article, DBError> = db.get()
            .map_err(|e| DBError::PoolError(e))
            .and_then(|c| get_row(c, "SELECT articles.id, headlineCN, dateCreated, articleBody, abstract, users.username, image, users.display_name FROM articles JOIN users ON articles.author = users.id WHERE articles.id = $1;", &[&id]))
            .and_then(|row| {
                let display_name: Option<String> = row.get(7);
                Ok(Article
                    { id: row.get(0)
                    , headline_cn: row.get(1)
                    , date_created: row.get(2)
                    , article_body: row.get(3)
                    , summary: row.get(4)
                    , author: display_name.unwrap_or_else(|| row.get(5))
                    , image: row.get(6)
                    })
                }
                );
        x
    })
    .await
    .map(|x| x)
}

// HELPERS

fn get(mut c: DBPool, query: &str, params: &[&(dyn postgres::types::ToSql + Sync)]) -> Result<Vec<postgres::row::Row>, DBError> {
    c.query(query, params).map_err(|e| DBError::TokioPostgresError(e))
}

fn get_row(mut c: DBPool, query: &str, params: &[&(dyn postgres::types::ToSql + Sync)]) -> Result<postgres::row::Row, DBError> {
    c.query_one(query, params).map_err(|e| DBError::TokioPostgresError(e))
}

fn get_from_row(row: tokio_postgres::row::Row) -> Result<String, DBError> {
    row.try_get(0).map_err(|e| DBError::TokioPostgresError(e))
}


// SET UP THE DATABASE
pub fn set_up(mut db: DBPool) -> String {
    let statements: String = glob("migrations/**/*.sql")
        .unwrap()
        .map(|path| fs::read_to_string(path.unwrap()).unwrap())
        .collect::<Vec<String>>()
        .concat();

    for path in glob("migrations/**/*.sql").unwrap() {
        println!("found sql file: {:?}", path.unwrap());
    }

    println!("executing sql...");

    match db.batch_execute(statements.as_str()) {
        Ok(_) => "database is set up".to_string(),
        Err(e) => e.to_string()
    }
}
