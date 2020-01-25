use std::fmt;
use std::error;
use postgres::{NoTls};
use tokio_postgres;
use r2d2_postgres::PostgresConnectionManager;
use actix_web::{web};

pub type DB = r2d2::Pool<PostgresConnectionManager<NoTls>>;
pub type DBPool = r2d2::PooledConnection<PostgresConnectionManager<NoTls>>;

#[derive(Debug)]
pub enum DBError {
	PoolError(r2d2::Error),
	PostgresError(postgres::error::Error),
	TokioPostgresError(tokio_postgres::error::Error),
	OtherError(String),
}

impl fmt::Display for DBError {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		match *self {
			DBError::PoolError(ref e) => ::std::fmt::Display::fmt(e, f),
			DBError::PostgresError(ref e) => ::std::fmt::Display::fmt(e, f),
			DBError::TokioPostgresError(ref e) => ::std::fmt::Display::fmt(e, f),
			DBError::OtherError(ref e) => ::std::fmt::Display::fmt(e, f),
		}
	}
}

impl error::Error for DBError {
	fn source(&self) -> Option<&(dyn error::Error + 'static)> {
        None
    }
}

// pub fn get_pool() -> Result<DBPool> {
	
// }

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

fn get_row(mut c: DBPool, query: &str, params: &[&(dyn postgres::types::ToSql + Sync)]) -> Result<postgres::row::Row, DBError> {
	c.query_one(query, params).map_err(|e| DBError::TokioPostgresError(e))
}

fn get_from_row(row: tokio_postgres::row::Row) -> Result<String, DBError> {
	row.try_get(0).map_err(|e| DBError::TokioPostgresError(e))
}