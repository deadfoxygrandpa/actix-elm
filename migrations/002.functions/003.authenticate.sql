CREATE OR REPLACE FUNCTION authenticate (
	usr TEXT,
	pass TEXT
)
RETURNS TABLE (
	success BOOLEAN,
	message TEXT
)
AS
$$
DECLARE
	success BOOLEAN;
	message TEXT;
	hashed_pw TEXT;
	validated_pw TEXT;
	active BOOLEAN;
BEGIN
	-- default to not approved
	SELECT FALSE, '' INTO success, message;
	
	-- if user doesn't exist
	IF (SELECT NOT EXISTS(SELECT 1 FROM users WHERE username=usr)) THEN
		SELECT FALSE, 'Username does not exist' INTO success, message;
	ELSE
		SELECT users.password, users.active FROM users WHERE username=usr INTO hashed_pw, active;
	
		-- if user is not activated
		IF (NOT active) THEN
			SELECT FALSE, 'User is not activated' INTO success, message;
		-- hash password
		ELSE
			SELECT crypt(pass, hashed_pw) INTO validated_pw;
		
			-- if password is wrong
			IF (validated_pw <> hashed_pw) THEN
				SELECT FALSE, 'Wrong password' INTO success, message;
			-- everything is correct
			ELSE 
				SELECT TRUE, 'Success' INTO success, message;
			END IF;
		END IF;
	END IF;
	RETURN QUERY SELECT success, message;
END;
$$ LANGUAGE PLPGSQL;