use actix_identity::Identity;

use crate::database;

pub fn to_credentials(id: Identity) -> Option<database::Credentials> {
	id.identity()
		.and_then(|identity| {
			match serde_json::from_str(&identity) {
				Ok(credentials) => Some(credentials),
				Err(_) => None
			}
		})
}

pub fn get_username(id: Identity) -> Option<String> {
	to_credentials(id)
		.and_then(|credentials| Some(credentials.username))
}

pub fn get_roles(id: Identity) -> Option<Vec<i32>> {
	to_credentials(id)
		.and_then(|credentials| Some(credentials.roles))
}

pub fn can_write_article(id: Identity) -> bool {
	match get_roles(id) {
		// Author before Admin as Author is likely more common
		Some(roles) => {
			if roles.contains(&2) || roles.contains(&1)  {
				true
			} else {
				false
			}},
		None => false
	}
}