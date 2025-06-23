CREATE TABLE PELANGGAN (
    id_pelanggan CHAR(5) PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    no_telepon VARCHAR(15) NOT NULL,
    pass VARCHAR(100) NOT NULL
);

CREATE TABLE PROMOSI (
    id_promosi CHAR(10) PRIMARY KEY,
    nama_promosi VARCHAR(50) NOT NULL,
    diskon DECIMAL(5, 2) NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_berakhir DATE NOT NULL,
    minimum_pembelian INT NOT NULL DEFAULT 1
);

CREATE TABLE MAKANAN (
    id_makanan CHAR(5) PRIMARY KEY,
    harga DECIMAL(10, 2) NOT NULL,
    nama VARCHAR(30) NOT NULL,
    klasifikasi VARCHAR(20) NOT NULL,
    stok INT NOT NULL,
    deskripsi VARCHAR(100)
);

CREATE TABLE LOKASI_STUDIO (
    id_lokasi_studio CHAR(5) PRIMARY KEY,
    alamat_studio VARCHAR(100) NOT NULL,
    no_telp VARCHAR(15) NOT NULL,
    merk_studio VARCHAR(30) NOT NULL
);

CREATE TABLE FILM (
    id_film CHAR(5) PRIMARY KEY,
    file_gambar TEXT NOT NULL,
    judul_film VARCHAR(50) NOT NULL,
    genre VARCHAR(20) NOT NULL,
    durasi INT NOT NULL,
    sutradara VARCHAR(50) NOT NULL,
    rating_usia VARCHAR(30) NOT NULL,
    rating_film DECIMAL(4, 2) NOT NULL,
    sinopsis VARCHAR(500) NOT NULL
);

CREATE TABLE MEMBERSHIP (
    id_membership CHAR(5) PRIMARY KEY,
    email VARCHAR(50) NOT NULL,
    jenis_kelamin CHAR(1) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    poin INT NOT NULL,
    pelanggan_id_pelanggan CHAR(5) NOT NULL,
    FOREIGN KEY (pelanggan_id_pelanggan) REFERENCES PELANGGAN(id_pelanggan) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TEATER(
    id_teater CHAR(5) PRIMARY KEY,
    jumlah_kursi_tersedia INT NOT NULL,
    lokasi_studio_id_lokasi_studio CHAR(5) NOT NULL,
    FOREIGN KEY (lokasi_studio_id_lokasi_studio) REFERENCES LOKASI_STUDIO(id_lokasi_studio) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE JADWAL_TAYANG (
    id_tayang CHAR(7) PRIMARY KEY,
    jadwal DATETIME NOT NULL,
    film_id_film CHAR(5) NOT NULL,
    teater_id_teater CHAR(5) NOT NULL,
    FOREIGN KEY (film_id_film) REFERENCES FILM(id_film) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (teater_id_teater) REFERENCES TEATER(id_teater) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TRANSAKSI (
    id_transaksi CHAR(19) PRIMARY KEY,
    total_biaya DECIMAL(10, 2) NOT NULL,
    status ENUM('ACCEPTED', 'DRAFT') NOT NULL DEFAULT 'DRAFT',
    tanggal_transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pelanggan_id_pelanggan CHAR(5) NOT NULL,
    jadwal_tayang_id_tayang CHAR(7) NOT NULL,
    teater_id_teater CHAR(5) NOT NULL,
    FOREIGN KEY (pelanggan_id_pelanggan) REFERENCES PELANGGAN(id_pelanggan) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (jadwal_tayang_id_tayang) REFERENCES JADWAL_TAYANG(id_tayang) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (teater_id_teater) REFERENCES TEATER(id_teater) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE MAKANAN_LOKASI_STUDIO (
    makanan_id_makanan CHAR(5) NOT NULL,
    lokasi_studio_id_lokasi_studio CHAR(5) NOT NULL,
    PRIMARY KEY (makanan_id_makanan, lokasi_studio_id_lokasi_studio),
    FOREIGN KEY (makanan_id_makanan) REFERENCES MAKANAN(id_makanan) ON DELETE CASCADE ON UPDATE CASCADE,    
    FOREIGN KEY (lokasi_studio_id_lokasi_studio) REFERENCES LOKASI_STUDIO(id_lokasi_studio) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TRANSAKSI_MAKANAN (
    transaksi_id_transaksi CHAR(19) NOT NULL,
    makanan_id_makanan CHAR(5) NOT NULL,
    tanggal TIMESTAMP NOT NULL,
    jumlah INT NOT NULL,
    catatan VARCHAR(100),
    PRIMARY KEY (transaksi_id_transaksi, makanan_id_makanan),
    FOREIGN KEY (transaksi_id_transaksi) REFERENCES TRANSAKSI(id_transaksi) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (makanan_id_makanan) REFERENCES MAKANAN(id_makanan) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PROMOSI_TRANSAKSI(
    transaksi_id_transaksi CHAR(19) NOT NULL,
    promosi_id_promosi CHAR(10) NOT NULL,
    PRIMARY KEY (transaksi_id_transaksi, promosi_id_promosi),
    FOREIGN KEY (transaksi_id_transaksi) REFERENCES TRANSAKSI(id_transaksi) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (promosi_id_promosi) REFERENCES PROMOSI(id_promosi) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE KURSI(
    id_kursi CHAR(5) PRIMARY KEY,
    row_kursi CHAR(1) NOT NULL,
    column_kursi INT NOT NULL,
    harga_kursi DECIMAL(10, 2) NOT NULL,
    sedia BOOLEAN NOT NULL,
    teater_id_teater CHAR(5) NOT NULL,
    FOREIGN KEY (teater_id_teater) REFERENCES TEATER(id_teater) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE DETAIL_TRANSAKSI (
    id_detail_transaksi CHAR(10) PRIMARY KEY,
    transaksi_id_transaksi CHAR(19) NOT NULL,
    kursi_id_kursi CHAR(5) NOT NULL,
    FOREIGN KEY (transaksi_id_transaksi) REFERENCES TRANSAKSI(id_transaksi) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (kursi_id_kursi) REFERENCES KURSI(id_kursi) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE KURSI_JADWAL_TAYANG(
    kursi_id_kursi CHAR(5) NOT NULL,
    jadwal_tayang_id_tayang CHAR(7) NOT NULL,
    PRIMARY KEY (kursi_id_kursi, jadwal_tayang_id_tayang),
    FOREIGN KEY (kursi_id_kursi) REFERENCES KURSI(id_kursi) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (jadwal_tayang_id_tayang) REFERENCES JADWAL_TAYANG(id_tayang) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE LOG_NOTIFIKASI (
    id_notif INT AUTO_INCREMENT PRIMARY KEY,
    tipe_notif ENUM('ERROR', 'NOTICE'),
    pesan TEXT,
    waktu DATETIME
);

CREATE TABLE FILM_LOKASI_STUDIO (
   film_id_film CHAR(5) NOT NULL,
   lokasi_studio_id_lokasi_studio CHAR(5) NOT NULL,
   CONSTRAINT film_lokasi_studio_pk PRIMARY KEY (film_id_film, lokasi_studio_id_lokasi_studio),
   FOREIGN KEY (film_id_film) REFERENCES FILM(id_film) ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (lokasi_studio_id_lokasi_studio) REFERENCES LOKASI_STUDIO(id_lokasi_studio) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE USER_SESSIONS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    token VARCHAR(128) UNIQUE NOT NULL,
    id_pelanggan CHAR(5) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_pelanggan) REFERENCES PELANGGAN(id_pelanggan) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_pelanggan (id_pelanggan)
);
