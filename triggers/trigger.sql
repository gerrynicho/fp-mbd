DELIMITER $$
-- #1
-- Trigger untuk menambahkan promosi hanya jika pelanggan masuk 10 orang pertama
-- menurutku ini harus refactor buat bikin count jadi sistem variabel
CREATE TRIGGER trg_diskon_10_orang
BEFORE INSERT ON PROMOSI_TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE count INTEGER DEFAULT 0;
    DECLARE promo_aktif INT;

    -- trg diskon 10 orang
    SET count = hitung_pelanggan_hari_ini(CURDATE());
    IF count <= 10 THEN
        SET NEW.promosi_id_promosi = 'PR010';
    END IF;

    -- trg diskon cek promo aktif
    SELECT COUNT(*) INTO promo_aktif
    FROM PROMOSI p
    WHERE id_promosi = NEW.promosi_id_promosi
        AND CURDATE() BETWEEN p.tanggal_mulai AND p.tanggal_berakhir;
    
    IF promo_aktif = 0 THEN
        INSERT INTO LOG_NOTIFIKASI(tipe_notif, pesan, waktu)
        VALUES ('ERROR', CONCAT('Promosi ', NEW.promosi_id_promosi, ' tidak aktif'), NOW());
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Promosi sudah tidak aktif.';
    END IF;
END $$

DELIMITER ;


-- #2
-- trigger stok menipis [DONE]
DELIMITER $$

CREATE TRIGGER trg_low_stok
BEFORE UPDATE ON MAKANAN
FOR EACH ROW 
BEGIN 
    -- Error: stok tidak boleh negatif
    IF NEW.stok < 0 THEN 
        INSERT INTO log_notifikasi (tipe_notif, pesan, waktu)
        VALUES ('ERROR',  CONCAT('Stok ', NEW.id_makanan, ' tidak mencukupi'), NOW());

        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Stok tidak mencukupi';

    -- Warning: stok kosong (update tetap dilakukan)
    ELSEIF NEW.stok = 0 THEN 
        INSERT INTO log_notifikasi (tipe_notif, pesan, waktu)
        VALUES ('NOTICE', CONCAT('Stok ', NEW.id_makanan, ' kosong'), NOW());
        -- No SIGNAL so update continues

    -- Notice: stok rendah (<= 5), update tetap dilakukan
    ELSEIF NEW.stok <= 5 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES ('NOTICE', CONCAT('Stok ', NEW.id_makanan, ' kritis! Tolong Restock.'), NOW());
        -- No SIGNAL so update continues
    END IF;
END$$

DELIMITER ;

-- #3
-- triger diskon tambahan ketika user ada membership [UPDATED]
DELIMITER $$
CREATE TRIGGER trg_diskon_membership
BEFORE INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE diskon DECIMAL(10,2) DEFAULT 0;
    DECLARE subtotal DECIMAL(10,2);
    
    -- If customer has membership, apply 10% discount
    IF cek_membership(NEW.pelanggan_id_pelanggan) THEN
        -- Get the original total_biaya
        SET subtotal = NEW.total_biaya;
        
        -- Calculate discount (10%)
        SET diskon = subtotal * 0.1;
        
        -- Apply the discount to total_biaya
        SET NEW.total_biaya = NEW.total_biaya - diskon;
    END IF;

    -- Jika ada total biaya negatif, otomatis set as 0
    IF NEW.total_biaya < 0 THEN
        SET total_biaya = 0;
        INSERT INTO LOG_NOTIFIKASI (tipe_notif, pesan, waktu)
        VALUES ('NOTICE', 'Total biaya transaksi negatif, diset menjadi 0.', NOW());
    END IF;


END $$
DELIMITER ;

-- #4
-- trigger tambah poin saat transaksi [DONE]
DELIMITER $$
CREATE TRIGGER trg_tambah_poin
AFTER INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE add_poin INT DEFAULT 0;

    SET add_poin = harga_ke_poin(NEW.total_biaya);

    -- Update poin di tabel membership
    UPDATE MEMBERSHIP
    SET poin = poin + add_poin
    WHERE pelanggan_id_pelanggan = NEW.pelanggan_id_pelanggan;
