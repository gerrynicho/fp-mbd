-- #6 Kembalikan Stok Makanan [HARUSNYA FUNCTION TAPI KU COBA JADI PROCEDURE]

DELIMITER $$
CREATE PROCEDURE kembalikan_stok_makanan(p_transaksi CHAR(19))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE makanan_id CHAR(5);
    DECLARE jumlah INT;
    DECLARE cur CURSOR FOR
        SELECT makanan_id_makanan, jumlah
        FROM TRANSAKSI_MAKANAN
        WHERE transaksi_id_transaksi = p_transaksi;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO makanan_id, jumlah;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE MAKANAN
        SET stok = stok + jumlah
        WHERE id_makanan = makanan_id;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

-- CALL kembalikan_stok_makanan('TRX202506100001');
-- CALL kembalikan_stok_makanan('TRX202506100002');


-- #1 Top 3 makanan terlaris per kategori
DELIMITER $$
CREATE PROCEDURE top_makanan_terlaris_per_kategori()
BEGIN
    SELECT m.klasifikasi, m.nama, SUM(tm.jumlah) AS total_terjual
    FROM MAKANAN m
    JOIN TRANSAKSI_MAKANAN tm ON m.id_makanan = tm.makanan_id_makanan
    GROUP BY m.klasifikasi, m.nama
    ORDER BY total_terjual DESC
    LIMIT 3;
END $$
DELIMITER ;

-- #2 Film yang paling banyak ditonton
DELIMITER $$
CREATE PROCEDURE film_paling_banyak_ditonton()
BEGIN
    SELECT f.id_film, f.judul_film, COUNT(jt.id_tayang) AS jumlah_penonton
    FROM FILM f
    JOIN JADWAL_TAYANG jt ON f.id_film = jt.film_id_film
    JOIN KURSI k ON jt.teater_id_teater = k.teater_id_teater
    WHERE k.sedia = FALSE -- Kursi yang sudah dipesan
    GROUP BY f.id_film, f.judul_film
    ORDER BY jumlah_penonton DESC
END $$

-- #3 Pelanggan yang transaksi paling banyak
DELIMITER $$
CREATE PROCEDURE pelanggan_transaksi_terbanyak()
BEGIN
    SELECT p.id_pelanggan, p.nama, COUNT(t.id_transaksi) AS jumlah_transaksi
    FROM PELANGGAN p
    JOIN TRANSAKSI t ON p.id_pelanggan = t.pelanggan_id_pelanggan
    GROUP BY p.id_pelanggan
    ORDER BY jumlah_transaksi DESC
END $$
DELIMITER ;

