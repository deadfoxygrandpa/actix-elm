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

pub async fn authenticate(db: web::Data<DB>, info: Login) -> Result<String, actix_web::error::BlockingError<DBError>> {
	web::block(move || {
		let x: Result<String, DBError> = db.get()
			.map_err(|e| DBError::PoolError(e))
			.and_then(|c| get_row(c, "SELECT success, message FROM authenticate($1, $2);", &[&info.username, &info.password]))
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

pub async fn register(db: web::Data<DB>, info: Register) -> Result<String, actix_web::error::BlockingError<DBError>> {
	web::block(move || {
		let x: Result<String, DBError> = db.get()
			.map_err(|e| DBError::PoolError(e))
			.and_then(|c| get_row(c, "SELECT success, message FROM register($1, $2, $3);", &[&info.username, &info.password, &info.confirm]))
			.and_then(|row| 
				match row.get(2) {
					true => Ok(row.get(3)),
					false => Err(DBError::AuthenticationError(row.get(1)))
				})
			.and_then(|x: String| Ok(x.clone()));
		x
	})
	.await
	.map(|x| x)
}

// HELPERS

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

	match db.batch_execute(statements.as_str()) {
		Ok(_) => "database is set up".to_string(),
		Err(e) => e.to_string()
	}
}
