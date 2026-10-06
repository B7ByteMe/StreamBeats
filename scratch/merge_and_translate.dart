import 'dart:convert';
import 'dart:io';

void main() {
  final enFile = File('d:/StreamBeats/lib/l10n/app_en.arb');
  final idFile = File('d:/StreamBeats/lib/l10n/app_id.arb');

  final en = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final id = json.decode(idFile.readAsStringSync()) as Map<String, dynamic>;

  // Additional translations for the missing keys
  final Map<String, String> idTranslations = {
    "settingsUIElements": "Antarmuka & Layanan",
    "settingsUIElementsSubtitle": "Geser otomatis bagan, penyesuaian antarmuka, dll.",
    "settingsLastFM": "Pengaturan Last.FM",
    "settingsLastFMSubtitle": "Kunci API, rahasia, dan pengaturan pencatatan putar.",
    "settingsStorage": "Penyimpanan",
    "settingsStorageSubtitle": "Cadangan, Cache, Riwayat, Pemulihan dan lainnya...",
    "settingsLanguageCountry": "Bahasa & Negara",
    "settingsLanguageCountrySubtitle": "Pilih bahasa dan negara Anda.",
    "settingsScanning": "Pemindaian",
    "settingsMusicFolders": "Folder Musik",
    "settingsHistory": "Riwayat",
    "settingsAutomatic": "Otomatis",
    "settingsDangerZone": "Zona Bahaya",
    "settingsScrobbling": "Pencatatan Putar (Scrobble)",
    "settingsAuthentication": "Autentikasi",
    "settingsHomeScreen": "Layar Beranda",
    "settingsChartVisibility": "Visibilitas Bagan",
    "settingsLocation": "Lokasi",
    
    "pluginRepositoryTitle": "Repositori Plugin",
    "pluginRepositorySubtitle": "Temukan plugin dari sumber URL jarak jauh",
    "pluginRepositoryAddAction": "Tambah Repositori",
    "pluginRepositoryAddTitle": "Tambah Repositori",
    "pluginRepositoryAddSubtitle": "Masukkan URL file JSON repositori plugin yang valid.",
    "pluginRepositoryEmpty": "Belum ada repositori yang ditambahkan.",
    "pluginRepositoryUrlCopied": "URL Repositori disalin ke papan klip",
    "pluginRepositoryNoDescription": "Deskripsi tidak tersedia.",
    "pluginRepositoryUnknownUpdate": "Pembaruan tidak diketahui",
    "pluginRepositoryPluginsCount": "{count, plural, =1{1 plugin} other{{count} plugin}}",
    "pluginRepositoryErrorLoad": "Gagal memuat repositori.",
    "pluginRepositoryErrorInvalid": "URL atau file repositori tidak valid.",
    "pluginRepositoryErrorRemove": "Gagal menghapus repositori.",
    "pluginRepositoryError": "Error: {message}",
    
    "dialogAddingToDownloadQueue": "Menambahkan ke antrean unduhan",
    
    "emptyNoInternet": "Tidak Ada Koneksi Internet!",
    "emptyNoContentPlugin": "Tidak ada plugin konten dimuat. Muat Content Resolver di Pengelola Plugin.",
    "emptyRefreshingSource": "Menyegarkan sumber Discover... Sumber sebelumnya tidak lagi tersedia.",
    "emptyNoTracks": "Tidak ada lagu tersedia",
    "emptyNoResults": "Pencarian tidak ditemukan",
    
    "snackbarDeletedTrack": "Berhasil menghapus \"{title}\"",
    "snackbarDeleteFailed": "Gagal menghapus \"{title}\"",
    "snackbarAddedToNextQueue": "Ditambahkan untuk Diputar Berikutnya",
    "snackbarAddedToQueue": "Ditambahkan ke Antrean",
    "snackbarAddedToLiked": "\"{title}\" ditambahkan ke Favorit!",
    "snackbarNowPlaying": "Memutar {name}",
    "snackbarPlaylistAddedToQueue": "Menambahkan {name} ke Antrean",
    "snackbarPlaylistQueued": "Playlist ditambahkan ke antrean unduhan",
    "snackbarPlaylistUpdated": "Playlist Diperbarui!",
    "snackbarNoInternet": "Koneksi internet terputus.",
    "snackbarImportFailed": "Impor Gagal!",
    "snackbarImportCompleted": "Impor Selesai",
    "snackbarBackupFailed": "Cadangan Gagal!",
    "snackbarExportedTo": "Diekspor ke: {path}",
    "snackbarMediaIdCopied": "ID Media disalin",
    "snackbarLinkCopied": "Tautan disalin",
    "snackbarNoLinkAvailable": "Tautan tidak tersedia",
    "snackbarCouldNotOpenLink": "Tidak dapat membuka tautan",
    "snackbarPreparingDownload": "Menyiapkan unduhan untuk {title}...",
    "snackbarAlreadyDownloaded": "\"{title}\" sudah diunduh.",
    "snackbarAlreadyInQueue": "\"{title}\" sudah ada di antrean.",
    "snackbarDownloaded": "Selesai mengunduh {title}",
    "snackbarDownloadServiceUnavailable": "Error: Layanan unduhan tidak tersedia.",
    "snackbarSongsAddedToQueue": "Menambahkan {count} lagu ke antrean unduhan",
    "snackbarDeleteTrackFailDevice": "Gagal menghapus trek dari penyimpanan perangkat.",
    
    "searchHintExplore": "Apa yang ingin Anda dengarkan?",
    "searchHintLibrary": "Cari di perpustakaan...",
    "searchHintOfflineMusic": "Cari lagu Anda...",
    "searchHintPlaylists": "Cari playlist...",
    "searchStartTyping": "Mulai mengetik untuk mencari...",
    "searchNoSuggestions": "Saran tidak ditemukan!",
    "searchFailed": "Pencarian gagal!",
    "searchDiscover": "Temukan musik keren...",
    "searchSources": "SUMBER",
    "searchNoPlugins": "Plugin tidak terpasang",
    "searchTracks": "Lagu",
    "searchAlbums": "Album",
    "searchArtists": "Artis",
    "searchPlaylists": "Playlist",
    
    "exploreDiscover": "Temukan",
    "exploreRecently": "Baru-baru Ini",
    "exploreLastFmPicks": "Rekomendasi Last.Fm",
    "exploreFailedToLoad": "Gagal memuat bagian beranda.",
    
    "libraryEmptyState": "Perpustakaan Anda sepi. Tambahkan lagu untuk meramaikannya!",
    "libraryIn": "di {playlistName}",
    
    "menuAddToPlaylist": "Tambah ke Playlist",
    "menuSmartReplace": "Smart Replace",
    "menuShare": "Bagikan",
    "menuAvailableOffline": "Tersedia Offline",
    "menuDownload": "Unduh",
    "menuOpenOriginalLink": "Buka tautan asli",
    "menuDeleteTrack": "Hapus",
    
    "songInfoTitle": "Judul",
    "songInfoArtist": "Artis",
    "songInfoAlbum": "Album",
    "songInfoMediaId": "ID Media",
    "songInfoCopyId": "Salin ID",
    "songInfoCopyLink": "Salin Tautan",
    "songInfoOpenBrowser": "Buka di browser",
    
    "tooltipRemoveFromLibrary": "Hapus dari Perpustakaan",
    "tooltipSaveToLibrary": "Simpan ke Perpustakaan",
    "tooltipOpenOriginalLink": "Buka Tautan Asli",
    "tooltipShuffle": "Acak",
    "tooltipAvailableOffline": "Tersedia Offline",
    "tooltipDownloadPlaylist": "Unduh playlist",
    "tooltipMoreOptions": "Opsi Lainnya",
    "tooltipInfo": "Info",
    
    "playerSettingCrossfadeInstant": "Transisi lagu instan",
    "playerSettingCrossfadeBlend": "Transisi tumpang tindih {seconds} detik",
    "playerSettingEqualizer": "Equalizer",
    "playerSettingEqualizerActive": "Aktif",
    "playerSettingEqualizerActivePreset": "Aktif — Preset {preset}",
    "playerSettingEqualizerSubtitle": "Equalizer parametrik 10-band via FFmpeg.",
    
    "pluginDefaultsTitle": "Default Plugin",
    "pluginDefaultsDiscoverHeader": "Sumber Discover",
    "pluginDefaultsNoResolver": "Resolver konten tidak dimuat. Pasang plugin untuk memilih sumber Discover.",
    "pluginDefaultsAutomaticSubtitle": "Gunakan resolver konten pertama yang tersedia.",
    "pluginDefaultsPriorityHeader": "Prioritas Resolver",
    "pluginDefaultsNoPriority": "Resolver konten tidak dimuat. Pengaturan prioritas akan muncul setelah plugin dimuat.",
    "pluginDefaultsPriorityDesc": "Seret untuk mengatur urutan. Resolver dengan prioritas lebih tinggi akan dicoba terlebih dahulu.",
    "pluginDefaultsLyricsHeader": "Prioritas Lirik",
    "pluginDefaultsLyricsNone": "Penyedia lirik tidak dimuat.",
    "pluginDefaultsLyricsDesc": "Seret untuk mengatur prioritas penyedia lirik.",
    "pluginDefaultsSuggestionsHeader": "Saran Pencarian",
    "pluginDefaultsSuggestionsNone": "Penyedia saran pencarian tidak dimuat.",
    "pluginDefaultsSuggestionsHistoryOnlyTitle": "Tidak Ada",
    "pluginDefaultsSuggestionsHistoryOnlySubtitle": "Gunakan riwayat pencarian saja.",
    
    "storageSettingTitle": "Penyimpanan",
    "storageClearHistoryEvery": "Bersihkan Riwayat Setiap",
    "storageClearHistorySubtitle": "Bersihkan riwayat putar otomatis setelah periode terpilih.",
    "storageDays": "{count, plural, =1{1 Hari} other{{count} Hari}}",
    "storageBackupLocation": "Lokasi Cadangan",
    "storageBackupLocationAndroid": "Folder Unduhan / direktori data aplikasi",
    "storageBackupLocationDownloads": "Folder Unduhan",
    "storageCreateBackup": "Buat Cadangan",
    "storageCreateBackupSubtitle": "Simpan pengaturan dan data Anda ke file cadangan.",
    "storageBackupCreatedAt": "Cadangan berhasil dibuat di {path}",
    "storageBackupShareFailed": "Gagal membagikan cadangan: {error}",
    "storageBackupFailed": "Cadangan Gagal!"
  };

  // Merge loop
  final Map<String, dynamic> merged = {};
  for (final key in en.keys) {
    if (key.startsWith('@@')) {
      merged[key] = id[key] ?? en[key];
    } else if (key.startsWith('@')) {
      // It is metadata, copy from EN
      merged[key] = en[key];
    } else {
      // Check ID first, then our custom map, fallback to EN
      merged[key] = id[key] ?? idTranslations[key] ?? en[key];
    }
  }

  idFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(merged));
  print('Merged successfully. Total keys: ${merged.length}');
}
