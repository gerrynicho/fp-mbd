-- #1
ALTER TABLE FILM
    ADD INDEX idx_id_film(id_film),
    ADD INDEX idx_genre(genre),
    ADD INDEX idx_rating_usia(rating_usia),
    ADD INDEX idx_rating_film(rating_film);

ALTER TABLE JADWAL_TAYANG
    ADD INDEX idx_id_tayang(id_tayang),
    ADD INDEX idx_id_film_jadwal(film_id_film),
    ADD INDEX idx_jadwal(jadwal);

ALTER TABLE KURSI
    ADD INDEX idx_kursi(row_kursi, column_kursi);

ALTER TABLE LOKASI_STUDIO
    ADD INDEX idx_alamat(alamat_studio),
    ADD INDEX idx_merk_studio(merk_studio);

ALTER TABLE PELANGGAN
    ADD INDEX idx_id_pelanggan(id_pelanggan),
    ADD INDEX idx_nama(nama);

ALTER TABLE TRANSAKSI
    ADD INDEX idx_tanggal_transaksi(tanggal_transaksi),
    ADD INDEX idx_pelanggan(pelanggan_id_pelanggan);

ALTER TABLE DETAIL_TRANSAKSI
    ADD INDEX idx_transaksi_detail(transaksi_id_transaksi),
    ADD INDEX idx_kursi_detail(kursi_id_kursi);