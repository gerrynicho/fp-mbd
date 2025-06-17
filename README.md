
### Kelompok F04

| No | Nama                      | NRP         |
|----|---------------------------|-------------|
| 1  | Gerry Nicholas            | 5025231017  |
| 2  | Nicholas                  | 5025231031  |
| 3  | Imelda Alexis Jovita     | 5025231032  |
| 4  | Karla Vania Widjanarko   | 5025231123  |

# Table of Contents
- [Table of Contents](#table-of-contents)
- [PDM CDM](#pdm-cdm)
- [🎬 Bioskop Database Design – Fitur \& Indexing](#-bioskop-database-design--fitur--indexing)
  - [🧠 Function](#-function)
    - [1. Cek Membership Pelanggan](#1-cek-membership-pelanggan)
    - [2. Validasi Masa Berlaku Promosi](#2-validasi-masa-berlaku-promosi)
    - [3. Hitung Total Penggunaan Promosi](#3-hitung-total-penggunaan-promosi)
    - [4. Kalkulasi Harga Setelah Promo](#4-kalkulasi-harga-setelah-promo)
    - [5. Kalkulasi Harga Makanan dalam Keranjang](#5-kalkulasi-harga-makanan-dalam-keranjang)
    - [6. Cek Poin untuk Free Tiket](#6-cek-poin-untuk-free-tiket)
    - [7. Konversi Total Harga Menjadi Poin](#7-konversi-total-harga-menjadi-poin)
    - [8. Hitung Pajak](#8-hitung-pajak)
    - [9. Hitung Refund Pembatalan](#9-hitung-refund-pembatalan)
    - [10. Hitung Total Transaksi](#10-hitung-total-transaksi)
    - [11. Hitung Harga Kursi](#11-hitung-harga-kursi)
    - [12. Hitung Pelanggan](#12-hitung-pelanggan)
  - [⚡ Trigger](#-trigger)
    - [1. Promosi untuk 10 Orang Pertama per Hari](#1-promosi-untuk-10-orang-pertama-per-hari)
    - [2. Trigger Stok Menipis](#2-trigger-stok-menipis)
    - [3. Diskon Tambahan untuk Membership](#3-diskon-tambahan-untuk-membership)
    - [4. Tambah Poin saat Transaksi](#4-tambah-poin-saat-transaksi)
    - [5. Trigger Pesan Kursi](#5-trigger-pesan-kursi)
  - [🧩 Stored Procedure](#-stored-procedure)
    - [1. Top 3 Makanan Terlaris per Kategori](#1-top-3-makanan-terlaris-per-kategori)
    - [2. Film Paling Populer](#2-film-paling-populer)
    - [3. Pelanggan dengan Transaksi Terbanyak](#3-pelanggan-dengan-transaksi-terbanyak)
    - [4. Prosedur Transaksi Lengkap](#4-prosedur-transaksi-lengkap)
    - [5. Studio Menjual Makanan Apa Saja](#5-studio-menjual-makanan-apa-saja)
    - [6. Studio Menayangkan Film Apa Saja](#6-studio-menayangkan-film-apa-saja)
    - [7. Teater Tempat Film Ditayangkan](#7-teater-tempat-film-ditayangkan)
    - [8. Jadwal Tayang di Lokasi Tertentu](#8-jadwal-tayang-di-lokasi-tertentu)
    - [9. Film Tersedia Berdasarkan Tanggal dan Lokasi](#9-film-tersedia-berdasarkan-tanggal-dan-lokasi)
    - [10. Pembatalan Transaksi](#10-pembatalan-transaksi)
  - [🗂️ Index](#️-index)
    - [📁 Table: `Film`](#-table-film)
    - [📁 Table: `Jadwal_Tayang`](#-table-jadwal_tayang)
    - [📁 Table: `Kursi`](#-table-kursi)
    - [📁 Table: `Lokasi_Studio`](#-table-lokasi_studio)
    - [📁 Table: `Pelanggan`](#-table-pelanggan)
    - [📁 Table: `Transaksi`](#-table-transaksi)
    - [📁 Table: `Detail_Transaksi`](#-table-detail_transaksi)

# PDM CDM
**PDM**
![Manajemen_Tix ID_Physical_Export_MBD-2025-06-17_12-45](https://github.com/user-attachments/assets/c1034715-d5a9-4420-9eb1-a43fd4c03451)

# 🎬 Bioskop Database Design – Fitur & Indexing

## 🧠 Function

### 1. Cek Membership Pelanggan
Mengembalikan apakah pelanggan memiliki status membership berdasarkan ID pelanggan.

```sql
--
DELIMITER $$
CREATE FUNCTION cek_membership(p_id CHAR(5))
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE status BOOL;

    SELECT EXISTS (
        SELECT 1 
        FROM MEMBERSHIP 
        WHERE pelanggan_id_pelanggan = p_id
    ) INTO status;

    RETURN status;
END//
DELIMITER ;
```
```sql
SELECT cek_membership('P0001') AS status_membership;
SELECT cek_membership('P0025') AS status_membership;
```
![image](https://github.com/user-attachments/assets/33e0fa0f-e07a-4fe3-a601-c41f3187df41)

![image](https://github.com/user-attachments/assets/ee6db324-757c-4921-9882-f381c491b800)

### 2. Validasi Masa Berlaku Promosi
Mengecek apakah tanggal saat ini masih dalam rentang masa berlaku promosi.

```sql
DELIMITER $$
CREATE FUNCTION promosi_masih_berlaku(p_id CHAR(10))
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE status BOOL DEFAULT FALSE;

    SELECT 
        (CURDATE() BETWEEN tanggal_mulai AND tanggal_berakhir)
    INTO 
        status
    FROM 
        PROMOSI
    WHERE 
        id_promosi = p_id;

    RETURN IFNULL(status, FALSE);
END//
DELIMITER ;
```
```sql
SELECT promosi_masih_berlaku('PR001') AS masih_berlaku;
SELECT promosi_masih_berlaku('PR014') AS masih_berlaku;
```
![image](https://github.com/user-attachments/assets/028c2556-fe11-4b11-adba-c2bc6e8cb2a1)
![image](https://github.com/user-attachments/assets/55c40ed0-934a-4c5a-9265-a0bbf7595377)

![image](https://github.com/user-attachments/assets/e4d7fb4e-e2df-4c4b-afca-23608dbc2349)
![image](https://github.com/user-attachments/assets/e23894be-6350-4444-9f19-44003dff49e1)

### 3. Hitung Total Penggunaan Promosi
Mengembalikan total jumlah penggunaan promosi tertentu oleh semua pelanggan.

```sql
DELIMITER $$

CREATE FUNCTION total_penggunaan_promosi(p_id CHAR(10))
RETURNS INT
BEGIN
    DECLARE total INT DEFAULT 0;

    SELECT COUNT(*) 
    INTO total
    FROM PROMOSI_TRANSAKSI
    WHERE promosi_id_promosi = p_id;

    RETURN total;
END//
DELIMITER ;
```


menambah dummy data
```sql
INSERT INTO PROMOSI_TRANSAKSI VALUES
('TRX202506100002','PR014'),
('TRX202506110001','PR014'),
('TRX202506120001','PR014'),
('TRX202506130001','PR011');
```

```sql
SELECT total_penggunaan_promosi('PR014') AS jumlah_penggunaan;
SELECT total_penggunaan_promosi('PR011') AS jumlah_penggunaan;

```
![image](https://github.com/user-attachments/assets/800e00f8-78e4-4c92-9503-2a93579356e5)

![image](https://github.com/user-attachments/assets/b9a36bf8-f168-4a53-bff6-3286d8205989)

![image](https://github.com/user-attachments/assets/70d3f28a-5351-49e5-8260-55aef3d09f74)


### 4. Kalkulasi Harga Setelah Promo
Mengurangi harga awal dengan persentase atau nilai diskon dari promosi yang valid.

```sql
DELIMITER $$

CREATE FUNCTION harga_setelah_promo(p_id CHAR(10), harga_awal DECIMAL(10, 2))
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE diskon_persen DECIMAL(5,2);
    DECLARE minimum INT;
    DECLARE harga_akhir DECIMAL(10,2);

    -- Ambil diskon dan syarat minimum_pembelian dari promosi yang masih berlaku
    SELECT diskon, minimum_pembelian
    INTO diskon_persen, minimum
    FROM PROMOSI
    WHERE id_promosi = p_id
      AND CURDATE() BETWEEN tanggal_mulai AND tanggal_berakhir;

    -- Jika promosi tidak ditemukan atau tidak berlaku
    IF diskon_persen IS NULL OR minimum IS NULL THEN
        RETURN harga_awal;
    END IF;

    -- Jika harga tidak memenuhi minimum pembelian, tidak dapat diskon
    IF harga_awal < minimum THEN
        RETURN harga_awal;
    END IF;

    -- Hitung harga akhir setelah diskon
    SET harga_akhir = harga_awal - (harga_awal * (diskon_persen / 100));

    RETURN harga_akhir;
END//
DELIMITER ;

```
```sql
SELECT harga_setelah_promo('PR014', 50000) AS harga_setelah_diskon;
```
jika memenuhi semua syarat, maka harga akan di potong diskon
![image](https://github.com/user-attachments/assets/9caedac6-8c98-48b8-a711-a72598249365)
![image](https://github.com/user-attachments/assets/ec5fe462-d7ed-4735-8d12-cf86d419160e)

misalnya minimum pembelian tidka terpenuhi,
```sql
SELECT harga_setelah_promo('PR014', 10000) AS harga_setelah_diskon;
```
![image](https://github.com/user-attachments/assets/98ab5944-6d2f-4286-96d2-73b0e5b5a2c7)


### 5. Kalkulasi Harga Makanan dalam Keranjang
Menghitung total harga makanan berdasarkan kuantitas dan harga satuan masing-masing item dalam keranjang.

```sql

DELIMITER $$
CREATE FUNCTION total_harga_keranjang(p_transaksi CHAR(19))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(m.harga * tm.jumlah)
    INTO total
    FROM TRANSAKSI_MAKANAN tm
    JOIN MAKANAN m ON tm.makanan_id_makanan = m.id_makanan
    WHERE tm.transaksi_id_transaksi = p_transaksi;
    RETURN IFNULL(total, 0);
END//
DELIMITER ;
```
```sql
SELECT total_harga_keranjang('TRX202506100001');
SELECT total_harga_keranjang('TRX202506100002');

```
![image](https://github.com/user-attachments/assets/8e0d36ed-ad58-4430-ba22-29968924d826)
![image](https://github.com/user-attachments/assets/00b3d965-97ce-43dd-943a-9ac426ea73c7)

### 6. Cek Poin untuk Free Tiket
Mengecek jika poin pelanggan >= 100, maka tiket gratis akan diterapkan.

```sql
DELIMITER //

CREATE FUNCTION cek_poin_gratis_tiket(p_id CHAR(5))
RETURNS BOOLEAN
BEGIN
    DECLARE jumlah_poin INT;

    SELECT poin INTO jumlah_poin
    FROM MEMBERSHIP
    WHERE pelanggan_id_pelanggan = p_id;


    -- Jika pelanggan tidak memiliki membership, tidak bisa tiket gratis
    IF jumlah_poin IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Jika poin >= 100, tiket gratis
    IF jumlah_poin >= 100 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
//

DELIMITER ;

```
```sql
SELECT cek_poin_gratis_tiket('P0001') AS status_tiket_gratis;
```
![image](https://github.com/user-attachments/assets/0f4e4ef9-41d3-42bf-a25a-0561025e0df9)



### 7. Konversi Total Harga Menjadi Poin
Mengubah total harga transaksi menjadi poin, setiap Rp25.000 = 1 poin.


```sql
DELIMITER //
CREATE FUNCTION harga_ke_poin(total DECIMAL(10,2))
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE id_pelanggan CHAR(5);
    DECLARE punya_membership BOOL;

    -- Ambil total biaya dan id pelanggan dari transaksi
    SELECT total_biaya, pelanggan_id_pelanggan
    INTO total, id_pelanggan
    FROM TRANSAKSI
    WHERE id_transaksi = p_id_transaksi;

    -- Cek apakah pelanggan memiliki membership
    SELECT EXISTS (
        SELECT 1 FROM MEMBERSHIP WHERE pelanggan_id_pelanggan = id_pelanggan
    ) INTO punya_membership;

    -- Jika tidak punya membership, return 0 poin
    IF NOT punya_membership THEN
        RETURN 0;
    END IF;

    -- Hitung poin: setiap 25.000 = 1 poin
    RETURN FLOOR(total / 25000);
END;
//
DELIMITER ;

```
```sql
SELECT konversi_poin_dari_transaksi('TRX202506110001');
```
![image](https://github.com/user-attachments/assets/0dfc1a14-7b2b-4292-9c2d-8978665fa6e2)

![image](https://github.com/user-attachments/assets/49d94845-5c6b-40f8-b21a-4eb813d17979)


### 8. Hitung Pajak
Menambahkan pajak (misal 10%) dari subtotal transaksi.

```sql
DELIMITER $$
CREATE FUNCTION hitung_pajak(subtotal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN subtotal * 0.10;
END//
DELIMITER ;
```
```sql
SELECT hitung_pajak(100000); -- Hasil: 10000
```
![image](https://github.com/user-attachments/assets/4730e60b-5814-4f4a-beae-002c5b8e3eb4)

### 9. Hitung Refund Pembatalan
Menghitung nominal refund sesuai kebijakan (misal potongan 20% dari total).

```sql
DELIMITER $$
CREATE FUNCTION hitung_refund(total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN total * 0.80; -- Potongan 20%
END//
DELIMITER ;
```
```sql
SELECT hitung_refund(100000); -- Hasil: 80000
```
![image](https://github.com/user-attachments/assets/62819c35-9a26-4e7a-a65e-ab5ba29e9685)


### 10. Hitung Total Transaksi
Menjumlahkan subtotal, pajak, biaya admin, dan dikurangi diskon jika ada.

```sql
DELIMITER $$
CREATE FUNCTION hitung_total(subtotal DECIMAL(10,2), pajak DECIMAL(10,2), biaya_admin DECIMAL(10,2), diskon DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN subtotal + pajak + biaya_admin - diskon;
END//
DELIMITER ;
```
```sql
SELECT hitung_total(100000, 10000, 5000, 15000); -- Hasil: 100000
```
![image](https://github.com/user-attachments/assets/5ff4e8c1-d88b-4652-be7d-9555e73c0cfd)


### 11. Hitung Harga Kursi
Mengembalikan harga berdasarkan banyaknya kursi yang dipesan.

```sql
DELIMITER $$
CREATE FUNCTION harga_kursi(jumlah_kursi INT, harga_per_kursi DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN jumlah_kursi * harga_per_kursi;
END//
DELIMITER ;
```
```sql
SELECT harga_kursi(3, 45000); -- Hasil: 135000
```
![image](https://github.com/user-attachments/assets/06f6ced8-7f16-449c-8b50-fa670ebc4c0e)


---

### 12. Hitung Pelanggan
Menghitung jumlah pelanggan pada hari ini. 
```sql
-- HITUNG PELANGGAN HARI INI
DELIMITER $$

CREATE FUNCTION hitung_pelanggan_hari_ini(p_date DATE) 
RETURNS INTEGER  
DETERMINISTIC
BEGIN 
    DECLARE jumlah_pelanggan_hari_ini INT;

    SELECT COUNT(DISTINCT pelanggan_id_pelanggan)
    INTO jumlah_pelanggan_hari_ini
    FROM TRANSAKSI t
    WHERE DATE(t.tanggal_transaksi) = p_date;

    RETURN jumlah_pelanggan_hari_ini;
END $$

DELIMITER ;
```

Testing 
```
select hitung_pelanggan_hari_ini(CURDATE()) AS jumlah_pelanggan_hari_ini
```

Hasil
![WhatsApp Image 2025-06-17 at 12 08 37_a1f7c757](https://github.com/user-attachments/assets/4aebbe8a-5c0d-4d4a-a733-b6a14a6f75f1)



## ⚡ Trigger

### 1. Promosi untuk 10 Orang Pertama per Hari
Trigger untuk membatasi promosi hanya berlaku untuk 10 transaksi pertama pada hari tersebut.
```sql
DELIMITER $$
-- #1
-- Trigger untuk menambahkan promosi hanya jika pelanggan masuk 10 orang pertama
-- menurutku ini harus refactor buat bikin count jadi sistem variabel
CREATE TRIGGER trg_diskon_10_orang
BEFORE INSERT ON PROMOSI_TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE jumlah INTEGER DEFAULT 0;

    SET jumlah = hitung_pelanggan_hari_ini(CURDATE());
    IF jumlah <= 10 THEN
        SET NEW.promosi_id_promosi = 'PR010';
    END IF;
END $$

DELIMITER ;
```
![image|300](https://github.com/user-attachments/assets/5d0d9206-e410-4fe5-9251-525472ae8999)

<br>Testing<br>
```sql
select * from promosi_transaksi
```
![image](https://github.com/user-attachments/assets/8e2d3552-b0f9-4651-b7de-fa612b457404)
Promosi terganti jadi PR010

### 2. Trigger Stok Menipis
Mengirimkan notifikasi atau log jika stok makanan < ambang batas tertentu.
![image|300](https://github.com/user-attachments/assets/2496e5ff-9ce2-4647-bcca-0bbcdd51762e)
```sql
-- #2
-- trigger stok menipis [DONE]
DELIMITER $$

CREATE TRIGGER trg_low_stok
BEFORE UPDATE ON MAKANAN
FOR EACH ROW 
BEGIN 
    -- Error: stok tidak boleh negatif
    IF NEW.stok < 0 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id_makanan, 'ERROR', 'Stok tidak mencukupi', NOW());

        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Stok tidak mencukupi';

    -- Warning: stok kosong (update tetap dilakukan)
    ELSEIF NEW.stok = 0 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id_makanan, 'NOTICE', 'Stok kosong', NOW());
        -- No SIGNAL so update continues

    -- Notice: stok rendah (<= 5), update tetap dilakukan
    ELSEIF NEW.stok <= 5 THEN 
        INSERT INTO log_notifikasi (id_makanan, tipe_notif, pesan, waktu)
        VALUES (NEW.id_makanan, 'NOTICE', 'Stok rendah, tolong stok ulang', NOW());
        -- No SIGNAL so update continues
    END IF;
END$$

DELIMITER ;

```


Testing

<br><i>Untuk stok kurang dari 5</i> 
```sql
UPDATE makanan
SET stok = (SELECT stok FROM makanan WHERE id_makanan = 'M0001') - 6
WHERE id_makanan = 'M0001';
```
![image](https://github.com/user-attachments/assets/9354096e-f84e-4559-9cac-a357552bd2cc)

Hasil <br>

![image](https://github.com/user-attachments/assets/29a4fc57-90b5-4ff2-9291-605092faa03e)



<i>Untuk stok sama dengan 0</i> 
Testing <br>

```sql
UPDATE makanan
SET stok = (SELECT stok FROM makanan WHERE id_makanan = 'M0001') - 4
WHERE id_makanan = 'M0001';
```

Hasil <br>
![image](https://github.com/user-attachments/assets/1bed5aec-cee6-4761-9d7a-8a46b68e5011)


<i>Untuk stok kurang dari 0</i> 
Testing <br>
```sql
UPDATE makanan
SET stok = (SELECT stok FROM makanan WHERE id_makanan = 'M0001') - 2
WHERE id_makanan = 'M0001';
```

Hasil <br>
![image](https://github.com/user-attachments/assets/4f43d311-b3a3-469d-860a-cd9b4961d635)



### 3. Diskon Tambahan untuk Membership
```sql
Trigger otomatis menambahkan diskon tambahan jika pelanggan adalah member aktif.
-- #3
-- triger diskon tambahan ketika user ada membership [UPDATED]
DELIMITER $$
CREATE TRIGGER trg_diskon_membership
BEFORE INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN 
    DECLARE diskon DECIMAL(10,2) DEFAULT 0;
    DECLARE subtotal DECIMAL(10,2);
    
    -- If customer has membership, apply 10% discount
    IF cek_membership(NEW.pelanggan_id_pelanggan) THEN
        -- Get the original total_biaya
        SET subtotal = NEW.total_biaya;
        
        -- Calculate discount (10%)
        SET diskon = subtotal * 0.1;
        
        -- Apply the discount to total_biaya
        SET NEW.total_biaya = NEW.total_biaya - diskon;
    END IF;
END $$
DELIMITER ;
```
![image](https://github.com/user-attachments/assets/0064f15e-1c3f-4395-b8c7-41a23dfd1d9a)
![image](https://github.com/user-attachments/assets/7dd36021-a559-4b13-9cfd-a8ed815f80cd)




### 4. Tambah Poin saat Transaksi
Setiap transaksi sukses akan menambahkan poin ke akun pelanggan berdasarkan nilai transaksi. Tiap 10.000 akan menambahkan 1 poin.

```
DELIMITER $$

CREATE TRIGGER tambah_poin_setelah_transaksi
AFTER INSERT ON TRANSAKSI
FOR EACH ROW
BEGIN
    DECLARE poin_tambahan INT;

    -- Hitung poin tambahan dari total_biaya (dibagi 10.000)
    SET poin_tambahan = FLOOR(NEW.total_biaya / 10000);

    -- Update poin pelanggan pada tabel MEMBERSHIP
    UPDATE MEMBERSHIP
    SET poin = poin + poin_tambahan
    WHERE pelanggan_id_pelanggan = NEW.pelanggan_id_pelanggan;
END$$

DELIMITER ;
```

Input data yang diperluhkan untuk testing

```sql
INSERT INTO PELANGGAN VALUES
('P001', 'Andi', '08123456789', 'pass123');
INSERT INTO MEMBERSHIP VALUES
('M001', 'andi@email.com', 'L', '2000-01-01', 0, 'P001');
INSERT INTO LOKASI_STUDIO VALUES
('LS001', 'Jl. Sudirman No.1', '021111222', 'XXI');

INSERT INTO TEATER VALUES
('T001', 100, 'LS001');
INSERT INTO FILM VALUES
('F001', 'Avengers: Endgame', 'Action', 180, 'Russo Brothers', '13+', 8.7, 'Final battle.');

INSERT INTO JADWAL_TAYANG VALUES
('JDT001', '2025-06-16 14:00:00', 'F001', 'T001');
```

pemicu trigger

```
INSERT INTO TRANSAKSI (
    id_transaksi, total_biaya, biaya_pajak, tanggal_transaksi, 
    pelanggan_id_pelanggan, jadwal_tayang_id_tayang, teater_id_teater
) VALUES (
    'TRX000000000000001', 45000, 5000, NOW(), 
    'P001', 'JDT001', 'T001'
);
```

P0001 akan mempunyai 4 poin karena dia memiliki membership dan mengeluarkan biaya lebih dari 10.000

Cek

```sql
SELECT * FROM MEMBERSHIP WHERE id_membership = 'M001';
```

![Screenshot 2025-06-16 210922](https://github.com/user-attachments/assets/39d0dc43-c677-41f0-8b2c-57e2260c9136)

### 5. Trigger Pesan Kursi
Trigger baru yang menandai kursi sebagai tidak tersedia ketika ditambahkan ke detail transaksi.

```
DELIMITER $$

CREATE TRIGGER pesan_kursi_tidak_tersedia
AFTER INSERT ON DETAIL_TRANSAKSI
FOR EACH ROW
BEGIN
    UPDATE KURSI
    SET sedia = FALSE
    WHERE id_kursi = NEW.kursi_id_kursi;
END$$

DELIMITER ;
```

Input data untuk testing

```
INSERT INTO KURSI (id_kursi, row_kursi, column_kursi, sedia, teater_id_teater)
VALUES ('K001', 'A', 1, TRUE, 'T001');
INSERT INTO TRANSAKSI (
    id_transaksi, total_biaya, biaya_pajak, tanggal_transaksi, 
    pelanggan_id_pelanggan, jadwal_tayang_id_tayang, teater_id_teater
) VALUES (
    'TRX000000000000002', 50000, 5000, NOW(), 
    'P001', 'JDT001', 'T001'
);
```

pemicu trigger

```
INSERT INTO DETAIL_TRANSAKSI (id_detail_transaksi, transaksi_id_transaksi, kursi_id_kursi)
VALUES ('DT001', 'TRX000000000000002', 'K001');
```

cek

```
SELECT id_kursi, sedia FROM KURSI WHERE id_kursi = 'K001';
```

![Screenshot 2025-06-16 211235](https://github.com/user-attachments/assets/d2b5147e-50f5-46fb-8331-b77e27de180f)

## 🧩 Stored Procedure

### 1. Top 3 Makanan Terlaris per Kategori
Mengembalikan 3 makanan dengan jumlah penjualan tertinggi di tiap kategori (minuman, popcorn, makanan berat, dll).

```
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
```


### 2. Film Paling Populer
Mengembalikan film dengan jumlah penonton terbanyak (berdasarkan transaksi tiket).

```
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
```

### 3. Pelanggan dengan Transaksi Terbanyak

Mengambil pelanggan dengan jumlah transaksi terbanyak sepanjang waktu.

```
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
```

### 4. Prosedur Transaksi Lengkap
Menyisipkan data ke tabel `transaksi`, `transaksi_makanan`, `promosi_transaksi` secara konsisten dan atomik (menggunakan transaksi SQL).

```
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
```

### 5. Studio Menjual Makanan Apa Saja
Mengembalikan daftar makanan yang tersedia di lokasi studio tertentu.

```
DELIMITER $$
CREATE PROCEDURE lokasi_studio_makanan()
BEGIN
    SELECT ls.id_lokasi_studio, ls.merk_studio, m.id_makanan, m.nama, m.harga
    FROM LOKASI_STUDIO ls
    JOIN MAKANAN_LOKASI_STUDIO mls ON ls.id_lokasi_studio = mls.lokasi_studio_id_lokasi_studio
    JOIN MAKANAN m ON mls.makanan_id_makanan = m.id_makanan;
END $$
DELIMITER ;
```

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

Call Procedure untuk menampilkan teater tempat film F001 ditayangkan di lokasi LS001

```
CALL teater_tempat_film_ditayangkan('F001', 'LS001');
```

![Screenshot 2025-06-16 201537](https://github.com/user-attachments/assets/6169767d-dbab-4fb4-9e81-ccbde8c90aa1)

### 8. Jadwal Tayang di Lokasi Tertentu
Menampilkan waktu tayang suatu film di lokasi tertentu.

```sql
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

```sql
CALL jadwal_tayang_film_lokasi('Avengers: Endgame', 'LS001');
```

 ![Screenshot 2025-06-16 202028](https://github.com/user-attachments/assets/cb4dbe1c-16a3-49a4-98a7-6a36a971f892)

### 9. Film Tersedia Berdasarkan Tanggal dan Lokasi
Menyediakan daftar film yang tersedia pada tanggal dan lokasi studio yang dipilih.

```sql
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

```sql
CALL film_tersedia_tanggal_lokasi('2025-06-16', 'LS001');
```

![Screenshot 2025-06-16 202239](https://github.com/user-attachments/assets/8c6ccf63-b1c9-4249-a1b7-df719b13fa48)

### 10. Pembatalan Transaksi
Menghapus transaksi dan rollback kursi, makanan, dan promosi yang digunakan.
```sql
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
```
**Insertion**
```sql
-- 1. Lokasi Studio
INSERT INTO LOKASI_STUDIO (id_lokasi_studio, alamat_studio, no_telp, merk_studio)
VALUES ('L001', 'Jl. Studio 1', '021123456', 'CineX');

-- 2. Teater
INSERT INTO TEATER (id_teater, jumlah_kursi_tersedia, lokasi_studio_id_lokasi_studio)
VALUES ('T001', 100, 'L001');

-- 3. Kursi
INSERT INTO KURSI (id_kursi, row_kursi, column_kursi, harga_kursi, sedia, teater_id_teater)
VALUES 
('K001', 'A', 1, 50000, FALSE, 'T001'),
('K002', 'A', 2, 50000, FALSE, 'T001'),
('K003', 'A', 3, 50000, TRUE, 'T001');

-- 4. Pelanggan
INSERT INTO PELANGGAN (id_pelanggan, nama, no_telepon, pass)
VALUES ('P001', 'John Doe', '081234567890', 'secret');

-- 5. Film
INSERT INTO FILM (id_film, judul_film, genre, durasi, sutradara, rating_usia, rating_film, sinopsis)
VALUES ('F001', 'Test Movie', 'Action', 120, 'Director', '13+', 8.5, 'An action-packed film.');

-- 6. Jadwal Tayang
INSERT INTO JADWAL_TAYANG (id_tayang, jadwal, film_id_film, teater_id_teater)
VALUES ('J001', '2025-06-17 18:00:00', 'F001', 'T001');

-- 7. Transaksi
INSERT INTO TRANSAKSI (id_transaksi, total_biaya, tanggal_transaksi, pelanggan_id_pelanggan, jadwal_tayang_id_tayang, teater_id_teater)
VALUES ('TRX0001', 100000, NOW(), 'P001', 'J001', 'T001');

-- 8. Detail Transaksi
INSERT INTO DETAIL_TRANSAKSI (id_detail_transaksi, transaksi_id_transaksi, kursi_id_kursi)
VALUES 
('DT001', 'TRX0001', 'K001'),
('DT002', 'TRX0001', 'K002');

-- 9. Kursi Jadwal
INSERT INTO KURSI_JADWAL_TAYANG (kursi_id_kursi, jadwal_tayang_id_tayang)
VALUES 
('K001', 'J001'),
('K002', 'J001');
```

**Sebelum pembatalan**
![image](https://github.com/user-attachments/assets/a9c16666-b4ea-473b-a8fa-381fc7b64204)
![image](https://github.com/user-attachments/assets/3ff39dc6-6d4a-40fb-b4c4-e8c88bf38ffb)

**Pembatalan**
```sql
CALL pembatalan_transaksi('TRX0001');
```

**Sesudah pembatalan**
![image](https://github.com/user-attachments/assets/ac899ce0-bf0b-45e0-8708-67aa1234db84)
![image](https://github.com/user-attachments/assets/493fc9af-808e-4f54-ae05-342581be8657)






## 🗂️ Index

### 📁 Table: `Film`
- **Kolom:** `genre`, `rating_usia`, `sutradara`, `id_film`
- **Alasan Indexing:**
  - Kolom seperti `genre`, `rating_usia`, dan `sutradara` sering digunakan dalam pencarian oleh pengguna.
  - `id_film` sebagai kunci relasi antar tabel.
- **Jenis Indexing:**
  - `genre`, `rating_usia`, `sutradara`: **Dense Indexing**
  - `id_film`: **Sparse Indexing**
 
```sql
ALTER TABLE FILM
    ADD INDEX idx_id_film(id_film),
    ADD INDEX idx_genre(genre),
    ADD INDEX idx_rating_usia(rating_usia),
    ADD INDEX idx_rating_film(rating_film);
```

---

### 📁 Table: `Jadwal_Tayang`
- **Kolom:** `jadwal`, `film_id_film`
- **Alasan Indexing:**
  - `jadwal`: untuk pencarian jadwal tayang film.
  - `film_id_film`: untuk menampilkan seluruh jadwal dari satu film.
- **Jenis Indexing:** **Sparse Indexing**

```sql
ALTER TABLE JADWAL_TAYANG
    ADD INDEX idx_id_tayang(id_tayang),
    ADD INDEX idx_id_film_jadwal(film_id_film),
    ADD INDEX idx_jadwal(jadwal);
```

---

### 📁 Table: `Kursi`
- **Kolom:** `row_kursi`, `column_kursi` (combined index: `idx_kursi(row_kursi, column_kursi)`)
- **Alasan Indexing:**
  - Untuk efisiensi pencarian ketersediaan kursi berdasarkan posisi.
- **Jenis Indexing:**
  - `row_kursi`: **Dense Indexing**
  - `column_kursi`: **Sparse Indexing** (dalam kombinasi)

```sql
ALTER TABLE KURSI
    ADD INDEX idx_kursi(row_kursi, column_kursi);
```

---

### 📁 Table: `Lokasi_Studio`
- **Kolom:** `alamat_studio`, `merk_studio`
- **Alasan Indexing:**
  - Untuk pencarian berdasarkan lokasi atau nama studio yang panjang (VARCHAR/TEXT).
- **Jenis Indexing:** **Dense Indexing**

```sql
ALTER TABLE LOKASI_STUDIO
    ADD INDEX idx_alamat(alamat_studio),
    ADD INDEX idx_merk_studio(merk_studio);
```

---

### 📁 Table: `Pelanggan`
- **Kolom:** `id_pelanggan`, `nama`
- **Alasan Indexing:**
  - Untuk pencarian cepat saat login, mengecek transaksi, atau status membership.
- **Jenis Indexing:** **Sparse Indexing**

```sql
ALTER TABLE PELANGGAN
    ADD INDEX idx_id_pelanggan(id_pelanggan),
    ADD INDEX idx_nama(nama);
```

---

### 📁 Table: `Transaksi`
- **Kolom:** `tanggal_transaksi`, `pelanggan_id_pelanggan`
- **Alasan Indexing:**
  - `tanggal_transaksi`: untuk filtering berdasarkan waktu transaksi
  - `pelanggan_id_pelanggan`: untuk query yang berkaitan dengan history pelanggan
- **Jenis Indexing:** **Sparse Indexing**

```sql
ALTER TABLE TRANSAKSI
    ADD INDEX idx_tanggal_transaksi(tanggal_transaksi),
    ADD INDEX idx_pelanggan(pelanggan_id_pelanggan);
```

---

### 📁 Table: `Detail_Transaksi`
- **Kolom:** `transaksi_id_transaksi`, `kursi_id_kursi`
- **Alasan Indexing:**
  - `transaksi_id_transaksi`: untuk mengambil semua detail kursi dalam satu transaksi
  - `kursi_id_kursi`: untuk mengecek status kursi dan riwayat pemakaian
- **Jenis Indexing:** **Sparse Indexing**

```sql
ALTER TABLE DETAIL_TRANSAKSI
    ADD INDEX idx_transaksi_detail(transaksi_id_transaksi),
    ADD INDEX idx_kursi_detail(kursi_id_kursi);
```
---
