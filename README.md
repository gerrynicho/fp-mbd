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
Setiap transaksi sukses akan menambahkan poin ke akun pelanggan berdasarkan nilai transaksi.

### 5. Kursi Kosong saat Film Selesai
Trigger mengubah status kursi menjadi tersedia (`true`) setelah waktu selesai film.

### 6. Auto Kosongkan Kursi saat Dipesan
Saat pelanggan memesan, status kursi diubah menjadi tidak tersedia (`false`).

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
Mengembalikan daftar film yang sedang tayang di studio tertentu.

### 7. Teater Tempat Film Ditayangkan
Menentukan film tertentu ditayangkan di teater mana dalam satu studio.

### 8. Jadwal Tayang di Studio Tertentu
Menampilkan waktu tayang suatu film di studio tertentu.

### 9. Film Tersedia Berdasarkan Tanggal dan Lokasi
Menyediakan daftar film yang tersedia pada tanggal dan lokasi studio yang dipilih.

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
