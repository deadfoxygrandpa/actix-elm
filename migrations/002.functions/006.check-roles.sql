CREATE OR REPLACE FUNCTION check_roles (
	usr TEXT
)
RETURNS INTEGER[]
AS
$$
	SELECT array_agg(role) FROM user_roles JOIN users ON username=usr WHERE users.id = user_roles.id;
$$ LANGUAGE SQL;