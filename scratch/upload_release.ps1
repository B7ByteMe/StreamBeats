# Upload APK ke GitHub Release menggunakan GitHub API
# Jalankan script ini dengan token autentikasi

param(
    [string]$Token = $env:GITHUB_TOKEN
)

$owner = "DuskCipher"
$repo  = "StreamBeats"
$tag   = "v3.2.0"
$title = "StreamBeats v3.2.0"
$body  = @"
## StreamBeats v3.2.0

### 🚀 Fitur Baru & Sinkronisasi Listen Together
- **Dialog Konfirmasi Guest:** Sekarang jika Guest di Party Room mencoba memutar, menjeda, memajukan, atau mengganti lagu, aplikasi akan menampilkan pop-up konfirmasi: *"Apakah Anda ingin keluar dari room untuk mengontrol musik sendiri?"*
- **Sinkronisasi Otomatis:** Guest tidak akan berganti lagu secara otomatis lagi saat lagu selesai, melainkan selalu tersinkronisasi mengikuti Host.
- **Fix RangeError:** Memperbaiki bug RangeError pada pembuatan kode acak.
- **Listen Together & Playlist Bersama:** Ditambahkan penanganan error transparan di layar.

### Pilih APK sesuai perangkat Anda:

| File | Keterangan |
|---|---|
| StreamBeats-v3.2.0-arm64-v8a.apk | HP modern 64-bit (2018+). **Direkomendasikan!** |
| StreamBeats-v3.2.0-armeabi-v7a.apk | HP lama 32-bit |
| StreamBeats-v3.2.0-x86_64.apk | Emulator / Chromebook |
"@

$apkDir = "build\app\outputs\flutter-apk"
$apks   = @(
    "$apkDir\StreamBeats-v3.2.0-arm64-v8a.apk",
    "$apkDir\StreamBeats-v3.2.0-armeabi-v7a.apk",
    "$apkDir\StreamBeats-v3.2.0-x86_64.apk"
)

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept"        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# 1. Dapatkan atau buat release
Write-Host "Mendapatkan info release $tag ..." -ForegroundColor Cyan
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/tags/$tag" `
        -Headers $headers
    Write-Host "Release ditemukan: $($release.html_url)" -ForegroundColor Green
} catch {
    Write-Host "Release tidak ditemukan, membuat baru..." -ForegroundColor Yellow
    $releaseBody = @{
        tag_name = $tag
        name     = $title
        body     = $body
        draft    = $false
        prerelease = $false
    } | ConvertTo-Json -Compress

    # Ensure UTF-8 string encoding for the request body
    $releaseBodyBytes = [System.Text.Encoding]::UTF8.GetBytes($releaseBody)
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases" `
        -Method POST -Headers $headers -Body $releaseBodyBytes -ContentType "application/json"
    Write-Host "Release baru berhasil dibuat!" -ForegroundColor Green
}

# 2. Ambil daftar asset yang ada untuk menghapus file lama jika namanya sama
Write-Host "Memeriksa asset yang ada di release..." -ForegroundColor Cyan
$existingAssets = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/$($release.id)/assets" `
    -Headers $headers

# 3. Upload setiap APK
foreach ($apkPath in $apks) {
    if (-not (Test-Path $apkPath)) {
        Write-Host "File tidak ditemukan: $apkPath" -ForegroundColor Red
        continue
    }

    $fileName = Split-Path $apkPath -Leaf
    
    # Periksa dan hapus asset lama jika ada yang namanya sama
    $duplicateAsset = $existingAssets | Where-Object { $_.name -eq $fileName }
    if ($duplicateAsset) {
        Write-Host "Asset '$fileName' sudah ada. Menghapus asset lama (ID: $($duplicateAsset.id))..." -ForegroundColor Yellow
        try {
            Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/assets/$($duplicateAsset.id)" `
                -Method DELETE -Headers $headers
            Write-Host "  ✅ Berhasil menghapus asset lama!" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ Gagal menghapus asset lama: $_" -ForegroundColor Red
            continue
        }
    }

    # Lakukan upload file baru
    $uploadUrl = $release.upload_url -replace "\{\?name,label\}", "?name=$fileName"
    $fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $apkPath))

    Write-Host "Mengupload $fileName ($([math]::Round($fileBytes.Length/1MB,1)) MB)..." -ForegroundColor Cyan

    try {
        $uploadHeaders = $headers.Clone()
        $uploadHeaders["Content-Type"] = "application/vnd.android.package-archive"
        Invoke-RestMethod -Uri $uploadUrl -Method POST -Headers $uploadHeaders -Body $fileBytes | Out-Null
        Write-Host "  ✅ $fileName berhasil diupload!" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Gagal upload $fileName`: $_" -ForegroundColor Red
    }
}

Write-Host "`nSelesai! Cek release di: https://github.com/$owner/$repo/releases/tag/$tag" -ForegroundColor Cyan
