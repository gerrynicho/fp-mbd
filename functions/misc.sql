-- #1 CEK MEMBERSHIP PELANGGAN [DONE]
DELIMITER $$
CREATE FUNCTION cek_membership(p_id CHAR(5))
RETURNS BOOLEAN
BEGIN
    DECLARE status BOOL;
    SELECT EXISTS (
        SELECT 1 
        FROM MEMBERSHIP 
        WHERE pelanggan_id_pelanggan = p_id
    ) INTO status;

    RETURN status;
END$$
DELIMITER ;
-- SELECT cek_membership('P0001') AS status_membership;
-- SELECT cek_membership('P0025') AS status_membership;

--  #2 CEK MASA BERLAKU MEMBERSHIP [DONE]
DELIMITER $$
CREATE FUNCTION promosi_masih_berlaku(p_id CHAR(10))
RETURNS BOOLEAN
BEGIN
    DECLARE status BOOL DEFAULT FALSE;

    SELECT 
        (CURDATE() BETWEEN tanggal_mulai AND tanggal_berakhir)
    INTO 
        status
    FROM 
        PROMOSI
    WHERE 
        id_promosi = p_id;

    RETURN IFNULL(status, FALSE);
END$$
DELIMITER ;
-- SELECT promosi_masih_berlaku('PR001') AS masih_berlaku;
-- SELECT promosi_masih_berlaku('PR014') AS masih_berlaku;

-- #3 Hitung Total Penggunaan Promosi [DONE]
DELIMITER $$
CREATE FUNCTION total_penggunaan_promosi(p_id CHAR(10))
RETURNS INT
BEGIN
    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) 
    INTO total
    FROM PROMOSI_TRANSAKSI
    WHERE promosi_id_promosi = p_id;

    RETURN total;
END$$
DELIMITER ;
-- INSERT INTO PROMOSI_TRANSAKSI VALUES
-- ('TRX202506100002','PR014'),
-- ('TRX202506110001','PR014'),
-- ('TRX202506120001','PR014'),
-- ('TRX202506130001','PR011');
-- SELECT total_penggunaan_promosi('PR014') AS jumlah_penggunaan;
-- SELECT total_penggunaan_promosi('PR011') AS jumlah_penggunaan;

-- #12 HITUNG PELANGGAN HARI INI [DONE]
DELIMITER $$
CREATE FUNCTION hitung_pelanggan_hari_ini(p_date DATE) 
RETURNS INTEGER  
DETERMINISTIC
BEGIN 
    DECLARE jumlah_pelanggan_hari_ini INT;

    SELECT COUNT(DISTINCT pelanggan_id_pelanggan)
    INTO jumlah_pelanggan_hari_ini
    FROM TRANSAKSI t
    WHERE DATE(t.tanggal_transaksi) = p_date;

    RETURN jumlah_pelanggan_hari_ini;
END $$
DELIMITER ;
-- SELECT hitung_pelanggan_hari_ini(CURDATE()) AS jumlah_pelanggan_hari_ini