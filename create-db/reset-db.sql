-- copas if want to reset the database
-- this resets the db and create only the table and the data
-- functions, procedures, and triggers are not included
SET @nama_db_fp_mbd = 'fp_mbd'; -- ganti dengan nama database kalian

DROP DATABASE IF EXISTS nama_db_fp_mbd;
CREATE DATABASE nama_db_fp_mbd;
USE nama_db_fp_mbd;

-- when session ends, the @nama_db_fp_mbd variable will be lost so no need for manual deallocation

-- create table
CREATE TABLE PELANGGAN (
    id_pelanggan CHAR(5) PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    no_telepon VARCHAR(15) NOT NULL,
    pass VARCHAR(50) NOT NULL
);

CREATE TABLE PROMOSI (
    id_promosi CHAR(10) PRIMARY KEY,
    nama_promosi VARCHAR(50) NOT NULL,
    diskon DECIMAL(5, 2) NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_berakhir DATE NOT NULL,
    minimum_pembelian INT NOT NULL
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
    id_makanan VARCHAR(20),
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

-- generate data
INSERT INTO PELANGGAN VALUES 
('P0001', 'Andi Wijaya', '081234567891', 'pass1234'),
('P0002', 'Siti Lestari', '081234567892', 'qwerty123'),
('P0003', 'Budi Santoso', '081234567893', 'abc12345'),
('P0004', 'Rina Permata', '081234567894', 'pass7890'),
('P0005', 'Dewi Ayu', '081234567895', 'hello321'),
('P0006', 'Agus Salim', '081234567896', 'mypassword'),
('P0007', 'Intan Nirmala', '081234567897', 'nirmala1'),
('P0008', 'Tono Wirawan', '081234567898', 'secure098'),
('P0009', 'Lina Rahmawati', '081234567899', 'rahma567'),
('P0010', 'Rudi Hartono', '081234567800', 'hartono12'),
('P0011', 'Ayu Pratiwi', '081234567811', 'pratiwi22'),
('P0012', 'Fajar Nugroho', '081234567812', 'fajar456'),
('P0013', 'Nina Marlina', '081234567813', 'marlina7'),
('P0014', 'Yusuf Kurniawan', '081234567814', 'yusufku'),
('P0015', 'Melati Putri', '081234567815', 'putri99'),
('P0016', 'Rio Prasetyo', '081234567816', 'riopra88'),
('P0017', 'Salsa Anjani', '081234567817', 'anjani23'),
('P0018', 'Dian Prakoso', '081234567818', 'prakoso45'),
('P0019', 'Aldo Wirawan', '081234567819', 'aldo000'),
('P0020', 'Kartika Dewi', '081234567820', 'kdewi56'),
('P0021', 'Bima Adi', '081234567821', 'bima1234'),
('P0022', 'Citra Lestari', '081234567822', 'citra789'),
('P0023', 'Dimas Prabowo', '081234567823', 'dimas456'),
('P0024', 'Eka Wulandari', '081234567824', 'eka321'),
('P0025', 'Fani Suryani', '081234567825', 'fani654'),
('P0026', 'Gilang Saputra', '081234567826', 'gilang789'),
('P0027', 'Hanafi Setiawan', '081234567827', 'hanafi123'),
('P0028', 'Intan Permata', '081234567828', 'intan456'),
('P0029', 'Joko Santoso', '081234567829', 'joko7890'),
('P0030', 'Kirana Ayu', '081234567830', 'kirana123'),
('P0031', 'Larasati Pratiwi', '081234567831', 'larasati456'),
('P0032', 'Maya Sari', '081234567832', 'maya789'),
('P0033', 'Nanda Prasetya', '081234567833', 'nanda1234'),
('P0034', 'Oki Wijaya', '081234567834', 'oki456'),
('P0035', 'Putra Adi', '081234567835', 'putra7890'),
('P0036', 'Qori Lestari', '081234567836', 'qori123'),
('P0037', 'Rizky Kurniawan', '081234567837', 'rizky456'),
('P0038', 'Siti Nurhaliza', '081234567838', 'siti789'),
('P0039', 'Tari Anjani', '081234567839', 'tari1234'),
('P0040', 'Umar Saputra', '081234567840', 'umar456'),
('P0041', 'Vina Wulandari', '081234567841', 'vina7890'),
('P0042', 'Wawan Setiawan', '081234567842', 'wawan123'),
('P0043', 'Xena Prabowo', '081234567843', 'xena456'),
('P0044', 'Yuni Sari', '081234567844', 'yuni789'),
('P0045', 'Zaki Adi', '081234567845', 'zaki1234'),
('P0046', 'Alya Permata', '081234567846', 'alya456'),
('P0047', 'Bintang Prasetya', '081234567847', 'bintang7890'),
('P0048', 'Cahya Lestari', '081234567848', 'cahya123'),
('P0049', 'Dewanto Wijaya', '081234567849', 'dewanto456'),
('P0050', 'Elisa Anjani', '081234567850', 'elisa789');

INSERT INTO PROMOSI VALUES 
('PR001', 'Promo Awal Tahun', 10.00, '2025-01-01', '2025-01-31', 50000),
('PR002', 'Promo Imlek', 15.00, '2025-02-01', '2025-02-15', 75000),
('PR003', 'Promo Valentine', 20.00, '2025-02-10', '2025-02-20', 60000),
('PR004', 'Promo Maret Ceria', 5.00, '2025-03-01', '2025-03-31', 40000),
('PR005', 'Promo Paskah', 25.00, '2025-04-01', '2025-04-15', 80000),
('PR006', 'Promo Lebaran', 30.00, '2025-05-01', '2025-05-30', 100000),
('PR007', 'Promo Kemerdekaan', 17.00, '2025-08-01', '2025-08-31', 77000),
('PR008', 'Promo Halloween', 13.00, '2025-10-20', '2025-10-31', 55000),
('PR009', 'Promo Natal', 20.00, '2025-12-01', '2025-12-25', 90000),
('PR010', 'Promo Tahun Baru', 22.00, '2025-12-26', '2026-01-05', 95000),
('PR011', 'Flash Sale', 40.00, '2025-06-01', '2025-06-03', 30000),
('PR012', 'Diskon Weekend', 12.00, '2025-06-07', '2025-06-09', 45000),
('PR013', 'Promo Spesial', 18.00, '2025-07-01', '2025-07-31', 70000),
('PR014', 'Diskon Mingguan', 8.00, '2025-06-10', '2025-06-17', 20000),
('PR015', 'Diskon Pelajar', 10.00, '2025-01-01', '2025-12-31', 40000),
('PR016', 'Promo Ramadhan', 35.00, '2025-03-10', '2025-04-10', 85000),
('PR017', 'Promo Akhir Tahun', 28.00, '2025-12-01', '2025-12-31', 95000),
('PR018', 'Voucher Ulang Tahun', 50.00, '2025-06-01', '2025-06-30', 60000),
('PR019', 'Diskon Partner', 20.00, '2025-04-01', '2025-05-01', 75000),
('PR020', 'Diskon Mega Sale', 45.00, '2025-11-01', '2025-11-11', 100000);

INSERT INTO MAKANAN VALUES 
('M001', 15000.00, 'Popcorn Karamel', 'Makanan', 100, 'Popcorn manis dengan rasa karamel.'),
('M002', 13000.00, 'Popcorn Asin', 'Makanan', 90, 'Popcorn gurih dengan sedikit garam.'),
('M003', 20000.00, 'Hotdog Jumbo', 'Makanan', 80, 'Sosis jumbo dengan roti lembut.'),
('M004', 12000.00, 'Teh Botol', 'Minuman', 70, 'Minuman teh manis dalam botol.'),
('M005', 10000.00, 'Air Mineral', 'Minuman', 200, 'Air mineral dalam kemasan.'),
('M006', 18000.00, 'Kentang Goreng', 'Makanan', 60, 'Kentang goreng renyah dengan saus.'),
('M007', 16000.00, 'Nachos', 'Camilan', 50, 'Keripik jagung dengan keju.'),
('M008', 22000.00, 'Burger Mini', 'Makanan', 40, 'Burger kecil isi daging dan sayur.'),
('M009', 14000.00, 'Sosis Bakar', 'Makanan', 55, 'Sosis bakar pedas manis.'),
('M010', 19000.00, 'Es Teh Manis', 'Minuman', 80, 'Teh dingin manis segar.'),
('M011', 25000.00, 'Cheeseburger', 'Makanan', 50, 'Burger dengan keju leleh.'),
('M012', 20000.00, 'Ayam Goreng', 'Makanan', 30, 'Ayam goreng crispy.'),
('M013', 12000.00, 'Jus Jeruk', 'Minuman', 100, 'Jus jeruk segar.'),
('M014', 17000.00, 'Jus Mangga', 'Minuman', 80, 'Jus mangga manis.'),
('M015', 15000.00, 'Camilan Mix', 'Camilan', 70, 'Campuran kacang dan keripik.'),
('M016', 13500.00, 'Roti Bakar', 'Makanan', 45, 'Roti isi cokelat dan keju.'),
('M017', 14500.00, 'Kue Brownies', 'Camilan', 35, 'Brownies cokelat lembut.'),
('M018', 15500.00, 'Mochi Ice Cream', 'Camilan', 25, 'Es krim dalam balutan mochi.'),
('M019', 12500.00, 'Soda Cola', 'Minuman', 60, 'Minuman bersoda segar.'),
('M020', 21000.00, 'Kopi Susu', 'Minuman', 70, 'Kopi susu kekinian.'),
('M021', 14000.00, 'Churros Cinnamon', 'Camilan', 40, 'Camilan manis dengan taburan kayu manis'),
('M022', 22500.00, 'Combo Family Pack', 'Makanan', 25, 'Paket popcorn jumbo dan 3 minuman'),
('M023', 18000.00, 'Ice Cream Sundae', 'Camilan', 30, 'Es krim dengan topping coklat dan kacang'),
('M024', 11500.00, 'Lemon Tea', 'Minuman', 65, 'Teh lemon dingin yang menyegarkan'),
('M025', 9000.00, 'Mineral Water Large', 'Minuman', 120, 'Air mineral kemasan besar'),
('M026', 25000.00, 'Pizza Mini', 'Makanan', 20, 'Pizza kecil dengan topping keju mozarella'),
('M027', 17500.00, 'French Fries Cheese', 'Makanan', 40, 'Kentang goreng dengan saus keju'),
('M028', 13500.00, 'Chocolate Milkshake', 'Minuman', 35, 'Minuman coklat susu kental'),
('M029', 16000.00, 'Caramel Pudding', 'Camilan', 25, 'Puding lembut dengan saus karamel'),
('M030', 19500.00, 'Chicken Wings', 'Makanan', 30, 'Sayap ayam pedas manis dengan saus BBQ');

INSERT INTO LOKASI_STUDIO VALUES 
('L001', 'Jl. Merdeka No.1, Jakarta', '0211234567', 'CineMax'),
('L002', 'Jl. Sudirman No.10, Jakarta', '0217654321', 'CineMax'),
('L003', 'Jl. Malioboro No.5, Yogyakarta', '0274123456', 'Movieland'),
('L004', 'Jl. Dago No.3, Bandung', '0229876543', 'Bioskop Kita'),
('L005', 'Jl. Gajah Mada No.7, Semarang', '0241237890', 'CineStar'),
('L006', 'Jl. Diponegoro No.9, Surabaya', '0311234567', 'SilverScreen'),
('L007', 'Jl. Kuta No.2, Bali', '0361122334', 'Bali Cinema'),
('L008', 'Jl. Soekarno Hatta No.8, Malang', '0341987654', 'Movieland'),
('L009', 'Jl. Asia Afrika No.12, Bandung', '0221231234', 'CineMax'),
('L010', 'Jl. Veteran No.6, Bogor', '0251123123', 'Bioskop Kita'),
('L011', 'Jl. Margonda No.4, Depok', '0215678912', 'CineStar'),
('L012', 'Jl. Ahmad Yani No.20, Bekasi', '0211239876', 'Bioskop Kita'),
('L013', 'Jl. Slamet Riyadi No.3, Solo', '0271123456', 'Movieland'),
('L014', 'Jl. Imam Bonjol No.14, Medan', '0619876543', 'SilverScreen'),
('L015', 'Jl. Sisingamangaraja No.11, Pekanbaru', '0761123123', 'CineMax'),
('L016', 'Jl. Diponegoro No.5, Padang', '0751123987', 'Bioskop Kita'),
('L017', 'Jl. Rajawali No.9, Palembang', '0711123456', 'CineStar'),
('L018', 'Jl. Pattimura No.15, Manado', '0431123456', 'Bali Cinema'),
('L019', 'Jl. Antasari No.6, Banjarmasin', '0511123456', 'Movieland'),
('L020', 'Jl. Basuki Rahmat No.7, Samarinda', '0541123456', 'SilverScreen');

INSERT INTO FILM VALUES
('F001', 'petualangan_si_kancil.jpg', 'Petualangan Si Kancil', 'Animation', 90, 'Dewi Larasati', 'SU', 8.1, 'Kisah seru si Kancil yang cerdik dan pemberani.'),
('F002', 'cinta_dalam_sepotong_roti.jpg', 'Cinta Dalam Sepotong Roti', 'Romance', 110, 'Rudi Hendra', '13+', 7.8, 'Drama cinta yang mengharukan di kota kecil.'),
('F003', 'horor_tengah_malam.jpg', 'Horor Tengah Malam', 'Horror', 95, 'Sinta Prabowo', '17+', 6.9, 'Kumpulan kisah horor yang menyeramkan.'),
('F004', 'aksi_balas_dendam.jpg', 'Aksi Balas Dendam', 'Action', 120, 'Dimas Hardian', '17+', 8.4, 'Seorang mantan agen rahasia kembali beraksi.'),
('F005', 'alien_dari_masa_lalu.jpg', 'Alien dari Masa Lalu', 'Sci-Fi', 130, 'Surya Dharma', '13+', 7.5, 'Kedatangan alien yang membawa misteri waktu.'),
('F006', 'misteri_desa_hilang.jpg', 'Misteri Desa Hilang', 'Mystery', 105, 'Nina Anggraini', '13+', 7.1, 'Desa yang tiba-tiba menghilang dan penuh misteri.'),
('F007', 'komedi_tengah_malam.jpg', 'Komedi Tengah Malam', 'Comedy', 100, 'Tono Wijaya', 'SU', 7.9, 'Kisah lucu para penghuni kos malam hari.'),
('F008', 'perjalanan_waktu.jpg', 'Perjalanan Waktu', 'Sci-Fi', 115, 'Aldo Budi', '13+', 8.3, 'Petualangan melintasi waktu ke masa lalu.'),
('F009', 'legenda_gunung_merapi.jpg', 'Legenda Gunung Merapi', 'Drama', 140, 'Bagas Putra', 'SU', 7.6, 'Legenda rakyat yang hidup kembali di layar lebar.'),
('F010', 'rahasia_sang_pianis.jpg', 'Rahasia Sang Pianis', 'Drama', 90, 'Yuni Saraswati', '13+', 7.4, 'Pianis jenius dengan masa lalu misterius.'),
('F011', 'serangan_zombie.jpg', 'Serangan Zombie', 'Horror', 105, 'Dian Nugroho', '17+', 6.8, 'Kota diserang oleh pasukan zombie haus darah.'),
('F012', 'cinta_di_ujung_pulau.jpg', 'Cinta di Ujung Pulau', 'Romance', 95, 'Ayu Pratiwi', '13+', 7.9, 'Dua insan bertemu di pulau terpencil.'),
('F013', 'pencuri_hati.jpg', 'Pencuri Hati', 'Romance', 100, 'Rio Mahendra', '13+', 7.7, 'Kisah pencopet yang jatuh cinta pada korbannya.'),
('F014', 'balapan_gila.jpg', 'Balapan Gila', 'Action', 110, 'Fajar Nugraha', '13+', 8.0, 'Aksi balapan liar yang memacu adrenalin.'),
('F015', 'hantu_selfie.jpg', 'Hantu Selfie', 'Horror', 90, 'Maya Ratih', '17+', 6.7, 'Kamera selfie yang menangkap roh penasaran.'),
('F016', 'si_juki_the_movie.jpg', 'Si Juki The Movie', 'Animation', 85, 'Faza Meonk', 'SU', 8.5, 'Petualangan Si Juki menyelamatkan dunia.'),
('F017', 'operasi_tangkap_tangan.jpg', 'Operasi Tangkap Tangan', 'Action', 115, 'Andi Susanto', '17+', 8.1, 'Operasi rahasia membongkar korupsi besar.'),
('F018', 'di_balik_kabut.jpg', 'Di Balik Kabut', 'Mystery', 105, 'Rina Kartika', '13+', 7.3, 'Kejadian aneh di desa yang diselimuti kabut.'),
('F019', 'adu_nasib.jpg', 'Adu Nasib', 'Drama', 120, 'Wawan Setiawan', '13+', 7.2, 'Dua sahabat bersaing untuk sukses.'),
('F020', 'perang_dunia_4.jpg', 'Perang Dunia 4', 'Sci-Fi', 130, 'Gunawan Budi', '17+', 8.6, 'Bumi menghadapi kehancuran total dari alien.'),
('F021', 'sang_pahlawan_terakhir.jpg', 'Sang Pahlawan Terakhir', 'Action', 125, 'Bambang Surya', '13+', 8.2, 'Kisah heroik seorang pahlawan di masa perang'),
('F022', 'mimpi_seribu_malam.jpg', 'Mimpi Seribu Malam', 'Fantasy', 115, 'Dinda Kusuma', 'SU', 7.9, 'Petualangan fantasi di dunia mimpi tanpa batas'),
('F023', 'detektif_jalanan.jpg', 'Detektif Jalanan', 'Crime', 110, 'Iman Perdana', '17+', 8.0, 'Detektif amatir memecahkan kasus pembunuhan misterius'),
('F024', 'surat_untuk_bintang.jpg', 'Surat untuk Bintang', 'Romance', 105, 'Lidya Cantika', '13+', 7.6, 'Kisah cinta yang bermula dari surat tak bertuan'),
('F025', 'lompatan_quantum.jpg', 'Lompatan Quantum', 'Sci-Fi', 140, 'Reza Mahardika', '13+', 8.4, 'Petualangan melompati dimensi ruang dan waktu'),
('F026', 'stand_up_komedi.jpg', 'Stand Up Komedi', 'Comedy', 95, 'Tora Sudiro', 'SU', 8.7, 'Kumpulan lelucon dari komedian terbaik Indonesia'),
('F027', 'rumah_angker_nenek.jpg', 'Rumah Angker Nenek.jpg', 'Horror', 100, 'Dian Sastro', '17+', 7.2, 'Teror mencekam di rumah peninggalan nenek'),
('F028', 'jelajah_indonesia.jpg', 'Jelajah Indonesia', 'Documentary', 120, 'Riri Riza', 'SU', 8.3, 'Dokumenter keindahan alam dan budaya nusantara'),
('F029', 'pendekar_bayangan.jpg', 'Pendekar Bayangan', 'Martial Arts', 130, 'Joe Taslim', '13+', 8.5, 'Pertarungan seni bela diri untuk membalaskan dendam'),
('F030', 'melodi_hati.jpg', 'Melodi Hati', 'Musical', 110, 'Raisa Andriana', 'SU', 7.8, 'Kisah cinta yang diceritakan melalui lagu dan tarian');


-- 1. MEMBERSHIP (20 pelanggan, random poin & tanggal_lahir)
INSERT INTO MEMBERSHIP VALUES
('M0001','andi@contoh.com','L','1990-05-10', 120,'P0001'),
('M0002','siti@contoh.com','P','1988-07-22', 80,'P0002'),
('M0003','budi@contoh.com','L','1992-11-05', 45,'P0003'),
('M0004','rina@contoh.com','P','1991-02-18', 200,'P0004'),
('M0005','dewi@contoh.com','P','1993-09-30', 150,'P0005'),
('M0006','agus@contoh.com','L','1985-12-12', 95,'P0006'),
('M0007','intan@contoh.com','P','1994-04-04', 30,'P0007'),
('M0008','tono@contoh.com','L','1989-06-20', 110,'P0008'),
('M0009','lina@contoh.com','P','1990-08-08', 60,'P0009'),
('M0010','rudi@contoh.com','L','1987-03-15', 75,'P0010');

-- ('M0011','ayu@contoh.com','P','1995-01-25', 180,'P0011'),
-- ('M0012','fajar@contoh.com','L','1992-10-10', 55,'P0012'),
-- ('M0013','nina@contoh.com','P','1993-12-12', 130,'P0013'),
-- ('M0014','yusuf@contoh.com','L','1986-09-05', 210,'P0014'),
-- ('M0015','melati@contoh.com','P','1994-11-11', 90,'P0015'),
-- ('M0016','rio@contoh.com','L','1991-07-07', 60,'P0016'),
-- ('M0017','salsa@contoh.com','P','1992-03-03', 140,'P0017'),
-- ('M0018','dian@contoh.com','P','1990-08-18', 50,'P0018'),
-- ('M0019','aldo@contoh.com','L','1988-02-02', 95,'P0019'),
-- ('M0020','kartika@contoh.com','P','1995-05-05', 160,'P0020');

-- 2. TEATER (5 teater tersebar di lokasi)
INSERT INTO TEATER VALUES
('T001',150,'L001'),
('T002',120,'L002'),
('T003',100,'L006'),
('T004',130,'L004'),
('T005',110,'L006'),
('T006',180, 'L003'),
('T007',90, 'L004'),
('T008',140, 'L005'),
('T009',120, 'L008'),
('T010',200, 'L009');

-- 3. JADWAL_TAYANG (10 jadwal film)
INSERT INTO JADWAL_TAYANG VALUES
('J001','2025-06-10 14:00:00','F001','T001'),
('J002','2025-06-10 16:30:00','F002','T002'),
('J003','2025-06-11 19:00:00','F003','T003'),
('J004','2025-06-12 20:00:00','F004','T001'),
('J005','2025-06-13 13:00:00','F005','T004'),
('J006','2025-06-14 15:00:00','F006','T005'),
('J007','2025-06-15 18:00:00','F007','T002'),
('J008','2025-06-16 20:30:00','F008','T003'),
('J009','2025-06-17 14:30:00','F009','T004'),
('J010','2025-06-18 19:30:00','F010','T005'),
('J011','2025-06-19 13:45:00', 'F011', 'T001'),
('J012','2025-06-19 16:15:00', 'F012', 'T002'),
('J013','2025-06-20 14:30:00', 'F013', 'T003'),
('J014','2025-06-20 19:45:00', 'F014', 'T004'),
('J015','2025-06-21 12:30:00', 'F015', 'T005'),
('J016','2025-06-21 17:00:00', 'F016', 'T006'),
('J017','2025-06-22 15:30:00', 'F017', 'T007'),
('J018','2025-06-22 20:00:00', 'F018', 'T008'),
('J019','2025-06-23 14:15:00', 'F019', 'T009'),
('J020','2025-06-23 18:45:00', 'F020', 'T010');

-- 4. MAKANAN_LOKASI_STUDIO (setiap studio sediakan sebagian menu)
INSERT INTO MAKANAN_LOKASI_STUDIO VALUES
('M001','L001'),('M002','L001'),('M003','L001'),
('M004','L006'),('M005','L006'),('M006','L006'),
('M007','L002'),('M008','L002'),
('M009','L004'),('M010','L004'),
('M011','L003'),('M012','L003'),
('M013','L005'),('M014','L005'),
('M015','L001'),('M016','L006'),
('M017', 'L001'), ('M018', 'L001'),
('M019', 'L002'), ('M020', 'L002'),
('M021', 'L003'), ('M022', 'L003'),
('M023', 'L004'), ('M024', 'L004'),
('M025', 'L005'), ('M026', 'L005'),
('M027', 'L006'), ('M028', 'L006'),
('M029', 'L008'), ('M030', 'L009');

-- 5. TRANSAKSI (5 transaksi contoh)
INSERT INTO TRANSAKSI VALUES
('TRX202506100001',200000,'2025-06-10 10:00:00','P0001','J001','T001'),
('TRX202506100002',150000,'2025-06-10 11:00:00','P0002','J002','T002'),
('TRX202506110001',100000,'2025-06-11 12:00:00','P0004','J003','T003'),
('TRX202506120001',250000,'2025-06-12 13:00:00','P0005','J004','T004'),
('TRX202506130001',180000,'2025-06-13 14:00:00','P0008','J005','T005'),
('TRX202506140001', 220000, '2025-06-14 09:30:00', 'P0003', 'J006', 'T001'),
('TRX202506150001', 175000, '2025-06-15 10:45:00', 'P0006', 'J007', 'T002'),
('TRX202506160001', 195000, '2025-06-16 13:20:00', 'P0007', 'J008', 'T003'),
('TRX202506160002', 280000, '2025-06-16 15:10:00', 'P0009', 'J009', 'T004'),
('TRX202506170001', 240000, '2025-06-17 11:30:00', 'P0010', 'J010', 'T005');

-- 6. TRANSAKSI_MAKANAN (menu dipilih, jumlah)
INSERT INTO TRANSAKSI_MAKANAN VALUES
('TRX202506100001','M001','2025-06-10 10:05:00',2,''),
('TRX202506100001','M004','2025-06-10 10:05:00',1,'tidak pakai es'),
('TRX202506100002','M002','2025-06-10 11:10:00',1,''),
('TRX202506100002','M005','2025-06-10 11:10:00',2,''),
('TRX202506110001','M003','2025-06-11 12:20:00',1,'extra saus'),
('TRX202506120001','M006','2025-06-12 13:30:00',3,'pedas'),
('TRX202506130001','M007','2025-06-13 14:25:00',2,''),
('TRX202506140001', 'M008', '2025-06-14 09:45:00', 2, 'extra cheese'),
('TRX202506140001', 'M010', '2025-06-14 09:45:00', 2, 'less ice'),
('TRX202506150001', 'M015', '2025-06-15 11:00:00', 1, ''),
('TRX202506150001', 'M020', '2025-06-15 11:00:00', 1, 'extra hot'),
('TRX202506160001', 'M021', '2025-06-16 13:25:00', 3, 'extra sugar'),
('TRX202506160002', 'M022', '2025-06-16 15:15:00', 1, ''),
('TRX202506160002', 'M023', '2025-06-16 15:15:00', 2, 'no nuts'),
('TRX202506170001', 'M026', '2025-06-17 11:40:00', 2, 'extra cheese'),
('TRX202506170001', 'M028', '2025-06-17 11:40:00', 3, '');

-- 7. PROMOSI_TRANSAKSI (promosi terpakai)
INSERT INTO PROMOSI_TRANSAKSI VALUES
('TRX202506100001','PR014'),
('TRX202506100002','PR011'),
('TRX202506110001','PR012'),
('TRX202506120001','PR011'),
('TRX202506130001','PR018');

-- 8. KURSI (sederhana, jumlah kursi dipesan)
-- 8. KURSI (with harga_kursi column added)
INSERT INTO KURSI VALUES
('K001','A',1,50000.00,TRUE,'T001'),
('K002','A',2,50000.00,TRUE,'T001'),
('K003','B',5,75000.00,TRUE,'T002'),
('K004','C',3,50000.00,TRUE,'T003'),
('K005','D',4,100000.00,TRUE,'T004'),
('K006','E',7,90000.00,TRUE,'T005'),
('K007','B',3,50000.00,TRUE,'T001'),
('K008','B',4,50000.00,TRUE,'T001'),
('K009','C',5,75000.00,TRUE,'T002'),
('K010','C',6,75000.00,TRUE,'T002'),
('K011','D',7,50000.00,TRUE,'T003'),
('K012','D',8,50000.00,TRUE,'T003'),
('K013','F',10,100000.00,TRUE,'T004'),
('K014','F',11,100000.00,TRUE,'T004'),
('K015','G',9,90000.00,TRUE,'T005'),
('K016','G',10,90000.00,TRUE,'T005');

-- 8.5. DETAIL_TRANSAKSI (detail kursi untuk setiap transaksi)
INSERT INTO DETAIL_TRANSAKSI VALUES
('DT001','TRX202506100001','K001'),
('DT002','TRX202506100001','K002'),
('DT003','TRX202506100002','K003'),
('DT004','TRX202506110001','K004'),
('DT005','TRX202506120001','K005'),
('DT006','TRX202506130001','K006'),
('DT007','TRX202506140001','K007'),
('DT008','TRX202506140001','K008'),
('DT009','TRX202506150001','K009'),
('DT010','TRX202506150001','K010'),
('DT011','TRX202506160001','K011'),
('DT012','TRX202506160001','K012'),
('DT013','TRX202506160002','K013'),
('DT014','TRX202506160002','K014'),
('DT015','TRX202506170001','K015'),
('DT016','TRX202506170001','K016');

-- 9. KURSI_JADWAL_TAYANG (kursi dipesan terkait jadwal)
INSERT INTO KURSI_JADWAL_TAYANG VALUES
('K001','J001'),
('K002','J001'),
('K003','J002'),
('K004','J003'),
('K005','J004'),
('K006','J005'),
('K007', 'J006'),
('K008', 'J006'),
('K009', 'J007'),
('K010', 'J007'),
('K011', 'J008'),
('K012', 'J008'),
('K013', 'J009'),
('K014', 'J009'),
('K015', 'J010'),
('K016', 'J010');

-- 9. FILM_LOKASI_STUDIO
INSERT INTO FILM_LOKASI_STUDIO VALUES
('F001', 'L001'),
('F001', 'L002'),
('F001', 'L003'),
('F002', 'L002'),
('F002', 'L004'),
('F003', 'L001'),
('F003', 'L004'),
('F003', 'L005'),
('F004', 'L003'),
('F004', 'L005'),
('F005', 'L006'),
('F005', 'L007'),
('F005', 'L001'),
('F006', 'L002'),
('F006', 'L006'),
('F006', 'L008'),
('F007', 'L003'),
('F007', 'L005'),
('F007', 'L009'),
('F008', 'L010'),
('F008', 'L001'),
('F008', 'L002'),
('F009', 'L011'),
('F009', 'L006'),
('F009', 'L003'),
('F010', 'L007'),
('F010', 'L008'),
('F010', 'L004'),
('F011', 'L005'),
('F011', 'L009'),
('F011', 'L010'),
('F012', 'L002'),
('F012', 'L003'),
('F012', 'L011'),
('F013', 'L004'),
('F013', 'L001'),
('F013', 'L012'),
('F014', 'L006'),
('F014', 'L013'),
('F014', 'L007'),
('F015', 'L008'),
('F015', 'L009'),
('F015', 'L014'),
('F016', 'L010'),
('F016', 'L002'),
('F016', 'L015'),
('F017', 'L005'),
('F017', 'L011'),
('F017', 'L003'),
('F018', 'L004'),
('F018', 'L006'),
('F018', 'L012'),
('F019', 'L013'),
('F019', 'L014'),
('F019', 'L001'),
('F020', 'L015'),
('F020', 'L007'),
('F020', 'L002');
