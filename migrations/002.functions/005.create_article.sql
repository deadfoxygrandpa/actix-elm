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

	RETURN new_id;

END;
$$ LANGUAGE PLPGSQL;