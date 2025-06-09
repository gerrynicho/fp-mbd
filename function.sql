DELIMITER $$
-- 
CREATE FUNCTION hitung_pelanggan_hari_ini(DATE current_date) 
RETURNS INTEGER  
DETERMINISTIC
BEGIN 
    DECLARE jumlah_pelanggan_hari_ini INT;

    SELECT COUNT(
        DISTINCT pelanggan_id_pelanggan 
    )
    INTO jumlah_pelanggan_hari_ini
    FROM TRANSAKSI t
    WHERE t.tanggal = current_date;

    RETURN jumlah_pelanggan_hari_ini;
END
$$
DELIMITER ;