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
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER low_stok
BEFORE UPDATE ON MAKANAN
FOR EACH ROW 
BEGIN 
    -- Error: stok tidak boleh negatif
    IF NEW.stok < 0 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id, 'ERROR', 'Stok tidak mencukupi', NOW());

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



