CREATE TABLE IF NOT EXISTS user_roles (
	id INTEGER REFERENCES users(id),
	role INTEGER REFERENCES roles(id),
	PRIMARY KEY(id, role)
);