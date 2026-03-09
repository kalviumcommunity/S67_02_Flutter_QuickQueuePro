-- Seed: sample customer users
-- Passwords are hashed with bcrypt; plain text: "password123"

USE quick_queue_pro;

INSERT INTO users (name, email, password_hash, role, phone) VALUES
  ('Alice Johnson', 'alice@example.com', '$2a$12$XhL0qH5YFDlkqHt4gN1sY.cL5lFDBWVLj9eEQP7/CmIBN6A3yOOKm', 'customer', '9000000001'),
  ('Bob Smith',     'bob@example.com',   '$2a$12$XhL0qH5YFDlkqHt4gN1sY.cL5lFDBWVLj9eEQP7/CmIBN6A3yOOKm', 'customer', '9000000002'),
  ('Carol White',   'carol@example.com', '$2a$12$XhL0qH5YFDlkqHt4gN1sY.cL5lFDBWVLj9eEQP7/CmIBN6A3yOOKm', 'customer', '9000000003');
