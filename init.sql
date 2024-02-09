--

CREATE TABLE customers(
  id SMALLSERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  max_limit INTEGER NOT NULL
);

CREATE TABLE transactions(
  id SERIAL PRIMARY KEY,
  value INTEGER NOT NULL,
  type VARCHAR(1) CHECK (type IN ('c', 'd')) NOT NULL,
  description VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT now() NOT NULL
);

DO $$
BEGIN
  INSERT INTO customers (name, max_limit)
  VALUES
    ('rubick', 1000 * 100),
    ('zeus', 800 * 100),
    ('killua', 10000 * 100),
    ('freeza', 100000 * 100),
    ('gohan', 5000 * 100);
END; $$
