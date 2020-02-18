DROP FUNCTION IF EXISTS authenticate;
CREATE OR REPLACE FUNCTION authenticate (
	usr TEXT,
	pass TEXT
)
RETURNS TABLE (
	success BOOLEAN,
	message TEXT,
	roles INTEGER[]
)
AS
$$
DECLARE
	success BOOLEAN;
	message TEXT;
	roles INTEGER[];
	hashed_pw TEXT;
	validated_pw TEXT;
	active BOOLEAN;
	user_id INTEGER;
BEGIN
	-- default to not approved
	SELECT FALSE, '', ARRAY[]::INTEGER[] INTO success, message, roles;
	
	-- if user doesn't exist
	IF (SELECT NOT EXISTS(SELECT 1 FROM users WHERE username=usr)) THEN
		SELECT FALSE, 'Username does not exist' INTO success, message;

		-- log the result
		INSERT INTO logs(subject, userId, dateCreated, entry)
			VALUES ('login', null, now()::TIMESTAMP, usr || ' does not exist');
	ELSE
		SELECT users.password, users.active, users.id FROM users WHERE username=usr INTO hashed_pw, active, user_id;
	
		-- if user is not activated
		IF (NOT active) THEN
			SELECT FALSE, 'User is not activated' INTO success, message;

			-- log the result
			INSERT INTO logs(subject, userId, dateCreated, entry)
				VALUES ('login', user_id, now()::TIMESTAMP, 'Tried to login before email confirmation');
		-- hash password
		ELSE
			SELECT crypt(pass, hashed_pw) INTO validated_pw;
		
			-- if password is wrong
			IF (validated_pw <> hashed_pw) THEN
				SELECT FALSE, 'Wrong password' INTO success, message;

				-- log the result
				INSERT INTO logs(subject, userId, dateCreated, entry)
					VALUES ('login', user_id, now()::TIMESTAMP, 'Wrong password');
			-- everything is correct
			ELSE 
				SELECT TRUE, 'Success' INTO success, message;
				SELECT check_roles(usr) INTO roles;

				-- log the result
				INSERT INTO logs(subject, userId, dateCreated, entry)
					VALUES ('login', user_id, now()::TIMESTAMP, 'Logged in');
			END IF;
		END IF;
	END IF;
	RETURN QUERY SELECT success, message, roles;
END;
$$ LANGUAGE PLPGSQL;