END $$
DELIMITER ;

-- #5
-- trigger untuk menandai kursi tidak tersedia saat dipesan
DELIMITER $$
CREATE TRIGGER trg_pesan_kursi
AFTER INSERT ON DETAIL_TRANSAKSI
FOR EACH ROW
BEGIN 
    -- Menandai kursi sebagai tidak tersedia ketika dipesan
    UPDATE KURSI
    SET sedia = FALSE
    WHERE id_kursi = NEW.kursi_id_kursi;

    -- Update jumlah kursi teater available kalo udah dibeli
    UPDATE TEATER 
    SET jumlah_kursi_tersedia = jumlah_kursi_tersedia - 1
    WHERE id_teater = (
        SELECT teater_id_teater
        FROM KURSI 
        WHERE id_kursi = NEW.kursi_id_kursi
    );
END $$
DELIMITER ;

-- #6
-- trigger untuk membebaskan kursi setelah film selesai
DELIMITER $$
CREATE TRIGGER trg_kosongkan_kursi_setelah_film
AFTER UPDATE ON JADWAL_TAYANG
FOR EACH ROW
BEGIN 
    -- Jika jadwal tayang sudah lewat, bebaskan kursi
    IF NEW.jadwal < NOW() THEN
        UPDATE KURSI k
        INNER JOIN DETAIL_TRANSAKSI dt ON k.id_kursi = dt.kursi_id_kursi
        INNER JOIN TRANSAKSI t ON dt.transaksi_id_transaksi = t.id_transaksi
        SET k.sedia = TRUE
        WHERE t.jadwal_tayang_id_tayang = NEW.id_tayang;

    -- Update jumlah kursi teater available kalo sudah dibebaskan
        UPDATE TEATER 
        SET jumlah_kursi_tersedia = (
            SELECT COUNT(*) 
            FROM KURSI k
            WHERE k.sedia = TRUE AND teater_id_teater = (
                SELECT teater_id_teater 
                FROM JADWAL_TAYANG 
                WHERE id_tayang = NEW.id_tayang
            )
        );
        WHERE id_teater = (
            SELECT teater_id_teater 
            FROM JADWAL_TAYANG 
            WHERE id_tayang = NEW.id_tayang
        );
    END IF;
END $$

-- # 8
-- Jika diskon dibuat angka minus
DELIMITER $$
CREATE TRIGGER trg_diskon_minus
BEFORE INSERT ON PROMOSI
BEGIN
    IF NEW.diskon < 0 THEN
        INSERT INTO LOG_NOTIFIKASI (tipe_notif, pesan, waktu)
        VALUES('ERROR', 'Diskon tidak boleh negatif', NOW());
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Diskon tidak boleh negatif.';
    END IF;
END $$
DELIMITER ;


-- # 9 
-- Jika tanggal mulai input diskon lebih besar daripada tanggal berakhir 
DELIMITER $$
CREATE TRIGGER trg_tanggal_promosi_invalid 
BEFORE INSERT ON PROMOSI 
FOR EACH ROW 
BEGIN
    IF NEW.tanggal_mulai > NEW.tanggal_berakhir THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tanggal promosi invalid. Tanggal akhir lebih dahulu daripada tanggal mulai';
    END IF;
END$$;
DELIMITER ;

-- # 10 
-- Jika harga kursi 0 atau minus 
DELIMITER $$ 
CREATE TRIGGER trg_harga_kursi_invalid 
BEFORE INSERT ON KURSI 
FOR EACH ROW 
BEGIN
    IF New.harga_kursi <= 0 THEN 
        SET NEW.harga_kursi = 25000; -- harga default kursi paling murah yang normal, tapi kalau menetapkan 10000 juga boleh
        INSERT INTO LOG_NOTIFIKASI (tipe_notif, pesan, waktu)
        VALUES ('NOTICE', CONCAT('Harga kursi ', NEW.id_kursi , ' invalid, diset default 25000 (harga normal).'), NOW())
    END IF;
END$$
DELIMITER ;
