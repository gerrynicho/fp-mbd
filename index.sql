-- #1
ALTER TABLE FILM
    ADD INDEX idx_id_film(id_film),
    ADD INDEX idx_genre(genre),
    ADD INDEX idx_rating_usia(rating_usia),
    ADD INDEX idx_rating_imdb(rating_imdb);

ALTER TABLE JADWAL_TAYANG
    ADD INDEX idx_jadwal(id_jadwal),
    ADD INDEX idx_id_film_jadwal(id_film),

ALTER TABLE KURSI
    ADD INDEX idx_kursi(row, number);

ALTER TABLE LOKASI_STUDIO
    ADD INDEX idx_alamat(alamat),
    ADD INDEX idx_nama_stdio(nama_studio);

ALTER TABLE PELANGGAN
    ADD INDEX idx_id_pelanggan(id_pelanggan),
    ADD INDEX idx_email(email);