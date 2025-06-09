DELIMITER $$
-- Trigger untuk menambahkan promosi hanya jika pelanggan masuk 10 orang pertama
CREATE TRIGGER trg_diskon_10_orang
BEFORE INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE count INTEGER DEFAULT 0;

    SET count = hitung_pelanggan_hari_ini(CURDATE());

    IF count >= 10 THEN
        SET NEW.total_biaya = NEW.total_biaya * 0.90;
    ENDIF;
END $$

DELIMITER ;




