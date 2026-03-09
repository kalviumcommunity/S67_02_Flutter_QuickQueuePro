-- Migration 004 – Create notifications table
-- Depends on: 001_create_users_table.sql, 003_create_queues_table.sql

USE quick_queue_pro;

CREATE TABLE IF NOT EXISTS notifications (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED  NOT NULL,
  queue_id    INT UNSIGNED  NULL,
  message     TEXT          NOT NULL,
  is_read     TINYINT(1)    NOT NULL DEFAULT 0,
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_notif_user  (user_id),
  INDEX idx_notif_queue (queue_id),
  CONSTRAINT fk_notif_user  FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_notif_queue FOREIGN KEY (queue_id)
    REFERENCES queues (id) ON DELETE SET NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
