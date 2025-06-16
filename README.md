# Table of Contents
- [Table of Contents](#table-of-contents)
- [🎬 Bioskop Database Design – Fitur \& Indexing](#-bioskop-database-design--fitur--indexing)
  - [📊 Database Schema Overview](#-database-schema-overview)
    - [Recent Schema Updates (Version 2.0)](#recent-schema-updates-version-20)
      - [🔄 **Perubahan Utama:**](#-perubahan-utama)
      - [🗃️ **Tabel Baru:**](#️-tabel-baru)
      - [🔧 **Tabel Yang Diperbarui:**](#-tabel-yang-diperbarui)
  - [🔄 Schema Migration Benefits](#-schema-migration-benefits)
    - [Keuntungan Schema Baru:](#keuntungan-schema-baru)
    - [Migration Notes:](#migration-notes)
  - [🧠 Function](#-function)
    - [1. Cek Membership Pelanggan](#1-cek-membership-pelanggan)
    - [2. Validasi Masa Berlaku Promosi](#2-validasi-masa-berlaku-promosi)
    - [3. Hitung Total Penggunaan Promosi](#3-hitung-total-penggunaan-promosi)
    - [4. Kalkulasi Harga Setelah Promo](#4-kalkulasi-harga-setelah-promo)
    - [5. Kalkulasi Harga Makanan dalam Keranjang](#5-kalkulasi-harga-makanan-dalam-keranjang)
    - [6. Kembalikan Stok Makanan](#6-kembalikan-stok-makanan)
    - [7. Cek Poin untuk Free Tiket](#7-cek-poin-untuk-free-tiket)
    - [8. Konversi Total Harga Menjadi Poin](#8-konversi-total-harga-menjadi-poin)
    - [9. Hitung Pajak](#9-hitung-pajak)
    - [10. Hitung Refund Pembatalan](#10-hitung-refund-pembatalan)
    - [11. Hitung Total Transaksi](#11-hitung-total-transaksi)
    - [12. Hitung Harga Kursi](#12-hitung-harga-kursi)
  - [⚡ Trigger](#-trigger)
    - [1. Promosi untuk 10 Orang Pertama per Hari](#1-promosi-untuk-10-orang-pertama-per-hari)
    - [2. Trigger Stok Menipis](#2-trigger-stok-menipis)
    - [3. Diskon Tambahan untuk Membership](#3-diskon-tambahan-untuk-membership)
    - [4. Tambah Poin saat Transaksi](#4-tambah-poin-saat-transaksi)
    - [5. Trigger Pesan Kursi](#5-trigger-pesan-kursi)
    - [6. Trigger Kosongkan Kursi Setelah Film](#6-trigger-kosongkan-kursi-setelah-film)
  - [🧩 Stored Procedure](#-stored-procedure)
    - [1. Top 3 Makanan Terlaris per Kategori](#1-top-3-makanan-terlaris-per-kategori)
    - [2. Film Paling Populer](#2-film-paling-populer)
    - [3. Pelanggan dengan Transaksi Terbanyak](#3-pelanggan-dengan-transaksi-terbanyak)
    - [4. Prosedur Transaksi Lengkap](#4-prosedur-transaksi-lengkap)
    - [5. Studio Menjual Makanan Apa Saja](#5-studio-menjual-makanan-apa-saja)
    - [6. Studio Menayangkan Film Apa Saja](#6-studio-menayangkan-film-apa-saja)
    - [7. Teater Tempat Film Ditayangkan](#7-teater-tempat-film-ditayangkan)
    - [8. Jadwal Tayang di Teater Tertentu](#8-jadwal-tayang-di-teater-tertentu)
    - [9. Film Tersedia Berdasarkan Tanggal dan Lokasi](#9-film-tersedia-berdasarkan-tanggal-dan-lokasi)
    - [10. Pembatalan Transaksi](#10-pembatalan-transaksi)
    - [11. Edit Transaksi (Pindah Kursi/Jadwal)](#11-edit-transaksi-pindah-kursijadwal)
  - [🗂️ Index](#️-index)
    - [📁 Table: `Film`](#-table-film)
    - [📁 Table: `Jadwal_Tayang`](#-table-jadwal_tayang)
    - [📁 Table: `Kursi`](#-table-kursi)
    - [📁 Table: `Lokasi_Studio`](#-table-lokasi_studio)
    - [📁 Table: `Pelanggan`](#-table-pelanggan)
    - [📁 Table: `Transaksi`](#-table-transaksi)
    - [📁 Table: `Detail_Transaksi`](#-table-detail_transaksi)
  
# 🎬 Bioskop Database Design – Fitur & Indexing

## 📊 Database Schema Overview

### Recent Schema Updates (Version 2.0)

Sistem database telah diperbarui dengan perubahan signifikan untuk meningkatkan normalisasi dan fleksibilitas:

#### 🔄 **Perubahan Utama:**

1. **Relasi Transaksi dan Detail Transaksi** - **0 to Many**
   - Sebelumnya: Relasi one-to-one antara transaksi dan kursi
   - Sekarang: Tabel `DETAIL_TRANSAKSI` baru untuk menangani multiple kursi per transaksi

2. **Koneksi Langsung Transaksi**
   - **Jadwal Tayang ↔ Transaksi**: Koneksi langsung melalui `jadwal_tayang_id_tayang`
   - **Teater ↔ Transaksi**: Koneksi langsung melalui `teater_id_teater`

3. **Peningkatan Atribut Waktu**
   - Kolom `tanggal_transaksi` dengan tipe `DATETIME` untuk timestamp yang lebih akurat

#### 🗃️ **Tabel Baru:**

```sql
CREATE TABLE DETAIL_TRANSAKSI (
    id_detail_transaksi CHAR(10) PRIMARY KEY,
    transaksi_id_transaksi CHAR(19) NOT NULL,
    kursi_id_kursi CHAR(5) NOT NULL,
    harga_kursi DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (transaksi_id_transaksi) REFERENCES TRANSAKSI(id_transaksi),
    FOREIGN KEY (kursi_id_kursi) REFERENCES KURSI(id_kursi)
);
```

#### 🔧 **Tabel Yang Diperbarui:**

**TRANSAKSI:**
```sql
CREATE TABLE TRANSAKSI (
    id_transaksi CHAR(19) PRIMARY KEY,
    total_biaya DECIMAL(10, 2) NOT NULL,
    biaya_pajak DECIMAL(10, 2) NOT NULL,
    tanggal_transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pelanggan_id_pelanggan CHAR(5) NOT NULL,
    jadwal_tayang_id_tayang CHAR(7) NOT NULL,
    teater_id_teater CHAR(5) NOT NULL,
    -- Foreign keys...
);
```

**KURSI:**
```sql
CREATE TABLE KURSI(
    id_kursi CHAR(5) PRIMARY KEY,
    row_kursi CHAR(1) NOT NULL,
    column_kursi INT NOT NULL,
    sedia BOOLEAN NOT NULL,
    teater_id_teater CHAR(5) NOT NULL,  -- Bukan lagi ke transaksi
    FOREIGN KEY (teater_id_teater) REFERENCES TEATER(id_teater)
);
```

---

## 🔄 Schema Migration Benefits

### Keuntungan Schema Baru:

1. **📈 Skalabilitas Lebih Baik**
   - Satu transaksi dapat menangani multiple kursi dengan mudah
   - Struktur yang lebih fleksibel untuk ekspansi fitur

2. **🎯 Normalisasi Improved**
   - Pemisahan concern antara transaksi dan detail kursi
   - Relasi yang lebih jelas antar entitas

3. **⚡ Performance Enhancement**
   - Koneksi langsung jadwal-transaksi dan teater-transaksi mengurangi kompleksitas join
   - Index yang lebih optimal untuk query umum

4. **🔒 Data Integrity**
   - Foreign key constraints yang lebih ketat
   - Validasi data yang lebih baik melalui triggers

5. **🛠️ Maintainability**
   - Code yang lebih mudah dipahami dan dimaintain
   - Trigger dan stored procedure yang lebih efisien

### Migration Notes:

- **Backward Compatibility**: Schema lama tidak kompatibel dengan yang baru
- **Data Migration**: Semua data dummy telah diupdate sesuai struktur baru
- **Testing**: Semua function, trigger, dan stored procedure telah diuji dengan schema baru
- **Performance**: Query performance meningkat untuk operasi yang sering digunakan

---

## 🧠 Function

### 1. Cek Membership Pelanggan
Mengembalikan apakah pelanggan memiliki status membership berdasarkan ID pelanggan.

```
-- #1 CEK MEMBERSHIP PELANGGAN [DONE]
DELIMITER //
CREATE FUNCTION cek_membership(p_id CHAR(5))
-- gk bisa deterministic gara" bisa aja function call before bikin membership baru
-- trus pas user bikin membership
-- function ini klo deterministic bakal kasi info salah
RETURNS BOOLEAN
BEGIN
    DECLARE status BOOL;
    SELECT EXISTS (
        SELECT 1 FROM MEMBERSHIP WHERE pelanggan_id_pelanggan = p_id
    ) INTO status;
    RETURN status;
END;
//
DELIMITER ;
```

### 2. Validasi Masa Berlaku Promosi
Mengecek apakah tanggal saat ini masih dalam rentang masa berlaku promosi.

### 3. Hitung Total Penggunaan Promosi
Mengembalikan total jumlah penggunaan promosi tertentu oleh semua pelanggan.

### 4. Kalkulasi Harga Setelah Promo
Mengurangi harga awal dengan persentase atau nilai diskon dari promosi yang valid.

### 5. Kalkulasi Harga Makanan dalam Keranjang
Menghitung total harga makanan berdasarkan kuantitas dan harga satuan masing-masing item dalam keranjang.

### 6. Kembalikan Stok Makanan
Mengembalikan stok makanan ke jumlah awal apabila transaksi dibatalkan.

### 7. Cek Poin untuk Free Tiket
Mengecek jika poin pelanggan >= 100, maka tiket gratis akan diterapkan.

### 8. Konversi Total Harga Menjadi Poin
Mengubah total harga transaksi menjadi poin, misalnya setiap Rp25.000 = 1 poin.

### 9. Hitung Pajak
Menambahkan pajak (misal 10%) dari subtotal transaksi.

### 10. Hitung Refund Pembatalan
Menghitung nominal refund sesuai kebijakan (misal potongan 20% dari total).

### 11. Hitung Total Transaksi
Menjumlahkan subtotal, pajak, biaya admin, dan dikurangi diskon jika ada.

### 12. Hitung Harga Kursi
Mengembalikan harga berdasarkan banyaknya kursi yang dipesan.

---

## ⚡ Trigger

### 1. Promosi untuk 10 Orang Pertama per Hari
Trigger untuk membatasi promosi hanya berlaku untuk 10 transaksi pertama pada hari tersebut.

### 2. Trigger Stok Menipis
Mengirimkan notifikasi atau log jika stok makanan < ambang batas tertentu.

### 3. Diskon Tambahan untuk Membership
Trigger otomatis menambahkan diskon tambahan jika pelanggan adalah member aktif.

### 4. Tambah Poin saat Transaksi
Setiap transaksi sukses akan menambahkan poin ke akun pelanggan berdasarkan nilai transaksi. Tiap 10.000 akan menambahkan 1 poin.

```sql
DELIMITER $$

CREATE TRIGGER tambah_poin_setelah_transaksi
AFTER INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN
    DECLARE tambahan_poin INT;
    DECLARE jumlah_membership INT;

    -- Cek apakah pelanggan punya akun membership
    SELECT COUNT(*) INTO jumlah_membership
    FROM MEMBERSHIP
    WHERE pelanggan_id_pelanggan = NEW.pelanggan_id_pelanggan;

    -- Jika punya membership dan total biaya >= 10000
    IF jumlah_membership > 0 AND NEW.total_biaya >= 10000 THEN
        SET tambahan_poin = FLOOR(NEW.total_biaya / 10000);

        -- Update poin pelanggan
        UPDATE MEMBERSHIP
        SET poin = poin + tambahan_poin
        WHERE pelanggan_id_pelanggan = NEW.pelanggan_id_pelanggan;
    END IF;
END$$

DELIMITER ;
```

Input data yang diperluhkan untuk testing

```sql
INSERT INTO PELANGGAN (id_pelanggan, nama, no_telepon, pass)
VALUES ('P0001', 'Budi', '081234567890', 'pass123');
INSERT INTO MEMBERSHIP (id_membership, email, jenis_kelamin, tanggal_lahir, poin, pelanggan_id_pelanggan)
VALUES ('M0001', 'budi@email.com', 'L', '2000-01-01', 0, 'P0001');
INSERT INTO PELANGGAN (id_pelanggan, nama, no_telepon, pass)
VALUES ('P0002', 'Siti', '089876543210', 'pass456');
```

Testing

```sql
INSERT INTO TRANSAKSI (id_transaksi, total_biaya, biaya_pajak, pelanggan_id_pelanggan)
VALUES ('TRX000000000000001', 45000.00, 4500.00, 'P0001');
INSERT INTO TRANSAKSI (id_transaksi, total_biaya, biaya_pajak, pelanggan_id_pelanggan)
VALUES ('TRX000000000000002', 60000.00, 6000.00, 'P0002');
INSERT INTO TRANSAKSI (id_transaksi, total_biaya, biaya_pajak, pelanggan_id_pelanggan)
VALUES ('TRX000000000000003', 8000.00, 800.00, 'P0001');
```

P0001 akan mempunyai 4 poin karena dia memiliki membership dan mengeluarkan biaya lebih dari 10.000

P0002 tidak memiliki poin karena dia tidak memiliki membership

Cek

```sql
SELECT * FROM MEMBERSHIP WHERE pelanggan_id_pelanggan = 'P0001';
SELECT * FROM MEMBERSHIP WHERE pelanggan_id_pelanggan = 'P0002';
```

![image](https://github.com/user-attachments/assets/74150003-00cc-4736-bad9-3cb573e6a91e)

![image](https://github.com/user-attachments/assets/ce90a4c5-7642-40d7-8298-a62d9b9665ad)

### 5. Trigger Pesan Kursi
Trigger baru yang menandai kursi sebagai tidak tersedia ketika ditambahkan ke detail transaksi.

```sql
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
```

### 6. Trigger Kosongkan Kursi Setelah Film
Trigger untuk membebaskan kursi setelah film selesai, dengan mekanisme yang lebih efisien.

```sql
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
DELIMITER ;
```

Status kursi akan menjadi FALSE

![image](https://github.com/user-attachments/assets/b42cb384-a4cf-4e07-95c2-fc1961d36a59)


---

## 🧩 Stored Procedure

### 1. Top 3 Makanan Terlaris per Kategori
Mengembalikan 3 makanan dengan jumlah penjualan tertinggi di tiap kategori (minuman, popcorn, makanan berat, dll).

### 2. Film Paling Populer
Mengembalikan film dengan jumlah penonton terbanyak (berdasarkan transaksi tiket).

### 3. Pelanggan dengan Transaksi Terbanyak

Mengambil pelanggan dengan jumlah transaksi terbanyak sepanjang waktu.

### 4. Prosedur Transaksi Lengkap
Menyisipkan data ke tabel `transaksi`, `transaksi_makanan`, `promosi_transaksi` secara konsisten dan atomik (menggunakan transaksi SQL).

### 5. Studio Menjual Makanan Apa Saja
Mengembalikan daftar makanan yang tersedia di lokasi studio tertentu.

### 6. Studio Menayangkan Film Apa Saja
Mengembalikan daftar film yang sedang tayang oleh merk studio tertentu.

```
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
```

Input data yang diperlukan untuk testing untuk no 6-9

```
INSERT INTO FILM VALUES
('F001', 'Avengers: Endgame', 'Action', 180, 'Russo Brothers', '13+', 8.7, 'The final battle against Thanos.'),
('F002', 'Frozen II', 'Animation', 103, 'Chris Buck', 'SU', 7.2, 'Elsa goes on a journey.'),
('F003', 'Interstellar', 'Sci-Fi', 169, 'Christopher Nolan', '13+', 8.6, 'Journey through space and time.');

INSERT INTO LOKASI_STUDIO VALUES
('LS001', 'Jl. Sudirman No.1, Jakarta', '021123456', 'XXI'),
('LS002', 'Jl. Asia Afrika No.99, Bandung', '022987654', 'Cinepolis'),
('LS003', 'Jl. Gajah Mada No.22, Surabaya', '031112233', 'XXI');

INSERT INTO TEATER VALUES
('T001', 100, 'LS001'),  -- XXI Jakarta
('T002', 120, 'LS002'),  -- Cinepolis Bandung
('T003', 90,  'LS003');  -- XXI Surabaya

INSERT INTO JADWAL_TAYANG VALUES
('JDT001', '2025-06-16 14:00:00', 'F001', 'T001'),  -- Avengers @ XXI Jakarta
('JDT002', '2025-06-16 17:00:00', 'F002', 'T002'),  -- Frozen @ Cinepolis Bandung
('JDT003', '2025-06-16 20:00:00', 'F001', 'T003'),  -- Avengers @ XXI Surabaya
('JDT004', '2025-06-17 13:00:00', 'F003', 'T003');  -- Interstellar @ XXI Surabaya
```

Call procedure untuk menampilkan film yang ada di XXI

```
CALL get_film_by_merk_studio('XXI');
```

![image](https://github.com/user-attachments/assets/92a67403-9c06-4431-8f6b-b8b50662439a)

### 7. Teater Tempat Film Ditayangkan
Menentukan film tertentu ditayangkan di teater mana dalam satu studio.

```
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
```

Call Procedure untuk menampilkan teater tempat film F001 ditayangkan di lokasi L001

```
CALL teater_tempat_film_ditayangkan('F001', 'LS001');
```

![Screenshot 2025-06-16 201537](https://github.com/user-attachments/assets/6169767d-dbab-4fb4-9e81-ccbde8c90aa1)

### 8. Jadwal Tayang di Lokasi Tertentu
Menampilkan waktu tayang suatu film di lokasi tertentu.

```
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
```

Menampilkan jadwal film Avengers: Endgame di lokasi LS001

```
CALL jadwal_tayang_film_lokasi('Avengers: Endgame', 'LS001');
```

 ![Screenshot 2025-06-16 202028](https://github.com/user-attachments/assets/cb4dbe1c-16a3-49a4-98a7-6a36a971f892)

### 9. Film Tersedia Berdasarkan Tanggal dan Lokasi
Menyediakan daftar film yang tersedia pada tanggal dan lokasi studio yang dipilih.

```
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
```
Menampilkan film apa saja yang tayang pada 16 Juni 2025 di lokasi LS001

```
CALL film_tersedia_tanggal_lokasi('2025-06-16', 'LS001');
```

![Screenshot 2025-06-16 202239](https://github.com/user-attachments/assets/8c6ccf63-b1c9-4249-a1b7-df719b13fa48)

### 10. Pembatalan Transaksi
Menghapus transaksi dan rollback kursi, makanan, dan promosi yang digunakan.

### 11. Edit Transaksi (Pindah Kursi/Jadwal)
Mengubah detail transaksi, seperti kursi atau jadwal film, dengan validasi ketersediaan baru.

---

## 🗂️ Index

### 📁 Table: `Film`
- **Kolom:** `genre`, `rating_usia`, `sutradara`, `id_film`
- **Alasan Indexing:**
  - Kolom seperti `genre`, `rating_usia`, dan `sutradara` sering digunakan dalam pencarian oleh pengguna.
  - `id_film` sebagai kunci relasi antar tabel.
- **Jenis Indexing:**
  - `genre`, `rating_usia`, `sutradara`: **Dense Indexing**
  - `id_film`: **Sparse Indexing**

---

### 📁 Table: `Jadwal_Tayang`
- **Kolom:** `jadwal`, `film_id_film`
- **Alasan Indexing:**
  - `jadwal`: untuk pencarian jadwal tayang film.
  - `film_id_film`: untuk menampilkan seluruh jadwal dari satu film.
- **Jenis Indexing:** **Sparse Indexing**

---

### 📁 Table: `Kursi`
- **Kolom:** `row_kursi`, `column_kursi` (combined index: `idx_kursi(row_kursi, column_kursi)`)
- **Alasan Indexing:**
  - Untuk efisiensi pencarian ketersediaan kursi berdasarkan posisi.
- **Jenis Indexing:**
  - `row_kursi`: **Dense Indexing**
  - `column_kursi`: **Sparse Indexing** (dalam kombinasi)

---

### 📁 Table: `Lokasi_Studio`
- **Kolom:** `alamat_studio`, `merk_studio`
- **Alasan Indexing:**
  - Untuk pencarian berdasarkan lokasi atau nama studio yang panjang (VARCHAR/TEXT).
- **Jenis Indexing:** **Dense Indexing**

---

### 📁 Table: `Pelanggan`
- **Kolom:** `id_pelanggan`, `nama`
- **Alasan Indexing:**
  - Untuk pencarian cepat saat login, mengecek transaksi, atau status membership.
- **Jenis Indexing:** **Sparse Indexing**

---

### 📁 Table: `Transaksi`
- **Kolom:** `tanggal_transaksi`, `pelanggan_id_pelanggan`
- **Alasan Indexing:**
  - `tanggal_transaksi`: untuk filtering berdasarkan waktu transaksi
  - `pelanggan_id_pelanggan`: untuk query yang berkaitan dengan history pelanggan
- **Jenis Indexing:** **Sparse Indexing**

---

### 📁 Table: `Detail_Transaksi`
- **Kolom:** `transaksi_id_transaksi`, `kursi_id_kursi`
- **Alasan Indexing:**
  - `transaksi_id_transaksi`: untuk mengambil semua detail kursi dalam satu transaksi
  - `kursi_id_kursi`: untuk mengecek status kursi dan riwayat pemakaian
- **Jenis Indexing:** **Sparse Indexing**

---
