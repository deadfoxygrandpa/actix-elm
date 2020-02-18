CREATE OR REPLACE FUNCTION register (
	new_username TEXT,
	pass TEXT,
	confirm TEXT
)
RETURNS TABLE (
	new_id INTEGER,
	message TEXT,
	success BOOLEAN,
	invitation TEXT
)
AS
$$
DECLARE
	new_id INTEGER;
	message TEXT;
	success BOOLEAN;
	invitation_token TEXT;
	hashed_pw TEXT;
BEGIN
	-- defaults to not approved
	SELECT 0, '', FALSE, '' INTO new_id, message, success, invitation; 

	IF (pass <> confirm) THEN
		SELECT 'Password and confirmed password do not match' INTO message;

	ELSIF (SELECT EXISTS(SELECT 1 FROM users WHERE username=new_username)) THEN
		SELECT 'Username already exists' INTO message;

	ELSE
		-- hash the password 
		SELECT crypt(pass, gen_salt('bf', 10)) into hashed_pw;
		-- generate random token for invitation
		SELECT substring(md5(random()::TEXT), 0, 36) INTO invitation_token;

		-- insert into users table
		INSERT INTO users(username, password, created, active)
			VALUES (new_username, hashed_pw, now()::TIMESTAMP, FALSE) RETURNING id INTO new_id;

		SELECT 'Success', TRUE INTO message, success;

		-- insert invitation token into table
		INSERT INTO invitations(id, invitation)
			VALUES (new_id, invitation_token);

		-- log the result
		INSERT INTO logs(subject, userId, dateCreated, entry)
			VALUES ('registration', new_id, now()::TIMESTAMP, 'Added new user');
	END IF;

	-- return the results table
	RETURN QUERY SELECT new_id, message, success, invitation_token;

END;
$$ LANGUAGE PLPGSQL;