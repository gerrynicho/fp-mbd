-- Fixed get_next_dt_id() function
DELIMITER $$
CREATE FUNCTION get_next_dt_id()
RETURNS CHAR(5)
BEGIN
    DECLARE max_num INT DEFAULT 0;
    DECLARE next_id CHAR(5);
    
    -- Get the highest existing DT number
    SELECT COALESCE(MAX(CAST(SUBSTRING(id_detail_transaksi, 3) AS UNSIGNED)), 0) 
    INTO max_num
    FROM DETAIL_TRANSAKSI 
    WHERE id_detail_transaksi LIKE 'DT%';
    
    -- Increment by 1 (fixed from +2) and format with leading zeros (3 digits)
    SET next_id = CONCAT('DT', LPAD(max_num + 1, 3, '0'));
    
    RETURN next_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_next_trx_id()
RETURNS CHAR(19)
READS SQL DATA
BEGIN
    DECLARE max_num INT DEFAULT 0;
    DECLARE next_id CHAR(19);
    DECLARE today_prefix CHAR(11);
    
    -- Create today's prefix: TRX + YYYYMMDD format
    SET today_prefix = CONCAT('TRX', DATE_FORMAT(CURDATE(), '%Y%m%d'));
    
    -- Get the highest existing transaction number for today
    -- Corrected SUBSTRING position from 16 to 12
    SELECT COALESCE(MAX(CAST(SUBSTRING(id_transaksi, 12) AS UNSIGNED)), 0) 
    INTO max_num
    FROM TRANSAKSI 
    WHERE id_transaksi LIKE CONCAT(today_prefix, '%');
    
    -- Increment by 1 and format with leading zeros (4 digits)
    SET next_id = CONCAT(today_prefix, LPAD(max_num + 1, 4, '0'));
    
    RETURN next_id;
END$$
DELIMITER ;


DELIMITER $$
CREATE FUNCTION get_current_trx_id() 
RETURNS CHAR(19)
BEGIN
    DECLARE current_id CHAR(19);
    SELECT id_transaksi
    INTO current_id
    FROM TRANSAKSI
    ORDER BY id_transaksi DESC
    LIMIT 1;
    RETURN current_id;
END$$
DELIMITER ;