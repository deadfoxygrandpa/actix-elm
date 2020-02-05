INSERT INTO roles(id, description) VALUES (1, 'admin') ON CONFLICT DO NOTHING;
INSERT INTO roles(id, description) VALUES (2, 'author') ON CONFLICT DO NOTHING;
INSERT INTO roles(id, description) VALUES (3, 'reviewer') ON CONFLICT DO NOTHING;
INSERT INTO roles(id, description) VALUES (4, 'publisher') ON CONFLICT DO NOTHING;