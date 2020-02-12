CREATE OR REPLACE FUNCTION get_temp_articles (
	usr TEXT
)
RETURNS TABLE (
	id UUID,
	headlineCN TEXT,
	dateCreated TIMESTAMP
)
AS
$$

	SELECT temp_articles.id, headlineCN, dateCreated 
	FROM temp_articles 
	JOIN users
	ON users.username = usr
	WHERE author=users.id;

$$ LANGUAGE SQL;