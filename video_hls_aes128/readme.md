####1. Buat Kunci: Jalankan ini di terminal untuk membuat kunci acak 16 byte: 
```bash
openssl rand 16 > keys/video.key
```
####2. Buat file keys/key_info.txt: Isinya harus seperti ini (Ganti localhost dengan domain Anda nanti):
```text
http://localhost:8080/video/key
keys/video.key
```
####3. Script Bash encrypt_video.bat: Script ini akan memecah video menjadi fragmen-fragmen kecil (.ts) yang terenkripsi.
```bash
encrypt_video.bat
```
####4. download package golang
```bash
go mod tidy
```

####5. Jalankan server
```bash
go run main.go
```