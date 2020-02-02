CREATE TABLE IF NOT EXISTS invitations (
	id INTEGER REFERENCES users(id),
	invitation TEXT UNIQUE NOT NULL,
	PRIMARY KEY (id, invitation)
);