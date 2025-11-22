-- =============================================
-- RARITY MARKET SYSTEM - Database Schema
-- Servidor: Nostalrius 7.72
-- =============================================

-- Tabela de ofertas ativas
CREATE TABLE IF NOT EXISTS `market_offers` (
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

-- Tabela de histórico de transações
CREATE TABLE IF NOT EXISTS `market_history` (
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

-- View para ofertas com nome do player
CREATE OR REPLACE VIEW `market_offers_view` AS
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

-- Procedure para limpar ofertas expiradas (executar via cron)
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS `clean_expired_offers`()
BEGIN
  -- Marca ofertas expiradas como inativas
  UPDATE market_offers 
  SET is_active = 0 
  WHERE expires_at <= NOW() AND is_active = 1;
  
  -- Remove ofertas muito antigas (30 dias)
  DELETE FROM market_offers 
  WHERE is_active = 0 
    AND expires_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
END//
DELIMITER ;

-- Indices adicionais para performance (comentado - criar manualmente se necessário)
-- CREATE INDEX idx_market_type_active ON market_offers(type, is_active, expires_at);
-- CREATE INDEX idx_market_item_active ON market_offers(item_id, is_active, type);

-- Configurações iniciais
-- Adicionar coluna de market_balance (comentado - adicionar manualmente se necessário)
-- ALTER TABLE players ADD COLUMN `market_balance` BIGINT UNSIGNED DEFAULT 0 COMMENT 'Balance dedicado para o Market System';

-- =============================================
-- DADOS DE TESTE (OPCIONAL - Remover em produção)
-- =============================================

-- Inserir algumas ofertas de teste
-- Descomente as linhas abaixo para teste:

/*
INSERT INTO market_offers (player_id, item_id, amount, price, type, expires_at) VALUES
(1, 3446, 1000, 2, 1, DATE_ADD(NOW(), INTERVAL 7 DAY)),  -- 1000x Bolt por 2gp cada (SELL)
(1, 3264, 1, 600, 1, DATE_ADD(NOW(), INTERVAL 5 DAY)),   -- Sword por 600gp (SELL)
(1, 3357, 1, 4000, 1, DATE_ADD(NOW(), INTERVAL 6 DAY)),  -- Plate Armor por 4000gp (SELL)
(2, 3446, 500, 3, 0, DATE_ADD(NOW(), INTERVAL 4 DAY)),   -- Comprar 500x Bolt por 3gp cada (BUY)
(2, 3274, 1, 550, 0, DATE_ADD(NOW(), INTERVAL 3 DAY));   -- Comprar Axe por 550gp (BUY)
*/

-- =============================================
-- QUERIES ÚTEIS PARA ADMINISTRAÇÃO
-- =============================================

-- Ver todas as ofertas ativas:
-- SELECT * FROM market_offers_view;

-- Ver histórico de transações de um player:
-- SELECT * FROM market_history WHERE buyer_id = 1 OR seller_id = 1 ORDER BY transaction_date DESC LIMIT 20;

-- Total de ofertas por tipo:
-- SELECT type, COUNT(*) as total FROM market_offers WHERE is_active = 1 GROUP BY type;

-- Ofertas prestes a expirar (menos de 1 hora):
-- SELECT * FROM market_offers_view WHERE seconds_remaining < 3600;

-- =============================================
-- FIM DO SCRIPT
-- =============================================
