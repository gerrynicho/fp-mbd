CREATE TABLE PELANGGAN (
    id_pelanggan CHAR(5) PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    no_telepon VARCHAR(15) NOT NULL,
);

CREATE TABLE PROMOSI (
    id_promosi CHAR(10) PRIMARY KEY,
    nama_promosi VARCHAR(50) NOT NULL,
    diskon DECIMAL(5, 2) NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_berakhir DATE NOT NULL
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
    merk_studio VARCHAR(30) NOT NULL,
);

CREATE TABLE FILM (
    id_film CHAR(5) PRIMARY KEY,
    judul_film VARCHAR(50) NOT NULL,
    genre VARCHAR(20) NOT NULL,
    durasi INT NOT NULL,
    sutradara VARCHAR(50) NOT NULL,
    rating_usia VARCHAR(30) NOT NULL,
    rating_film DECIMAL(4, 2) NOT NULL,
    sinopsis VARCHAR(500) NOT NULL,
);

CREATE TABLE MEMBERSHIP (
    id_membership CHAR(5) PRIMARY KEY,
    email VARCHAR(50) NOT NULL,
    jenis_kelamin CHAR(1) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    poin INT NOT NULL,
    pelanggan_id_pelanggan CHAR(5) NOT NULL,
    FOREIGN KEY (pelanggan_id_pelanggan) REFERENCES PELANGGAN(id_pelanggan)
);