-- HITUNG PELANGGAN HARI INI
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

-- CEK MEMBERSHIP PELANGGAN [DONE]
DELIMITER //
CREATE FUNCTION cek_membership(p_id CHAR(5))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE status BOOL;
    SELECT EXISTS (
        SELECT 1 FROM MEMBERSHIP WHERE pelanggan_id_pelanggan = p_id
    ) INTO status;
    RETURN status;
END;
//
DELIMITER ;
-- SELECT cek_membership('P0001');
-- SELECT cek_membership('P0021');

--  Validasi Masa Berlaku Promosi

