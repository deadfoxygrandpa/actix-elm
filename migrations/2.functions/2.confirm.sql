CREATE OR REPLACE FUNCTION confirm (
	invitation_token TEXT
)
RETURNS TABLE (
	success BOOLEAN,
	message TEXT
)
AS
$$
DECLARE
	user_id INTEGER;
	success BOOLEAN;
	message TEXT;
BEGIN
	-- default to not approved
	SELECT FALSE, '' INTO success, message;
	
	-- if invitation doesn't exist
	IF (SELECT NOT EXISTS(SELECT 1 FROM invitations WHERE invitation=invitation_token)) THEN
		SELECT FALSE, 'Invitation does not exist' INTO success, message;
	ELSE 
		SELECT invitations.id INTO user_id FROM invitations WHERE invitation = invitation_token;

		-- activate the user 
		UPDATE users SET active = TRUE WHERE id = user_id;

		-- remove invitation now that it's confirmed
		DELETE FROM invitations WHERE invitation = invitation_token;

		SELECT TRUE, 'User is activated' INTO success, message;

	END IF;
	
	RETURN QUERY SELECT success, message;
END;
$$ LANGUAGE PLPGSQL;