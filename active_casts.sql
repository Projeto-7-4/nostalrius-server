-- Create active_casts table for Cast System
-- This table tracks which players are currently broadcasting

CREATE TABLE IF NOT EXISTS `active_casts` (
    `player_id` int(11) NOT NULL,
    `viewer_count` int(11) NOT NULL DEFAULT 0,
    `last_update` bigint(20) NOT NULL,
    PRIMARY KEY (`player_id`),
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Clean up any old records (in case of server crash)
DELETE FROM `active_casts`;

