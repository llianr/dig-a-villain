# PANDUAN PASANG & PUBLISH — DIG A VILLAIN!

Semua kode sudah jadi. Kamu hanya perlu melakukan langkah di Roblox Studio ini (±20–30 menit).
File dalam paket ini:
- `ServerMain.lua` — seluruh logika server (dunia, galian, villain, home, toko, gift, perk creator)
- `ClientMain.lua` — seluruh tampilan pemain (HUD, banner, koleksi, toko, panel creator)
- `thumbnail-1920x1080.png` — thumbnail utama (sudah ada judulnya)
- `icon-512.png` — ikon game

## Langkah 1 — Buat tempat baru di Studio
1. Buka **Roblox Studio**, login pakai akunmu.
2. Klik **New** → pilih template **Baseplate**.
3. Di panel **Explorer** (kanan), hapus part **Baseplate** dan **SpawnLocation** bawaan (game ini membangun tanah & spawn-nya sendiri). Sisakan folder `Workspace` kosong tidak apa-apa.

## Langkah 2 — Tempel kode server
1. Di Explorer, arahkan ke **ServerScriptService** → klik tanda **+** → pilih **Script**.
2. Buka script itu, hapus semua isinya, lalu **paste seluruh isi file `ServerMain.lua`**.
3. Di bagian paling atas ada blok `CONFIG` — isi dua hal:
   - `OwnerUserId` = UserID Roblox kamu (angka). Cara melihatnya: buka profilmu di roblox.com — alamatnya berbentuk `roblox.com/users/<USERID>/profile`. Angka itulah UserID-mu. Tanpa ini perk Creator tidak aktif.
   - `CreatorName` = nama panggilanmu yang mau ditampilkan di patung & pengumuman (bebas).

## Langkah 3 — Tempel kode client
1. Di Explorer, buka **StarterPlayer → StarterPlayerScripts** → klik **+** → pilih **LocalScript**.
2. Hapus isinya, **paste seluruh isi file `ClientMain.lua`**.

## Langkah 4 — Tes dulu (Play)
1. Tekan **Play (F5)**. Kamu akan spawn di plaza; ladang galian ada di depan (zona tanah berwarna).
2. Coba: dekati gundukan tanah → pencet **E** untuk menggali → villain muncul.
3. Coba buka **Toko Cakar** (stand kayu di plaza / tombol Toko), panel **Koleksi**, dan pajang villain dari panel Koleksi — villain-nya akan berdiri di home-mu (home ditandai papan "Home <namamu>", lokasinya melingkar di pinggir map).
4. Kalau ada tulisan error merah di panel **Output**, screenshot dan kirim ke Pip — jangan diteruskan dulu.
5. Catatan: di Studio, progres (koin/koleksi) TIDAK tersimpan permanen — itu normal. Penyimpanan (DataStore) baru aktif setelah publish + Langkah 6 nomor 3.

## Langkah 5 — Publish game
1. **File → Publish to Roblox As…** → beri nama **DIG A VILLAIN!** → **Create**.
2. Tempel deskripsi game (teks lengkap ada di bagian bawah panduan ini).
3. Jadikan publik: **Home → Game Settings → Permissions → Public** → Save.
4. Atur **Max Players = 12** (Creator Dashboard → game-mu → Places → Configure) supaya semua pemain kebagian home.

## Langkah 6 — Ikon, thumbnail & penyimpanan
1. Di **Creator Dashboard** (create.roblox.com) → pilih game-mu → **Configure → Places → Thumbnails / Icon**: upload `icon-512.png` sebagai ikon dan `thumbnail-1920x1080.png` sebagai thumbnail.
2. Thumbnail tambahan (opsional): file opsi B/C/D ada di folder `../gali-villain/thumbnails/`.
3. Aktifkan penyimpanan: di Studio **Game Settings → Security → Enable Studio Access to API Services = ON** → Save, lalu **File → Publish** sekali lagi.

## Langkah 7 — (Opsional) Game Pass cakar Robux
Bikin pass-nya GRATIS; yang bayar adalah pembeli (kamu terima 70%).
1. Creator Dashboard → game-mu → **Monetization → Passes → Create a Pass**.
2. Buat 3 pass (ikonnya boleh pakai `icon-512.png` dulu):
   - **Bloodmoon Claw** — harga **199** Robux
   - **Galaxy Ripper** — harga **499** Robux
   - **Hand of the Nameless** — harga **999** Robux
3. Setiap pass punya **ID** (angka di alamat halamannya). Salin ketiga ID itu ke `CONFIG.PassIds` di `ServerMain.lua` (Bloodmoon / Galaxy / Nameless), lalu **File → Publish** lagi di Studio.
4. Selama ID masih 0, tombol beli cakar Robux otomatis tampil "Segera hadir" — aman.

## Deskripsi game (salin-tempel)
```
⛏️ DIG A VILLAIN! 👑

Every patch of dirt hides a villain. You won't know WHO — or how RARE — until you dig them out!

🪦 9 RARITY TIERS: Common, Uncommon, Rare, Epic, Legendary, Mythic, Divine, Cosmic... and 404 — HE WHO WAITS BELOW (0.8%)!

🌋 5 TIERS OF DIRT — the harder the ground, the crazier your odds. Void Dirt boosts 404 chances ×10!

🦾 CLAWS, NOT SHOVELS — upgrade 9 mighty claws, from the Rusty Claw to The Nameless Claw. More speed. More LUCK. More power.

👑 BUILD YOUR KINGDOM — display your rarest villains as royal guards in your home. They earn you coins every minute — and whoever sits on the THRONE earns DOUBLE!

✨ Hunt SHINY villains (1% chance, worth 10×), chase runaway Mythics, fuse duplicates, gift villains to friends (Level 10+)!

HOW TO PLAY:
1️⃣ Dig any dirt patch with your claw
2️⃣ Reveal the hidden villain & grab your coins
3️⃣ Upgrade your claw, unlock harder dirt
4️⃣ Display your legends. Rule your kingdom.

Can YOU dig up HE WHO WAITS BELOW? 🌈
```
Tambahkan baris terakhir: `👑 Created by <username Roblox kamu>`

## Kalau ada masalah
Screenshot pesan errornya (panel Output di Studio) dan kirim ke Pip lewat chat — sebutkan lagi di langkah mana kamu berhenti.
