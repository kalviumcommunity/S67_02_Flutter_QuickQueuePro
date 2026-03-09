-- Migration 002 – Create vendors table
-- Depends on: 001_create_users_table.sql

USE quick_queue_pro;

CREATE TABLE IF NOT EXISTS vendors (
  id                   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  user_id              INT UNSIGNED  NOT NULL,
  name                 VARCHAR(150)  NOT NULL,
  category             VARCHAR(100)  NULL,
  address              TEXT          NULL,
  phone                VARCHAR(20)   NULL,
  is_open              TINYINT(1)    NOT NULL DEFAULT 1,
  avg_service_minutes  INT UNSIGNED  NOT NULL DEFAULT 5,
  created_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE  KEY uq_vendor_user  (user_id),
  INDEX   idx_vendor_is_open  (is_open),
  CONSTRAINT fk_vendor_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
