-- Seed: sample vendors (vendor users must exist first = seed_users.sql)
-- Passwords are hashed with bcrypt; plain text: "password123"

USE quick_queue_pro;

INSERT INTO users (name, email, password_hash, role, phone) VALUES
  ('City Barber Shop',  'barber@example.com',   '$2a$12$XhL0qH5YFDlkqHt4gN1sY.cL5lFDBWVLj9eEQP7/CmIBN6A3yOOKm', 'vendor', '9876543210'),
  ('Quick Med Clinic',  'clinic@example.com',   '$2a$12$XhL0qH5YFDlkqHt4gN1sY.cL5lFDBWVLj9eEQP7/CmIBN6A3yOOKm', 'vendor', '9876543211'),
  ('Sunrise Pharmacy',  'pharmacy@example.com', '$2a$12$XhL0qH5YFDlkqHt4gN1sY.cL5lFDBWVLj9eEQP7/CmIBN6A3yOOKm', 'vendor', '9876543212');

-- vendor profiles (assumes user ids 1,2,3 for the rows above)
INSERT INTO vendors (user_id, name, category, address, phone, is_open, avg_service_minutes) VALUES
  (1, 'City Barber Shop', 'Salon',    '12 Main Street, Downtown',      '9876543210', 1, 15),
  (2, 'Quick Med Clinic', 'Medical',  '45 Health Ave, Northside',      '9876543211', 1, 10),
  (3, 'Sunrise Pharmacy', 'Pharmacy', '7 Sunrise Road, West District', '9876543212', 1,  5);
