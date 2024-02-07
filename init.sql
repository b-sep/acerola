--

CREATE TABLE clientes(
  id SMALLSERIAL PRIMARY KEY,
  nome varchar NOT NULL,
  limite INTEGER NOT NULL
);

DO $$
BEGIN
  INSERT INTO clientes (nome, limite)
  VALUES
    ('rubick', 1000 * 100),
    ('zeus', 800 * 100),
    ('killua', 10000 * 100),
    ('freeza', 100000 * 100),
    ('gohan', 5000 * 100);
END; $$
