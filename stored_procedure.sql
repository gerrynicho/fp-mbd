-- #6 Kembalikan Stok Makanan [HARUSNYA FUNCTION TAPI KU COBA JADI PROCEDURE]

DELIMITER //
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
END;
//
DELIMITER ;

-- CALL kembalikan_stok_makanan('TRX202506100001');
-- CALL kembalikan_stok_makanan('TRX202506100002');


-- #1 Top 3 makanan terlaris per kategori
DELIMITER $$
CREATE PROCEDURE top_makanan_terlaris_per_kategori()
BEGIN
    SELECT m.kategori, m.nama_makanan, SUM(tm.jumlah) AS total_terjual
    FROM MAKANAN m
    JOIN TRANSAKSI_MAKANAN tm ON m.id_makanan = tm.makanan_id_makanan
    GROUP BY m.kategori, m.nama_makanan
    ORDER BY total_terjual DESC
    LIMIT 3;
END $$
DELIMITER ;

-- #2 Film yang paling banyak ditonton
DELIMITER $$
CREATE PROCEDURE film_paling_banyak_ditonton()
BEGIN
    SELECT f.id_film, f.judul, COUNT(jt.id_jadwal) AS jumlah_penonton
    FROM FILM f
    JOIN JADWAL_TAYANG jt ON f.id_film = jt.film_id_film
    JOIN KURSI k ON jt.studio_id_studio = k.studio_id_studio
    WHERE k.sedia = FALSE -- Kursi yang sudah dipesan
    GROUP BY f.id_film, f.judul
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
CREATE PROCEDURE lokasi_studio_film_tayang()
BEGIN
    SELECT ls.id_lokasi_studio, ls.merk_studio, f.id_film, f.judul_film, f.genre, f.rating_usia
    FROM LOKASI_STUDIO ls
    JOIN TEATER t ON ls.id_lokasi_studio = t.lokasi_studio_id_lokasi_studio
    JOIN JADWAL_TAYANG jt ON t.id_teater = jt.teater_id_teater
    JOIN FILM f ON jt.film_id_film = f.id_film;
END $$
DELIMITER ;

-- #7 teater dari lokasi studio yang menayang film
DELIMITER $$
CREATE PROCEDURE teater_lokasi_studio_film()
BEGIN
    SELECT ls.id_lokasi_studio, ls.nama_studio, s.id_studio, s.nama_teater, f.id_film, f.judul
    FROM LOKASI_STUDIO ls
    JOIN STUDIO s ON ls.id_lokasi_studio = s.lokasi_studio_id_lokasi_studio
    JOIN JADWAL_TAYANG jt ON s.id_studio = jt.studio_id_studio
    JOIN FILM f ON jt.film_id_film = f.id_film;
END $$

-- #8 jadwal tayang di studio tertentu
DELIMITER $$
CREATE PROCEDURE jadwal_tayang_studio_tertentu(p_studio_id CHAR(5))
BEGIN
    SELECT jt.id_jadwal, f.judul, jt.tanggal_tayang, jt.waktu_tayang
    FROM JADWAL_TAYANG jt
    JOIN FILM f ON jt.film_id_film = f.id_film
    WHERE jt.studio_id_studio = p_studio_id;
END $$
DELIMITER ;

-- #9 film tersedia berdasarkan tanggal dan lokasi studio
DELIMITER $$
CREATE PROCEDURE film_tersedia_tanggal_lokasi(p_tanggal DATE, p_lokasi_studio_id CHAR(5))
BEGIN
    SELECT f.id_film, f.judul, jt.tanggal_tayang, jt.waktu_tayang
    FROM FILM f
    JOIN JADWAL_TAYANG jt ON f.id_film = jt.film_id_film
    JOIN STUDIO s ON jt.studio_id_studio = s.id_studio
    WHERE jt.tanggal_tayang = p_tanggal AND s.lokasi_studio_id_lokasi_studio = p_lokasi_studio_id;
END $$
DELIMITER ;

-- #10 pembatalan transaksi

-- #11 edit transaksi (pindah kursi atau jadwal)