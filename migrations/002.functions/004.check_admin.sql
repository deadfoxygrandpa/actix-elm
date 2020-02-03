CREATE OR REPLACE FUNCTION check_admin (
	usr TEXT
)
RETURNS BOOLEAN
AS
$$
DECLARE
	is_admin BOOLEAN;
BEGIN
	-- the double lines are to convert any nulls to false if admin isnt set or user doesnt exist 
	SELECT (admin IS TRUE) FROM users WHERE username=usr INTO is_admin;
	RETURN is_admin IS TRUE;
END;
$$ LANGUAGE PLPGSQL;