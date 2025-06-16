DELIMITER $$
-- Trigger untuk menambahkan promosi hanya jika pelanggan masuk 10 orang pertama
CREATE TRIGGER trg_diskon_10_orang
BEFORE INSERT ON PROMOSI_TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE count INTEGER DEFAULT 0;

    SET count = hitung_pelanggan_hari_ini(CURDATE());
    IF count <= 10 THEN
        SET NEW.promosi_id_promosi = 'PR010';
    ENDIF;
END $$

DELIMITER ;

-- Trigger untuk warning low stok
DELIMITER $$

CREATE TRIGGER low_stok
BEFORE UPDATE ON MAKANAN
FOR EACH ROW 
BEGIN 
    -- Error: stok tidak boleh negatif
    IF NEW.stok < 0 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id_makanan, 'ERROR', 'Stok tidak mencukupi', NOW());

        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Stok tidak mencukupi';

    -- Warning: stok kosong (update tetap dilakukan)
    ELSEIF NEW.stok = 0 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id, 'NOTICE', 'Stok kosong', NOW());
        -- No SIGNAL so update continues

    -- Notice: stok rendah (<= 5), update tetap dilakukan
    ELSEIF NEW.stok <= 5 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id, 'NOTICE', 'Stok rendah, tolong stok ulang', NOW());
        -- No SIGNAL so update continues
    END IF;
END$$

DELIMITER ;

-- Trigger untuk menambahkan diskon jika ada membership
DELIMITER $$

CREATE OR REPLACE TRIGGER diskon_membership
BEFORE INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN
    DECLARE is_member INT DEFAULT 0;
    DECLARE diskon_persen DECIMAL(5,2) DEFAULT 0.10; -- 10% discount
    DECLARE biaya_awal DECIMAL(10,2);

    SELECT COUNT(*) INTO is_member
    FROM MEMBERSHIP
    WHERE pelanggan_id_pelanggan = NEW.pelanggan_id_pelanggan;

    IF is_member > 0 THEN
        SET biaya_awal = NEW.total_biaya;
        SET NEW.total_biaya = biaya_awal - (biaya_awal * diskon_persen);
    END IF;
END $$

DELIMITER ;
