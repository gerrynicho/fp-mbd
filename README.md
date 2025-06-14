# Table of Contents
- [Table of Contents](#table-of-contents)
- [🎬 Bioskop Database Design – Fitur \& Indexing](#-bioskop-database-design--fitur--indexing)
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
    - [5. Kursi Kosong saat Film Selesai](#5-kursi-kosong-saat-film-selesai)
    - [6. Auto Kosongkan Kursi saat Dipesan](#6-auto-kosongkan-kursi-saat-dipesan)
  - [🧩 Stored Procedure](#-stored-procedure)
    - [1. Top 3 Makanan Terlaris per Kategori](#1-top-3-makanan-terlaris-per-kategori)
    - [2. Film Paling Populer](#2-film-paling-populer)
    - [3. Pelanggan dengan Transaksi Terbanyak](#3-pelanggan-dengan-transaksi-terbanyak)
    - [4. Prosedur Transaksi Lengkap](#4-prosedur-transaksi-lengkap)
    - [5. Studio Menjual Makanan Apa Saja](#5-studio-menjual-makanan-apa-saja)
    - [6. Studio Menayangkan Film Apa Saja](#6-studio-menayangkan-film-apa-saja)
    - [7. Teater Tempat Film Ditayangkan](#7-teater-tempat-film-ditayangkan)
    - [8. Jadwal Tayang di Studio Tertentu](#8-jadwal-tayang-di-studio-tertentu)
    - [9. Film Tersedia Berdasarkan Tanggal dan Lokasi](#9-film-tersedia-berdasarkan-tanggal-dan-lokasi)
    - [10. Pembatalan Transaksi](#10-pembatalan-transaksi)
    - [11. Edit Transaksi (Pindah Kursi/Jadwal)](#11-edit-transaksi-pindah-kursijadwal)
  - [🗂️ Index](#️-index)
    - [📁 Table: `Film`](#-table-film)
    - [📁 Table: `Jadwal_Tayang`](#-table-jadwal_tayang)
    - [📁 Table: `Kursi`](#-table-kursi)
    - [📁 Table: `Lokasi_Studio`](#-table-lokasi_studio)
    - [📁 Table: `Pelanggan`](#-table-pelanggan)
  
# 🎬 Bioskop Database Design – Fitur & Indexing

## 🧠 Function

### 1. Cek Membership Pelanggan
Mengembalikan apakah pelanggan memiliki status membership berdasarkan ID pelanggan.

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

### 5. Kursi Kosong saat Film Selesai
Trigger mengubah status kursi menjadi tersedia (`true`) setelah waktu selesai film.

### 6. Auto Kosongkan Kursi saat Dipesan
Saat pelanggan memesan, status kursi diubah menjadi tidak tersedia (`false`).

```sql
DELIMITER $$

CREATE TRIGGER kosongkan_kursi_saat_dipesan
AFTER INSERT ON KURSI_JADWAL_TAYANG
FOR EACH ROW
BEGIN
    UPDATE KURSI
    SET sedia = FALSE
    WHERE id_kursi = NEW.kursi_id_kursi;
END$$

DELIMITER ;
```

Data yang diperlukan untuk testing

```sql
INSERT INTO KURSI (id_kursi, row_kursi, column_kursi, sedia, transaksi_id_transaksi)
VALUES ('K001', 'A', 1, TRUE, 'TRX000000000000001');
INSERT INTO FILM (
    id_film, judul_film, genre, durasi, sutradara, rating_usia, rating_film, sinopsis
) VALUES (
    'F0001', 'Petualangan Si Kancil', 'Animasi', 90, 'Agus Salim', 'Semua Umur', 8.5, 'Cerita seru tentang petualangan seekor kancil menyelamatkan hutan.'
);
INSERT INTO LOKASI_STUDIO (
    id_lokasi_studio, alamat_studio, no_telp, merk_studio
) VALUES (
    'L0001', 'Jl. Sudirman No. 99, Jakarta', '021888999', 'XXI Plaza'
);
INSERT INTO TEATER (
    id_teater, jumlah_kursi_tersedia, lokasi_studio_id_lokasi_studio
) VALUES (
    'T0001', 100, 'L0001'
);
INSERT INTO JADWAL_TAYANG (id_tayang, jadwal, film_id_film, teater_id_teater)
VALUES ('JT00001', '2025-06-14 15:00:00', 'F0001', 'T0001');
```

Testing

```sql
INSERT INTO KURSI_JADWAL_TAYANG (kursi_id_kursi, jadwal_tayang_id_tayang)
VALUES ('K001', 'JT00001');
```

Cek

```sql
SELECT id_kursi, sedia
FROM KURSI
WHERE id_kursi = 'K001';
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

CREATE PROCEDURE studio_menayangkan_film_apa_saja(
    IN merk_studio_input VARCHAR(30)
)
BEGIN
    SELECT DISTINCT
        F.id_film,
        F.judul_film,
        F.genre,
        F.durasi,
        F.rating_usia,
        F.rating_film,
        L.merk_studio,
        L.alamat_studio
    FROM JADWAL_TAYANG JT
    JOIN TEATER T ON JT.teater_id_teater = T.id_teater
    JOIN LOKASI_STUDIO L ON T.lokasi_studio_id_lokasi_studio = L.id_lokasi_studio
    JOIN FILM F ON JT.film_id_film = F.id_film
    WHERE L.merk_studio = merk_studio_input
    ORDER BY F.judul_film;
END$$

DELIMITER ;
```

Input data yang diperlukan untuk testing

```
INSERT INTO LOKASI_STUDIO VALUES
('L001', 'Jl. Sudirman No.1, Jakarta', '0211234567', 'XXI'),
('L002', 'Jl. Diponegoro No.5, Bandung', '0227654321', 'Cineplex');

INSERT INTO TEATER VALUES
('T001', 100, 'L001'),
('T002', 80, 'L001'),
('T003', 120, 'L002');

INSERT INTO FILM VALUES
('F001', 'Avengers: Endgame', 'Action', 180, 'Russo Brothers', '13+', 8.9, 'Pertarungan akhir para Avengers.'),
('F002', 'Finding Dory', 'Animation', 100, 'Andrew Stanton', 'SU', 8.0, 'Dory mencari keluarganya yang hilang.'),
('F003', 'Inception', 'Sci-Fi', 148, 'Christopher Nolan', '17+', 8.8, 'Petualangan di dunia mimpi.');

INSERT INTO JADWAL_TAYANG VALUES
('J000001', '2025-06-15 14:00:00', 'F001', 'T001'),
('J000002', '2025-06-15 17:00:00', 'F002', 'T001'),
('J000003', '2025-06-15 19:00:00', 'F003', 'T003'),
('J000004', '2025-06-16 13:00:00', 'F001', 'T002')
('J000005', '2025-06-16 14:00:00', 'F001', 'T001'); 
```

Call procedure untuk menampilkan film yang ada di XXI

```
CALL studio_menayangkan_film_apa_saja('XXI');
```

![image](https://github.com/user-attachments/assets/7218a66e-c037-4c42-b460-71dbd4af9fab)

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

Input data yang diperlukan untuk testing

```
INSERT INTO LOKASI_STUDIO VALUES
('L001', 'Jl. Sudirman No.1, Jakarta', '0211234567', 'XXI'),
('L002', 'Jl. Diponegoro No.5, Bandung', '0227654321', 'Cineplex');

INSERT INTO TEATER VALUES
('T001', 100, 'L001'),
('T002', 80, 'L001'),
('T003', 120, 'L002');

INSERT INTO FILM VALUES
('F001', 'Avengers: Endgame', 'Action', 180, 'Russo Brothers', '13+', 8.9, 'Pertarungan akhir para Avengers.'),
('F002', 'Finding Dory', 'Animation', 100, 'Andrew Stanton', 'SU', 8.0, 'Dory mencari keluarganya yang hilang.'),
('F003', 'Inception', 'Sci-Fi', 148, 'Christopher Nolan', '17+', 8.8, 'Petualangan di dunia mimpi.');

INSERT INTO JADWAL_TAYANG VALUES
('J000001', '2025-06-15 14:00:00', 'F001', 'T001'),
('J000002', '2025-06-15 17:00:00', 'F002', 'T001'),
('J000003', '2025-06-15 19:00:00', 'F003', 'T003'),
('J000004', '2025-06-16 13:00:00', 'F001', 'T002')
('J000005', '2025-06-16 14:00:00', 'F001', 'T001'); 
```

Call Procedure untuk menampilkan teater tempat film F001 ditayangkan di lokasi L001

```
CALL teater_tempat_film_ditayangkan('F001', 'L001');
```

![image](https://github.com/user-attachments/assets/f8d51a99-6939-4bb8-a4b5-4677d08943da)


### 8. Jadwal Tayang di Studio Tertentu
Menampilkan waktu tayang suatu film di lokasi studio tertentu pada tanggal tertentu.

```
DELIMITER $$

CREATE PROCEDURE jadwal_tayang_film_studio_tanggal(
    IN id_film CHAR(5),
    IN id_lokasi_studio CHAR(5),
    IN tanggal_tayang DATE
)
BEGIN
    SELECT 
        JT.id_tayang,
        F.judul_film,
        T.id_teater,
        L.alamat_studio,
        JT.jadwal
    FROM JADWAL_TAYANG JT
    JOIN FILM F ON JT.film_id_film = F.id_film
    JOIN TEATER T ON JT.teater_id_teater = T.id_teater
    JOIN LOKASI_STUDIO L ON T.lokasi_studio_id_lokasi_studio = L.id_lokasi_studio
    WHERE F.id_film = id_film
      AND L.id_lokasi_studio = id_lokasi_studio
      AND DATE(JT.jadwal) = tanggal_tayang
    ORDER BY JT.jadwal ASC;
END$$

DELIMITER ;
```

Input data yang diperlukan untuk testing

```
INSERT INTO LOKASI_STUDIO VALUES
('L001', 'Jl. Sudirman No.1, Jakarta', '0211234567', 'XXI'),
('L002', 'Jl. Diponegoro No.5, Bandung', '0227654321', 'Cineplex');

INSERT INTO TEATER VALUES
('T001', 100, 'L001'),
('T002', 80, 'L001'),
('T003', 120, 'L002');

INSERT INTO FILM VALUES
('F001', 'Avengers: Endgame', 'Action', 180, 'Russo Brothers', '13+', 8.9, 'Pertarungan akhir para Avengers.'),
('F002', 'Finding Dory', 'Animation', 100, 'Andrew Stanton', 'SU', 8.0, 'Dory mencari keluarganya yang hilang.'),
('F003', 'Inception', 'Sci-Fi', 148, 'Christopher Nolan', '17+', 8.8, 'Petualangan di dunia mimpi.');

INSERT INTO JADWAL_TAYANG VALUES
('J000001', '2025-06-15 14:00:00', 'F001', 'T001'),
('J000002', '2025-06-15 17:00:00', 'F002', 'T001'),
('J000003', '2025-06-15 19:00:00', 'F003', 'T003'),
('J000004', '2025-06-16 13:00:00', 'F001', 'T002')
('J000005', '2025-06-16 14:00:00', 'F001', 'T001'); 
```

Call procedure untuk jadwal dari film F001 di lokasi L001 pada tanggal 2025-06-16

```
CALL jadwal_tayang_film_studio_tanggal('F001', 'L001', '2025-06-16');
```

![image](https://github.com/user-attachments/assets/f2029600-5357-4305-9e51-22491453e910)

### 9. Film Tersedia Berdasarkan Tanggal dan Lokasi
Menyediakan daftar film yang tersedia pada tanggal dan lokasi studio yang dipilih.

```
DELIMITER $$

CREATE PROCEDURE film_tersedia_berdasarkan_tanggal_lokasi(
    IN tanggal_pilih DATE,
    IN lokasi_pilih CHAR(5)
)
BEGIN
    SELECT 
        F.id_film,
        F.judul_film,
        F.genre,
        F.durasi,
        F.sutradara,
        F.rating_usia,
        F.rating_film,
        F.sinopsis,
        JT.jadwal
    FROM JADWAL_TAYANG JT
    JOIN FILM F ON JT.film_id_film = F.id_film
    JOIN TEATER T ON JT.teater_id_teater = T.id_teater
    WHERE DATE(JT.jadwal) = tanggal_pilih
      AND T.lokasi_studio_id_lokasi_studio = lokasi_pilih
    ORDER BY JT.jadwal ASC;
END$$

DELIMITER ;
```

Input data yang diperlukan untuk testing

```
INSERT INTO LOKASI_STUDIO VALUES
('L001', 'Jl. Sudirman No.1, Jakarta', '0211234567', 'XXI'),
('L002', 'Jl. Diponegoro No.5, Bandung', '0227654321', 'Cineplex');

INSERT INTO TEATER VALUES
('T001', 100, 'L001'),
('T002', 80, 'L001'),
('T003', 120, 'L002');

INSERT INTO FILM VALUES
('F001', 'Avengers: Endgame', 'Action', 180, 'Russo Brothers', '13+', 8.9, 'Pertarungan akhir para Avengers.'),
('F002', 'Finding Dory', 'Animation', 100, 'Andrew Stanton', 'SU', 8.0, 'Dory mencari keluarganya yang hilang.'),
('F003', 'Inception', 'Sci-Fi', 148, 'Christopher Nolan', '17+', 8.8, 'Petualangan di dunia mimpi.');

INSERT INTO JADWAL_TAYANG VALUES
('J000001', '2025-06-15 14:00:00', 'F001', 'T001'),
('J000002', '2025-06-15 17:00:00', 'F002', 'T001'),
('J000003', '2025-06-15 19:00:00', 'F003', 'T003'),
('J000004', '2025-06-16 13:00:00', 'F001', 'T002')
('J000005', '2025-06-16 14:00:00', 'F001', 'T001'); 
```

Call procedure untuk film yang tayang di L001 pada tanggal 2025-06-15

```
CALL film_tersedia_berdasarkan_tanggal_lokasi('2025-06-15', 'L001');
```

![image](https://github.com/user-attachments/assets/574e8423-d675-40d6-b563-7766871b226b)

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
- **Kolom:** `row`, `number` (combined index: `idx_kursi(row, number)`)
- **Alasan Indexing:**
  - Untuk efisiensi pencarian ketersediaan kursi berdasarkan posisi.
- **Jenis Indexing:**
  - `row`: **Dense Indexing**
  - `number`: **Sparse Indexing** (dalam kombinasi)

---

### 📁 Table: `Lokasi_Studio`
- **Kolom:** `alamat`, `nama_studio`
- **Alasan Indexing:**
  - Untuk pencarian berdasarkan lokasi atau nama studio yang panjang (VARCHAR/TEXT).
- **Jenis Indexing:** **Dense Indexing**

---

### 📁 Table: `Pelanggan`
- **Kolom:** `id_pelanggan`
- **Alasan Indexing:**
  - Untuk pencarian cepat saat login, mengecek transaksi, atau status membership.
- **Jenis Indexing:** **Sparse Indexing**

---
