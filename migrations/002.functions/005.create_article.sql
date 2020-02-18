CREATE OR REPLACE FUNCTION create_article (
	usr INTEGER,
	headline TEXT,
	body TEXT,
	title TEXT,
	wordcount SMALLINT
)
RETURNS INTEGER
AS
$$
DECLARE
	new_id INTEGER;
BEGIN

	INSERT INTO articles(headlineCN, dateCreated, disabled, articleBody, wordCount, abstract, author)
	VALUES (title, now()::TIMESTAMP, FALSE, body, wordcount, title, usr)
	RETURNING id INTO new_id;

	-- log the result
	INSERT INTO logs(subject, userId, dateCreated, entry)
		VALUES ('create_article', usr, now()::TIMESTAMP, 'Created new article: ' || cast(new_id as TEXT));

	RETURN new_id;

END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION create_article (
	usr TEXT,
	headline TEXT,
	body TEXT,
	title TEXT,
	wordcount SMALLINT
)
RETURNS INTEGER
AS
$$
DECLARE
	usr_id INTEGER;
	new_id INTEGER;
BEGIN

	SELECT users.id FROM users WHERE users.username=usr INTO usr_id;
	
	INSERT INTO articles(headlineCN, dateCreated, disabled, articleBody, wordCount, abstract, author)
	VALUES (title, now()::TIMESTAMP, FALSE, body, wordcount, title, usr_id)
	RETURNING id INTO new_id;

	-- log the result
	INSERT INTO logs(subject, userId, dateCreated, entry)
		VALUES ('create_article', usr_id, now()::TIMESTAMP, 'Created new article: ' || cast(new_id as TEXT));

	RETURN new_id;

END;
$$ LANGUAGE PLPGSQL;