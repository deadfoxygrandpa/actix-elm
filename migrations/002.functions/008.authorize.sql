CREATE OR REPLACE FUNCTION authorize (
	usr TEXT,
	rle INTEGER
)
RETURNS BOOLEAN
AS
$$

	SELECT coalesce(sum(role), 0) > 0 FROM user_roles 
	JOIN users ON username=usr
	WHERE users.id=user_roles.id 
	AND role=rle;

$$ LANGUAGE SQL;