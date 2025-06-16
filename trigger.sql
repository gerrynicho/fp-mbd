DELIMITER $$
-- #1
-- Trigger untuk menambahkan promosi hanya jika pelanggan masuk 10 orang pertama
-- menurutku ini harus refactor buat bikin count jadi sistem variabel
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


-- #2
-- trigger stok menipis [DONE]
DELIMITER $$

CREATE TRIGGER trg_low_stok
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

-- #3
-- triger diskon tambahan ketika user ada membership [DONE]
DELIMITER $$
CREATE TRIGGER trg_diskon_membership
BEFORE INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE diskon INT DEFAULT 0;
    IF cek_membership(NEW.pelanggan_id_pelanggan) THEN
        SET diskon = 10; -- Diskon 10% untuk anggota
        SET NEW.total_biaya = NEW.total_biaya * (1 - diskon / 100);
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
    END IF;
END $$