--

CREATE TABLE customers(
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  max_limit INTEGER NOT NULL
);

CREATE TABLE transactions(
  id SERIAL PRIMARY KEY,
  value INTEGER NOT NULL,
  customer_id INTEGER REFERENCES customers(id),
  type VARCHAR(1) CHECK (type IN ('c', 'd')) NOT NULL,
  description VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT now() NOT NULL
);

CREATE TABLE balances(
  id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id),
  value INTEGER NOT NULL
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

  INSERT INTO balances(customer_id, value)
    SELECT id, 0 FROM customers;
END; $$
