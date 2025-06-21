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
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id_makanan, 'ERROR', 'Stok tidak mencukupi', NOW());

        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Stok tidak mencukupi';

    -- Warning: stok kosong (update tetap dilakukan)
    ELSEIF NEW.stok = 0 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id_makanan, 'NOTICE', 'Stok kosong', NOW());
        -- No SIGNAL so update continues

    -- Notice: stok rendah (<= 5), update tetap dilakukan
    ELSEIF NEW.stok <= 5 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id_makanan, 'NOTICE', 'Stok rendah, tolong stok ulang', NOW());
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

-- [DRAFT input handling]
-- # 7 
-- Jika jumlah kursi tersedia 0 cegah pembeli
-- # 8 
-- Jika promosi yang dimasukkan pengguna ketemu tapi masa sudah tidak aktif
-- # 9
-- Jika diskon dibuat angka minus
-- # 10 
-- Jika tanggal mulai input diskon lebih besar daripada tanggal berakhir 
-- # 11 
-- Jika harga kursi 0 atau minus 
-- # 12
-- Jika transaksi total biaya minus maka set default 0
