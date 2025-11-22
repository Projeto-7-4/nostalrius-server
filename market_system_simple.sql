-- Market System - Schema Simplificado
-- Nostalrius 7.72

-- Dropar tabelas antigas
DROP TABLE IF EXISTS market_active_offers;
DROP TABLE IF EXISTS market_depot;
DROP TABLE IF EXISTS market_price_stats;
DROP VIEW IF EXISTS market_offers_view;
DROP TABLE IF EXISTS market_history;
DROP TABLE IF EXISTS market_offers;

-- Tabela de ofertas
CREATE TABLE `market_offers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT NOT NULL,
  `item_id` INT UNSIGNED NOT NULL,
  `amount` INT UNSIGNED NOT NULL,
  `price` INT UNSIGNED NOT NULL,
  `type` TINYINT(1) NOT NULL COMMENT '0 = buy, 1 = sell',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `expires_at` TIMESTAMP NOT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `item_id` (`item_id`),
  KEY `is_active` (`is_active`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Tabela de histórico
CREATE TABLE `market_history` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `offer_id` INT UNSIGNED NOT NULL,
  `buyer_id` INT NOT NULL,
  `seller_id` INT NOT NULL,
  `item_id` INT UNSIGNED NOT NULL,
  `amount` INT UNSIGNED NOT NULL,
  `price` INT UNSIGNED NOT NULL,
  `transaction_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `seller_id` (`seller_id`),
  KEY `offer_id` (`offer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- View para ofertas ativas
CREATE VIEW `market_offers_view` AS
SELECT 
  mo.id,
  mo.player_id,
  p.name as player_name,
  mo.item_id,
  mo.amount,
  mo.price,
  mo.type,
  mo.created_at,
  mo.expires_at,
  TIMESTAMPDIFF(SECOND, NOW(), mo.expires_at) as seconds_remaining
FROM market_offers mo
INNER JOIN players p ON p.id = mo.player_id
WHERE mo.is_active = 1 
  AND mo.expires_at > NOW()
ORDER BY mo.created_at DESC;

-- Dados de teste
INSERT INTO market_offers (player_id, item_id, amount, price, type, expires_at) VALUES
(1, 3446, 100, 2, 1, DATE_ADD(NOW(), INTERVAL 7 DAY)),
(1, 3264, 1, 600, 1, DATE_ADD(NOW(), INTERVAL 5 DAY)),
(1, 3357, 1, 4000, 1, DATE_ADD(NOW(), INTERVAL 6 DAY));

SELECT 'Market System instalado com sucesso!' as status;
SELECT COUNT(*) as ofertas_teste FROM market_offers;



