import 'dart:convert';
import 'dart:io';

void main() {
  final Map<String, dynamic> translations = {
    "@@locale": "id",
    "onboardingTitle": "Selamat Datang di StreamBeats",
    "onboardingSubtitle": "Mari atur bahasa dan wilayah Anda.",
    "continueButton": "Lanjutkan",
    "navHome": "Beranda",
    "navLibrary": "Perpustakaan",
    "navSearch": "Cari",
    "navLocal": "Lokal",
    "navOffline": "Offline",
    "playerEnjoyingFrom": "Menikmati Dari",
    "playerQueue": "Antrean",
    "playerPlayWithMix": "Putar Otomatis Campuran",
    "playerPlayNext": "Putar Berikutnya",
    "playerAddToQueue": "Tambahkan ke Antrean",
    "playerAddToFavorites": "Tambahkan ke Favorit",
    "playerNoLyricsFound": "Lirik Tidak Ditemukan",
    "playerLyricsNoPlugin": "Penyedia lirik tidak dikonfigurasi. Buka Pengaturan → Plugin untuk memasang.",
    "playerFullscreenLyrics": "Lirik Layar Penuh",
    "localMusicTitle": "Lokal",
    "localMusicGrantPermission": "Izinkan Akses",
    "localMusicStorageAccessRequired": "Akses Penyimpanan Diperlukan",
    "localMusicStorageAccessDesc": "Izinkan akses untuk memindai dan memutar file audio yang disimpan di perangkat Anda.",
    "localMusicAddFolder": "Tambah Folder Musik",
    "localMusicScanNow": "Pindai Sekarang",
    "localMusicScanFailed": "Pemindaian gagal: {message}",
    "@localMusicScanFailed": {
      "placeholders": {
        "message": {"type": "String"}
      }
    },
    "localMusicScanning": "Memindai perangkat untuk file audio...",
    "localMusicEmpty": "Tidak ada musik lokal ditemukan",
    "localMusicSearchEmpty": "Lagu tidak ditemukan.",
    "localMusicShuffle": "Acak",
    "localMusicPlayAll": "Putar Semua",
    "localMusicSearchHint": "Cari musik lokal...",
    "localMusicRescanDevice": "Pindai Ulang Perangkat",
    "localMusicRemoveFolder": "Hapus folder",
    "localMusicMusicFolders": "Folder Musik",
    "localMusicTrackCount": "{count} lagu",
    "@localMusicTrackCount": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "buttonCancel": "Batal",
    "buttonDelete": "Hapus",
    "buttonOk": "OK",
    "buttonUpdate": "Perbarui",
    "buttonDownload": "Unduh",
    "buttonShare": "Bagikan",
    "buttonLater": "Nanti",
    "buttonInfo": "Info",
    "buttonMore": "Lebih Banyak",
    "dialogDeleteTrack": "Hapus Lagu",
    "dialogDeleteTrackMessage": "Apakah Anda yakin ingin menghapus \"{title}\" dari perangkat? Tindakan ini tidak bisa dibatalkan.",
    "@dialogDeleteTrackMessage": {
      "placeholders": {
        "title": {"type": "String"}
      }
    },
    "dialogDeleteTrackLinkedPlaylists": "Lagu ini juga akan dihapus dari:",
    "dialogDontAskAgain": "Jangan tanyakan lagi",
    "dialogDeletePlugin": "Hapus Plugin?",
    "dialogDeletePluginMessage": "Apakah Anda yakin ingin menghapus \"{name}\"? Tindakan ini akan menghapus filenya secara permanen.",
    "@dialogDeletePluginMessage": {
      "placeholders": {
        "name": {"type": "String"}
      }
    },
    "dialogUpdateAvailable": "Pembaruan Tersedia",
    "dialogUpdateNow": "Perbarui Sekarang",
    "dialogDownloadPlaylist": "Unduh playlist",
    "dialogDownloadPlaylistMessage": "Apakah Anda ingin mengunduh {count} lagu dari \"{title}\"? Ini akan menambahkan mereka ke antrean unduhan.",
    "@dialogDownloadPlaylistMessage": {
      "placeholders": {
        "count": {"type": "int"},
        "title": {"type": "String"}
      }
    },
    "dialogDownloadAll": "Unduh Semua",
    "playlistEdit": "Edit Playlist",
    "playlistShareFile": "Bagikan file",
    "playlistExportFile": "Ekspor File",
    "playlistPlay": "Putar",
    "playlistAddToQueue": "Tambah Playlist ke Antrean",
    "playlistShare": "Bagikan Playlist",
    "playlistDelete": "Hapus Playlist",
    "playlistEmptyState": "Belum Ada Lagu!",
    "playlistAvailableOffline": "Tersedia Offline",
    "playlistShuffle": "Acak",
    "playlistMoreOptions": "Opsi Lainnya",
    "playlistNoMatchSearch": "Tidak ada playlist yang cocok",
    "playlistCreateNew": "Buat Playlist Baru 😍",
    "playlistCreateFirstOne": "Belum ada playlist. Buat satu untuk memulai!",
    "addToPlaylistNoSongSelected": "Tidak ada lagu yang dipilih",
    "createPlaylistDialogBarrierLabel": "Dialog buat playlist",
    "createPlaylistDialogNameHint": "Lagu Santai",
    "createPlaylistDialogCreate": "Buat",
    "playlistSongCount": "{count, plural, =1{1 Lagu} other{{count} Lagu}}",
    "@playlistSongCount": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "playlistRemovedTrack": "{title} dihapus dari {playlist}",
    "@playlistRemovedTrack": {
      "placeholders": {
        "title": {"type": "String"},
        "playlist": {"type": "String"}
      }
    },
    "playlistFailedToLoad": "Gagal memuat playlist",
    "settingsTitle": "Pengaturan",
    "settingsPlugins": "Plugin",
    "settingsPluginsSubtitle": "Pasang, muat, dan kelola plugin.",
    "settingsUpdates": "Pembaruan",
    "settingsUpdatesSubtitle": "Periksa pembaruan baru",
    "settingsDownloads": "Unduhan",
    "settingsDownloadsSubtitle": "Lokasi unduhan, kualitas unduhan, dan lainnya...",
    "settingsLocalTracks": "Lagu Lokal",
    "settingsLocalTracksSubtitle": "Pindai, kelola folder, dan pemindaian otomatis.",
    "settingsLanguage": "Bahasa",
    "settingsLanguageSubtitle": "Pilih bahasa aplikasi",
    "settingsAccentColor": "Warna Aksen",
    "settingsAccentColorSubtitle": "Sesuaikan warna tema aplikasi",
    "settingsThemeMode": "Mode Tema",
    "settingsThemeModeSubtitle": "Gelap, Terang, atau ikuti Sistem",
    "settingsBackupRestore": "Cadangkan & Pulihkan",
    "settingsBackupRestoreSubtitle": "Ekspor data Anda ke file atau pulihkan kembali",
    "settingsAbout": "Tentang",
    "settingsAboutSubtitle": "Info aplikasi, versi, dan lisensi",
    "settingsDiscordRPC": "Discord RPC",
    "settingsDiscordRPCSubtitle": "Tampilkan musik yang sedang Anda dengar di status Discord",
    "settingsEqualizer": "Equalizer",
    "settingsEqualizerSubtitle": "Sesuaikan frekuensi suara musik",
    "settingsCrossfade": "Crossfade",
    "settingsCrossfadeSubtitle": "Transisi musik yang mulus antar lagu",
    "settingsBlacklist": "Daftar Hitam",
    "settingsBlacklistSubtitle": "Kelola folder atau lagu yang diabaikan",
    "settingsCache": "Cache",
    "settingsCacheSubtitle": "Kelola penyimpanan cache lagu",
    "settingsQuality": "Kualitas Audio",
    "settingsQualitySubtitle": "Atur kualitas suara saat streaming",
    "settingsSource": "Sumber Utama",
    "settingsSourceSubtitle": "Pilih penyedia musik default",
    "settingsThemeModeDark": "Gelap",
    "settingsThemeModeLight": "Terang",
    "settingsThemeModeSystem": "Sistem",
    "settingsBackupCreate": "Buat Cadangan",
    "settingsBackupRestoreAction": "Pulihkan Cadangan",
    "settingsBackupSuccess": "Cadangan berhasil dibuat!",
    "settingsRestoreSuccess": "Cadangan berhasil dipulihkan!",
    "settingsRestoreFailed": "Gagal memulihkan cadangan: {error}",
    "@settingsRestoreFailed": {
      "placeholders": {
        "error": {"type": "String"}
      }
    },
    "settingsBackupFailed": "Gagal membuat cadangan: {error}",
    "@settingsBackupFailed": {
      "placeholders": {
        "error": {"type": "String"}
      }
    },
    "settingsSelectBackupFile": "Pilih File Cadangan",
    "settingsNoBackupsFound": "Tidak ada file cadangan ditemukan",
    "settingsDeleteBackup": "Hapus Cadangan",
    "settingsConfirmDeleteBackup": "Apakah Anda yakin ingin menghapus cadangan ini?",
    "settingsDownloadPath": "Lokasi Unduhan",
    "settingsDownloadQuality": "Kualitas Unduhan",
    "settingsDownloadQualityHigh": "Tinggi (320kbps)",
    "settingsDownloadQualityMedium": "Sedang (160kbps)",
    "settingsDownloadQualityLow": "Rendah (96kbps)",
    "settingsAutoScan": "Pemindaian Otomatis",
    "settingsAutoScanSubtitle": "Pindai lagu secara otomatis saat aplikasi dibuka",
    "settingsMetadataRefresh": "Perbarui Metadata Otomatis",
    "settingsMetadataRefreshSubtitle": "Ambil sampul album dan info lagu terbaru",
    "settingsPluginsInstall": "Pasang Plugin",
    "settingsPluginsDeveloperMode": "Mode Pengembang",
    "settingsPluginsDeveloperModeSubtitle": "Aktifkan untuk memuat plugin lokal",
    "settingsUpdatesCheck": "Periksa Pembaruan",
    "settingsUpdatesAutoCheck": "Periksa Otomatis",
    "settingsUpdatesAutoCheckSubtitle": "Beri tahu jika ada versi baru",
    "settingsUpdatesBeta": "Saluran Beta",
    "settingsUpdatesBetaSubtitle": "Dapatkan akses ke fitur uji coba terbaru",
    "settingsDiscordRPCEnabled": "Aktifkan RPC",
    "settingsDiscordRPCStatus": "Status Ketersediaan",
    "settingsDiscordRPCPlayStatus": "Tampilkan Status Putar/Jeda",
    "settingsDiscordRPCLargeImage": "Gambar Sampul Besar",
    "settingsEqualizerEnabled": "Aktifkan Equalizer",
    "settingsEqualizerPreset": "Preset",
    "settingsCrossfadeDuration": "Durasi Transisi",
    "settingsCrossfadeDurationSubtitle": "Atur waktu tumpang tindih suara (detik)",
    "settingsCacheSize": "Ukuran Cache",
    "settingsCacheClear": "Hapus Cache",
    "settingsCacheSizeTracks": "{count} lagu cached",
    "@settingsCacheSizeTracks": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "settingsCacheCleared": "Cache lagu berhasil dihapus!",
    "settingsQualityStream": "Kualitas Streaming",
    "settingsSourcePreferred": "Penyedia Musik Utama",
    "libraryTitle": "Perpustakaan",
    "libraryPlaylists": "Playlist",
    "libraryArtists": "Artis",
    "libraryAlbums": "Album",
    "libraryFavorites": "Favorit",
    "libraryDownloads": "Unduhan",
    "libraryHistory": "Riwayat",
    "libraryOffline": "Mode Offline",
    "libraryImport": "Impor",
    "searchTitle": "Cari",
    "searchHistory": "Riwayat Pencarian",
    "searchHistoryClear": "Hapus Semua",
    "searchSuggestions": "Saran Pencarian",
    "searchHint": "Cari lagu, artis, atau playlist...",
    "searchEmpty": "Ketik sesuatu untuk mencari musik",
    "searchNoResults": "Tidak ada hasil untuk \"{query}\"",
    "@searchNoResults": {
      "placeholders": {
        "query": {"type": "String"}
      }
    },
    "searchCategoryTracks": "Lagu",
    "searchCategoryArtists": "Artis",
    "searchCategoryAlbums": "Album",
    "searchCategoryPlaylists": "Playlist",
    "searchFilterAll": "Semua",
    "offlineTitle": "Mode Offline",
    "offlineSubtitle": "Putar musik yang sudah Anda unduh tanpa koneksi internet.",
    "offlineEmpty": "Belum ada lagu yang diunduh",
    "downloadQueueTitle": "Antrean Unduhan",
    "downloadQueueEmpty": "Tidak ada unduhan aktif",
    "downloadStatusDownloading": "Mengunduh...",
    "downloadStatusPaused": "Ditangguhkan",
    "downloadStatusCompleted": "Selesai",
    "downloadStatusFailed": "Gagal",
    "downloadStatusWaiting": "Menunggu",
    "downloadActionPause": "Jeda",
    "downloadActionResume": "Lanjutkan",
    "downloadActionCancel": "Batal",
    "downloadActionDelete": "Hapus",
    "downloadSnackbarAdded": "\"{title}\" ditambahkan ke antrean unduhan",
    "@downloadSnackbarAdded": {
      "placeholders": {
        "title": {"type": "String"}
      }
    },
    "downloadSnackbarCompleted": "Unduhan selesai: {title}",
    "@downloadSnackbarCompleted": {
      "placeholders": {
        "title": {"type": "String"}
      }
    },
    "downloadSnackbarFailed": "Unduhan gagal: {title}",
    "@downloadSnackbarFailed": {
      "placeholders": {
        "title": {"type": "String"}
      }
    },
    "historyTitle": "Riwayat Putar",
    "historyEmpty": "Belum ada riwayat putar lagu",
    "historyClear": "Hapus Riwayat",
    "favoritesTitle": "Lagu Favorit",
    "favoritesEmpty": "Belum ada lagu favorit",
    "favoritesAdd": "Tambah ke Favorit",
    "favoritesRemove": "Hapus dari Favorit",
    "aboutTitle": "Tentang",
    "aboutVersion": "Versi {version}",
    "@aboutVersion": {
      "placeholders": {
        "version": {"type": "String"}
      }
    },
    "aboutBuild": "Build {build}",
    "@aboutBuild": {
      "placeholders": {
        "build": {"type": "String"}
      }
    },
    "aboutDescription": "StreamBeats adalah pemutar musik modern dan elegan yang dibangun dengan Flutter.",
    "aboutLicense": "Lisensi",
    "aboutCredits": "Kredit",
    "aboutFeedback": "Kirim Umpan Balik",
    "aboutSupport": "Dukung Kami",
    "aboutWebsite": "Kunjungi Website",
    "albumViewTrackCount": "{count, plural, =1{1 Lagu} other{{count} Lagu}}",
    "@albumViewTrackCount": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "albumViewLoadFailed": "Gagal memuat album",
    "aboutCraftingSubtitle": "Merangkai simfoni dalam baris kode.",
    "aboutFollowGitHub": "Ikuti di GitHub",
    "aboutSendInquiry": "Kirim penawaran bisnis",
    "aboutCreativeHighlights": "Pembaruan dan sorotan kreatif",
    "aboutTipQuote": "Menikmati StreamBeats? Dukungan kecil Anda sangat berarti. 🌸",
    "aboutTipButton": "Saya ingin membantu",
    "aboutTipDesc": "Saya ingin StreamBeats terus berkembang.",
    "aboutGitHub": "GitHub",
    "songInfoSectionDetails": "Detail Lagu",
    "songInfoSectionTechnical": "Informasi Teknis",
    "songInfoSectionActions": "Tindakan",
    "songInfoLabelTitle": "Judul",
    "songInfoLabelArtist": "Artis",
    "songInfoLabelAlbum": "Album",
    "songInfoLabelDuration": "Durasi",
    "songInfoLabelSource": "Sumber",
    "songInfoLabelMediaId": "ID Media",
    "songInfoLabelPluginId": "ID Plugin",
    "songInfoIdCopied": "ID Media disalin",
    "songInfoLinkCopied": "Tautan disalin",
    "songInfoNoLink": "Tautan tidak tersedia",
    "songInfoOpenFailed": "Tidak dapat membuka tautan",
    "songInfoUpdateMetadata": "Ambil metadata terbaru",
    "songInfoMetadataUpdated": "Metadata diperbarui",
    "songInfoMetadataUpdateFailed": "Gagal memperbarui metadata",
    "songInfoMetadataUnavailable": "Pembaruan metadata tidak tersedia untuk sumber ini",
    "songInfoSearchTitle": "Cari lagu ini di StreamBeats",
    "songInfoSearchArtist": "Cari artis ini di StreamBeats",
    "songInfoSearchAlbum": "Cari album ini di StreamBeats",
    "eqTitle": "Equalizer",
    "eqResetTooltip": "Reset ke Awal",
    "chartNoItems": "Tidak ada item di bagan ini",
    "chartLoadFailed": "Gagal memuat bagan",
    "chartPlay": "Putar",
    "chartResolving": "Menghubungkan...",
    "chartReady": "Siap",
    "chartAddToPlaylist": "Tambah ke Playlist",
    "chartNoResolver": "Penyedia konten tidak dimuat. Pasang plugin untuk memutar.",
    "chartResolveFailed": "Gagal menghubungkan. Mencoba mencari...",
    "chartNoResolverAdd": "Penyedia konten tidak dimuat.",
    "chartNoMatch": "Tidak ditemukan kecocokan. Coba cari secara manual.",
    "chartStatPeak": "Puncak",
    "chartStatWeeks": "Minggu",
    "chartStatChange": "Perubahan",
    "menuSharePreparing": "Menyiapkan {title} untuk dibagikan.",
    "@menuSharePreparing": {
      "placeholders": {
        "title": {"type": "String"}
      }
    },
    "menuOpenLinkFailed": "Tidak dapat membuka tautan",
    "localMusicFolders": "Folder Musik",
    "localMusicCloseSearch": "Tutup pencarian",
    "localMusicOpenSearch": "Cari",
    "localMusicNoMusicFound": "Musik lokal tidak ditemukan",
    "localMusicNoSearchResults": "Lagu tidak ditemukan.",
    "importSongsTitle": "Impor Lagu",
    "importNoPluginsLoaded": "Plugin pengimpor konten tidak dimuat.\nPasang plugin pengimpor untuk mengimpor playlist dari layanan eksternal.",
    "importStreamBeatsFiles": "Impor File StreamBeats",
    "importM3UFiles": "Impor Playlist M3U",
    "importM3UNameDialogTitle": "Nama Playlist",
    "importM3UNameHint": "Masukkan nama untuk playlist ini",
    "importM3UNoTracks": "Tidak ada lagu valid ditemukan di file M3U.",
    "importNoteTitle": "Catatan",
    "importNoteMessage": "Anda hanya dapat mengimpor file yang dibuat oleh StreamBeats.\nJika file Anda dari sumber lain, itu tidak akan berfungsi. Lanjutkan?",
    "importTitle": "Impor",
    "importCheckingUrl": "Memeriksa URL...",
    "importFetchingTracks": "Mengambil lagu...",
    "importSavingToLibrary": "Menyimpan ke perpustakaan...",
    "importPasteUrlHint": "Tempel URL playlist atau album untuk diimpor",
    "importAction": "Impor",
    "importTrackCount": "{count} lagu",
    "@importTrackCount": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "importResolving": "Menghubungkan...",
    "importResolvingProgress": "Menghubungkan lagu: {done} / {total}",
    "@importResolvingProgress": {
      "placeholders": {
        "done": {"type": "int"},
        "total": {"type": "int"}
      }
    },
    "importReviewTitle": "Tinjau Impor",
    "importReviewSummary": "{resolved} berhasil, {failed} gagal dari total {total}",
    "@importReviewSummary": {
      "placeholders": {
        "resolved": {"type": "int"},
        "failed": {"type": "int"},
        "total": {"type": "int"}
      }
    },
    "importSaveTracks": "Simpan {count} Lagu",
    "@importSaveTracks": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "importTracksSaved": "{count} lagu berhasil disimpan!",
    "@importTracksSaved": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "importDone": "Selesai",
    "importMore": "Impor Lebih Banyak",
    "importUnknownError": "Kesalahan tidak dikenal",
    "importTryAgain": "Coba Lagi",
    "importSkipTrack": "Lewati lagu ini",
    "importMatchOptions": "Opsi pencocokan",
    "importAutoMatched": "Cocok otomatis",
    "importUserSelected": "Dipilih",
    "importSkipped": "Dilewati",
    "importNoMatch": "Tidak ditemukan kecocokan",
    "importReorderTip": "Tekan lama playlist untuk mengatur ulang urutan",
    "importErrorCannotHandleUrl": "Plugin ini tidak dapat memproses URL yang diberikan.",
    "importErrorUnexpectedResponse": "Respon tidak terduga dari plugin.",
    "importErrorFailedToCheck": "Gagal memeriksa URL: {error}",
    "@importErrorFailedToCheck": {
      "placeholders": {
        "error": {"type": "String"}
      }
    },
    "importErrorFailedToFetchInfo": "Gagal mengambil info koleksi: {error}",
    "@importErrorFailedToFetchInfo": {
      "placeholders": {
        "error": {"type": "String"}
      }
    },
    "importErrorFailedToFetchTracks": "Gagal mengambil lagu: {error}",
    "@importErrorFailedToFetchTracks": {
      "placeholders": {
        "error": {"type": "String"}
      }
    },
    "importErrorFailedToSave": "Gagal menyimpan playlist: {error}",
    "@importErrorFailedToSave": {
      "placeholders": {
        "error": {"type": "String"}
      }
    },
    "playlistPinToTop": "Sematkan di Atas",
    "playlistUnpin": "Lepas Sematan",
    "snackbarImportingMedia": "Mengimpor Media...",
    "snackbarPlaylistSaved": "Playlist disimpan ke perpustakaan!",
    "snackbarInvalidFileFormat": "Format File Tidak Valid",
    "snackbarMediaItemImported": "Item Media Diimpor",
    "snackbarPlaylistImported": "Playlist Diimpor",
    "snackbarOpenImportForUrl": "Buka menu Impor di Perpustakaan untuk mengimpor dari URL ini.",
    "snackbarProcessingFile": "Memproses File...",
    "snackbarPreparingShare": "Menyiapkan {title} untuk dibagikan",
    "@snackbarPreparingShare": {
      "placeholders": {
        "title": {"type": "String"}
      }
    },
    "snackbarPreparingExport": "Menyiapkan {title} untuk diekspor.",
    "@snackbarPreparingExport": {
      "placeholders": {
        "title": {"type": "String"}
      }
    },
    "pluginManagerTabInstalled": "Terpasang",
    "pluginManagerTabStore": "Toko Plugin",
    "pluginManagerSelectPackage": "Pilih Paket Plugin (.bex)",
    "pluginManagerOutdatedManifest": "Plugin menggunakan versi manifest usang. Beberapa fitur mungkin bermasalah.",
    "pluginManagerStatusActive": "Aktif",
    "pluginManagerStatusInactive": "Tidak Aktif",
    "pluginRepositoryUpdatedOn": "Diperbarui {date}",
    "@pluginRepositoryUpdatedOn": {
      "placeholders": {
        "date": {"type": "String"}
      }
    },
    "pluginRepositoryAvailableCount": "{count, plural, =1{1 plugin tersedia} other{{count} plugin tersedia}}",
    "@pluginRepositoryAvailableCount": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "pluginRepositoryOutdatedManifest": "Manifest usang. Fitur mungkin bermasalah.",
    "pluginRepositoryUnknownPublisher": "Penerbit tidak dikenal",
    "pluginRepositoryActionRetry": "Coba Lagi",
    "pluginRepositoryActionOutdated": "Usang",
    "pluginRepositoryActionInstalled": "Terpasang",
    "pluginRepositoryActionInstall": "Pasang",
    "pluginRepositoryActionUnavailable": "Tidak Tersedia",
    "pluginRepositoryInstallFailed": "Pemasangan gagal.",
    "pluginRepositoryDownloadFailed": "Gagal mengunduh {name}.",
    "@pluginRepositoryDownloadFailed": {
      "placeholders": {
        "name": {"type": "String"}
      }
    },
    "smartReplaceAppliedPlaylistsSummary": "{count, plural, =1{Digantikan di 1 playlist{queue}.} other{Digantikan di {count} playlist{queue}.}}",
    "@smartReplaceAppliedPlaylistsSummary": {
      "placeholders": {
        "count": {"type": "int"},
        "queue": {"type": "String"}
      }
    },
    "lyricsSearchFieldLabel": "Cari lirik...",
    "lyricsSearchEmptyPrompt": "Ketik judul lagu atau artis untuk mencari lirik.",
    "lyricsSearchNoResults": "Lirik tidak ditemukan untuk \"{query}\"",
    "@lyricsSearchNoResults": {
      "placeholders": {
        "query": {"type": "String"}
      }
    },
    "lyricsSearchApplied": "Lirik berhasil diterapkan",
    "lyricsSearchFetchFailed": "Gagal mengambil lirik",
    "lyricsSearchPreview": "Pratinjau",
    "lyricsSearchPreviewTooltip": "Pratinjau lirik",
    "lyricsSearchSynced": "TER-SINKRONISASI",
    "lyricsSearchPreviewLoadFailed": "Gagal memuat lirik.",
    "lyricsSearchApplyAction": "Terapkan Lirik",
    "lyricsSettingsSearchTitle": "Cari Lirik Kustom",
    "lyricsSettingsSearchSubtitle": "Cari lirik alternatif di internet",
    "lyricsSettingsSyncTitle": "Sesuaikan Sinkronisasi (Jeda/Offset)",
    "lyricsSettingsSyncSubtitle": "Perbaiki lirik yang terlalu cepat atau lambat",
    "lyricsSettingsSaveTitle": "Simpan Offline",
    "lyricsSettingsSaveSubtitle": "Simpan lirik ini di perangkat Anda",
    "lyricsSettingsDeleteTitle": "Hapus Lirik Tersimpan",
    "lyricsSettingsDeleteSubtitle": "Hapus data lirik offline",
    "lyricsSyncTapToReset": "Ketuk untuk reset",
    "upNextTitle": "Selanjutnya",
    "upNextItemsInQueue": "{count, plural, =1{1 lagu di antrean} other{{count} lagu di antrean}}",
    "@upNextItemsInQueue": {
      "placeholders": {
        "count": {"type": "int"}
      }
    },
    "upNextAutoPlay": "Putar Otomatis",
    "tooltipCopyToClipboard": "Salin ke papan klip",
    "snackbarCopiedToClipboard": "Disalin ke papan klip",
    "tooltipSongInfo": "Informasi Lagu",
    "snackbarCannotDeletePlayingSong": "Tidak dapat menghapus lagu yang sedang diputar",
    "playerLoopOff": "Mati",
    "playerLoopOne": "Ulangi Satu",
    "playerLoopAll": "Ulangi Semua",
    "snackbarOpeningAlbumPage": "Membuka halaman album asli.",
    "updateAvailableBody": "Versi baru StreamBeats🌸 telah tersedia!\n\nVersi: {ver}+{build}",
    "@updateAvailableBody": {
      "placeholders": {
        "ver": {"type": "String"},
        "build": {"type": "String"}
      }
    },
    "pluginSnackbarInstalled": "Plugin \"{id}\" berhasil dipasang",
    "@pluginSnackbarInstalled": {
      "placeholders": {
        "id": {"type": "String"}
      }
    },
    "pluginSnackbarLoaded": "Plugin \"{id}\" dimuat",
    "@pluginSnackbarLoaded": {
      "placeholders": {
        "id": {"type": "String"}
      }
    },
    "pluginSnackbarDeleted": "Plugin \"{id}\" berhasil dihapus",
    "@pluginSnackbarDeleted": {
      "placeholders": {
        "id": {"type": "String"}
      }
    },
    "pluginBootstrapTitle": "Menyiapkan StreamBeats",
    "pluginBootstrapProgress": "Menyiapkan mesin plugin baru... {percent}%",
    "@pluginBootstrapProgress": {
      "placeholders": {
        "percent": {"type": "String"}
      }
    },
    "pluginBootstrapHint": "Ini hanya terjadi sekali.",
    "pluginBootstrapErrorTitle": "Koneksi Terlalu Lambat",
    "pluginBootstrapErrorBody": "Beberapa plugin tidak dapat dipasang. Anda tetap dapat menggunakan StreamBeats — plugin akan dicoba kembali saat peluncuran berikutnya.",
    "pluginBootstrapContinue": "Lanjutkan Saja"
  };

  final file = File('d:/StreamBeats/lib/l10n/app_id.arb');
  final encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(translations));
  print('Successfully wrote app_id.arb');
}