-- #4 add transaksi
CREATE PROCEDURE create_transaksi(
    IN p_biaya DECIMAL(10, 2),
    IN p_pelanggan_id CHAR(5),
    IN p_jadwal_tayang_id CHAR(7),
    IN p_teater_id CHAR(5),
    IN promosi_id CHAR(10) DEFAULT NULL,
)
BEGIN
    DECLARE new_transaksi_id CHAR(19);
    DECLARE total DECIMAL(10, 2);

    SET new_transaksi_id = get_next_trx_id();
    SET total = calculate_transaction_total(
        p_biaya,
        2000.00,
        0, -- diskon, bisa diubah sesuai kebutuhan
        new_transaksi_id
    );

    INSERT INTO TRANSAKSI (
        id_transaksi,
        total_biaya,
        tanggal_transaksi,
        pelanggan_id_pelanggan,
        jadwal_tayang_id_tayang,
        teater_id_teater
    ) VALUES (
        new_transaksi_id,

END $$
DELIMITER ;

-- #5 lokasi studio menjual makanan apa saja
DELIMITER $$
CREATE PROCEDURE lokasi_studio_makanan()
BEGIN
    SELECT ls.id_lokasi_studio, ls.merk_studio, m.id_makanan, m.nama, m.harga
    FROM LOKASI_STUDIO ls
    JOIN MAKANAN_LOKASI_STUDIO mls ON ls.id_lokasi_studio = mls.lokasi_studio_id_lokasi_studio
    JOIN MAKANAN m ON mls.makanan_id_makanan = m.id_makanan;
END $$
DELIMITER ;

-- #6 lokasi studio sedang tayang film apa saja
DELIMITER $$

CREATE PROCEDURE get_film_by_merk_studio(IN merk_input VARCHAR(30))
BEGIN
    SELECT DISTINCT 
        F.id_film,
        F.judul_film,
        F.genre,
        F.durasi,
        F.sutradara,
        F.rating_usia,
        F.rating_film,
        F.sinopsis
    FROM LOKASI_STUDIO LS
    JOIN TEATER T ON LS.id_lokasi_studio = T.lokasi_studio_id_lokasi_studio
    JOIN JADWAL_TAYANG JT ON T.id_teater = JT.teater_id_teater
    JOIN FILM F ON JT.film_id_film = F.id_film
    WHERE LS.merk_studio = merk_input;
END$$

DELIMITER ;

-- #7 teater dari lokasi studio yang menayang film
DELIMITER $$

CREATE PROCEDURE teater_tempat_film_ditayangkan(
    IN id_film CHAR(5),
    IN id_lokasi_studio CHAR(5)
)
BEGIN
    SELECT DISTINCT 
        T.id_teater,
        T.jumlah_kursi_tersedia,
        L.alamat_studio,
        L.merk_studio
    FROM JADWAL_TAYANG JT
    JOIN TEATER T ON JT.teater_id_teater = T.id_teater
    JOIN LOKASI_STUDIO L ON T.lokasi_studio_id_lokasi_studio = L.id_lokasi_studio
    WHERE JT.film_id_film = id_film
      AND T.lokasi_studio_id_lokasi_studio = id_lokasi_studio;
END$$

DELIMITER ;

-- #8 jadwal tayang di lokasi tertentu
DELIMITER $$

CREATE PROCEDURE jadwal_tayang_film_lokasi(
    IN p_judul_film VARCHAR(50),
    IN p_id_lokasi CHAR(5)
)
BEGIN
    SELECT 
        jt.id_tayang,
        f.judul_film,
        jt.jadwal,
        ls.alamat_studio,
        t.id_teater
    FROM JADWAL_TAYANG jt
    JOIN FILM f ON jt.film_id_film = f.id_film
    JOIN TEATER t ON jt.teater_id_teater = t.id_teater
    JOIN LOKASI_STUDIO ls ON t.lokasi_studio_id_lokasi_studio = ls.id_lokasi_studio
    WHERE f.judul_film = p_judul_film
      AND ls.id_lokasi_studio = p_id_lokasi;
END$$

DELIMITER ;

-- #9 film tersedia berdasarkan tanggal dan lokasi studio
DELIMITER $$

CREATE PROCEDURE film_tersedia_tanggal_lokasi(
    IN p_tanggal DATE,
    IN p_id_lokasi CHAR(5)
)
BEGIN
    SELECT DISTINCT
        f.id_film,
        f.judul_film,
        f.genre,
        f.durasi,
        f.sutradara,
        f.rating_usia,
        f.rating_film
    FROM JADWAL_TAYANG jt
    JOIN FILM f ON jt.film_id_film = f.id_film
    JOIN TEATER t ON jt.teater_id_teater = t.id_teater
    JOIN LOKASI_STUDIO ls ON t.lokasi_studio_id_lokasi_studio = ls.id_lokasi_studio
    WHERE DATE(jt.jadwal) = p_tanggal
      AND ls.id_lokasi_studio = p_id_lokasi;
END$$

DELIMITER ;

-- #10 pembatalan transaksi
DELIMITER $$

CREATE PROCEDURE pembatalan_transaksi(IN p_id_transaksi CHAR(19))
BEGIN
    -- Set kursi back to available
    UPDATE KURSI
    SET sedia = TRUE
    WHERE id_kursi IN (
        SELECT kursi_id_kursi
        FROM DETAIL_TRANSAKSI
        WHERE transaksi_id_transaksi = p_id_transaksi
    );

    -- Restore makanan stock
    UPDATE MAKANAN m
    JOIN TRANSAKSI_MAKANAN tm ON tm.makanan_id_makanan = m.id_makanan
    SET m.stok = m.stok + tm.jumlah
    WHERE tm.transaksi_id_transaksi = p_id_transaksi;

    -- Delete associated data
    DELETE FROM PROMOSI_TRANSAKSI WHERE transaksi_id_transaksi = p_id_transaksi;
    DELETE FROM TRANSAKSI_MAKANAN WHERE transaksi_id_transaksi = p_id_transaksi;
    DELETE FROM DETAIL_TRANSAKSI WHERE transaksi_id_transaksi = p_id_transaksi;
    DELETE FROM TRANSAKSI WHERE id_transaksi = p_id_transaksi;
END $$

DELIMITER ;


-- #11 edit transaksi (pindah kursi atau jadwal)
