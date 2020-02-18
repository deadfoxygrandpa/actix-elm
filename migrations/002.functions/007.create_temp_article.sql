CREATE OR REPLACE FUNCTION create_temp_article (
	usr TEXT
)
RETURNS UUID
AS
$$
DECLARE
	usr_id INTEGER;
	new_id UUID;
BEGIN
	
	SELECT users.id FROM users WHERE username=usr INTO usr_id;

	INSERT INTO temp_articles(dateCreated, author)
	VALUES (now()::TIMESTAMP, usr_id)
	RETURNING id INTO new_id;

	-- log the result
	INSERT INTO logs(subject, userId, dateCreated, entry)
		VALUES ('create_article', usr_id, now()::TIMESTAMP, 'Created new temp article: ' || cast(new_id as TEXT));

	RETURN new_id;

END;
$$ LANGUAGE PLPGSQL;