-- Seed data for Database Assistant MCP demos.
-- Run: sqlite3 database.db < seed.sql

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    age INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    category TEXT,
    stock INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    total REAL NOT NULL,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_product ON orders(product_id);

INSERT INTO users (name, email, age) VALUES
    ('Alice', 'alice@example.com', 30),
    ('Bob', 'bob@example.com', 25),
    ('Charlie', 'charlie@example.com', 35),
    ('Diana', 'diana@example.com', 28),
    ('Eve', NULL, 22);

INSERT INTO products (name, price, category, stock) VALUES
    ('Widget', 9.99, 'Gadgets', 100),
    ('Gizmo', 24.99, 'Gadgets', 50),
    ('Doohickey', 4.99, 'Tools', 200),
    ('Thingamajig', 14.99, 'Tools', 75),
    ('Whatchamacallit', 49.99, 'Premium', 10);

INSERT INTO orders (user_id, product_id, quantity, total) VALUES
    (1, 1, 2, 19.98),
    (1, 3, 1, 4.99),
    (2, 2, 1, 24.99),
    (3, 5, 1, 49.99),
    (4, 1, 3, 29.97),
    (4, 4, 2, 29.98),
    (5, 3, 5, 24.95);
