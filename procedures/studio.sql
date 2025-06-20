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

-- #6 lokasi studio sedang tayang film apa saja
DELIMITER $$

CREATE PROCEDURE get_film_by_merk_studio(IN merk_input VARCHAR(30))
BEGIN
    SELECT DISTINCT 
        F.id_film,
        F.file_gambar,
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
        f.file_gambar,
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