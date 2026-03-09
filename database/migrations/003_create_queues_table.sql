-- Migration 003 – Create queues table
-- Depends on: 001_create_users_table.sql, 002_create_vendors_table.sql

USE quick_queue_pro;

CREATE TABLE IF NOT EXISTS queues (
  id                      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  vendor_id               INT UNSIGNED  NOT NULL,
  customer_id             INT UNSIGNED  NOT NULL,
  token_number            INT UNSIGNED  NOT NULL,
  status                  ENUM('waiting','serving','completed','cancelled')
                          NOT NULL DEFAULT 'waiting',
  estimated_wait_minutes  INT UNSIGNED  NOT NULL DEFAULT 0,
  created_at              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  served_at               TIMESTAMP     NULL,
  PRIMARY KEY (id),
  INDEX idx_queue_vendor   (vendor_id),
  INDEX idx_queue_customer (customer_id),
  INDEX idx_queue_status   (status),
  INDEX idx_queue_created  (created_at),
  CONSTRAINT fk_queue_vendor   FOREIGN KEY (vendor_id)
    REFERENCES vendors (id) ON DELETE CASCADE,
  CONSTRAINT fk_queue_customer FOREIGN KEY (customer_id)
    REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
