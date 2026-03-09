-- ============================================================
-- QuickQueuePro – Complete Database Schema
-- Database: MySQL 8+
-- Run this file to create all tables from scratch.
-- ============================================================

CREATE DATABASE IF NOT EXISTS quick_queue_pro
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE quick_queue_pro;

-- ── users ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100)    NOT NULL,
  email         VARCHAR(255)    NOT NULL UNIQUE,
  password_hash VARCHAR(255)    NOT NULL,
  role          ENUM('customer','vendor') NOT NULL DEFAULT 'customer',
  phone         VARCHAR(20)     NULL,
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_users_email (email),
  INDEX idx_users_role  (role)
) ENGINE=InnoDB;

-- ── vendors ──────────────────────────────────────────────────
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
  UNIQUE  KEY uq_vendor_user   (user_id),
  INDEX   idx_vendor_is_open   (is_open),
  CONSTRAINT fk_vendor_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── queues ───────────────────────────────────────────────────
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
  INDEX idx_queue_vendor     (vendor_id),
  INDEX idx_queue_customer   (customer_id),
  INDEX idx_queue_status     (status),
  INDEX idx_queue_created    (created_at),
  CONSTRAINT fk_queue_vendor   FOREIGN KEY (vendor_id)
    REFERENCES vendors (id) ON DELETE CASCADE,
  CONSTRAINT fk_queue_customer FOREIGN KEY (customer_id)
    REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── notifications (optional) ─────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED  NOT NULL,
  queue_id    INT UNSIGNED  NULL,
  message     TEXT          NOT NULL,
  is_read     TINYINT(1)    NOT NULL DEFAULT 0,
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_notif_user (user_id),
  CONSTRAINT fk_notif_user  FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_notif_queue FOREIGN KEY (queue_id)
    REFERENCES queues (id) ON DELETE SET NULL
) ENGINE=InnoDB;
