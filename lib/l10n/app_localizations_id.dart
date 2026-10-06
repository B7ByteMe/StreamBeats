// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get onboardingTitle => 'Selamat Datang di StreamBeats';

  @override
  String get onboardingSubtitle => 'Mari atur bahasa dan wilayah Anda.';

  @override
  String get continueButton => 'Lanjutkan';

  @override
  String get navHome => 'Beranda';

  @override
  String get navLibrary => 'Perpustakaan';

  @override
  String get navSearch => 'Cari';

  @override
  String get navLocal => 'Lokal';

  @override
  String get navOffline => 'Offline';

  @override
  String get playerEnjoyingFrom => 'Menikmati Dari';

  @override
  String get playerQueue => 'Antrean';

  @override
  String get playerPlayWithMix => 'Putar Otomatis Campuran';

  @override
  String get playerPlayNext => 'Putar Berikutnya';

  @override
  String get playerAddToQueue => 'Tambahkan ke Antrean';

  @override
  String get playerAddToFavorites => 'Tambahkan ke Favorit';

  @override
  String get playerNoLyricsFound => 'Lirik Tidak Ditemukan';

  @override
  String get playerLyricsNoPlugin =>
      'Penyedia lirik tidak dikonfigurasi. Buka Pengaturan → Plugin untuk memasang.';

  @override
  String get playerFullscreenLyrics => 'Lirik Layar Penuh';

  @override
  String get localMusicTitle => 'Lokal';

  @override
  String get localMusicGrantPermission => 'Izinkan Akses';

  @override
  String get localMusicStorageAccessRequired => 'Akses Penyimpanan Diperlukan';

  @override
  String get localMusicStorageAccessDesc =>
      'Izinkan akses untuk memindai dan memutar file audio yang disimpan di perangkat Anda.';

  @override
  String get localMusicAddFolder => 'Tambah Folder Musik';

  @override
  String get localMusicScanNow => 'Pindai Sekarang';

  @override
  String localMusicScanFailed(String message) {
    return 'Pemindaian gagal: $message';
  }

  @override
  String get localMusicScanning => 'Memindai perangkat untuk file audio...';

  @override
  String get localMusicEmpty => 'Tidak ada musik lokal ditemukan';

  @override
  String get localMusicSearchEmpty => 'Lagu tidak ditemukan.';

  @override
  String get localMusicShuffle => 'Acak';

  @override
  String get localMusicPlayAll => 'Putar Semua';

  @override
  String get localMusicSearchHint => 'Cari musik lokal...';

  @override
  String get localMusicRescanDevice => 'Pindai Ulang Perangkat';

  @override
  String get localMusicRemoveFolder => 'Hapus folder';

  @override
  String get localMusicMusicFolders => 'Folder Musik';

  @override
  String localMusicTrackCount(int count) {
    return '$count lagu';
  }

  @override
  String get buttonCancel => 'Batal';

  @override
  String get buttonDelete => 'Hapus';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'Perbarui';

  @override
  String get buttonDownload => 'Unduh';

  @override
  String get buttonShare => 'Bagikan';

  @override
  String get buttonLater => 'Nanti';

  @override
  String get buttonInfo => 'Info';

  @override
  String get buttonMore => 'Lebih Banyak';

  @override
  String get dialogDeleteTrack => 'Hapus Lagu';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Apakah Anda yakin ingin menghapus \"$title\" dari perangkat? Tindakan ini tidak bisa dibatalkan.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Lagu ini juga akan dihapus dari:';

  @override
  String get dialogDontAskAgain => 'Jangan tanyakan lagi';

  @override
  String get dialogDeletePlugin => 'Hapus Plugin?';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'Apakah Anda yakin ingin menghapus \"$name\"? Tindakan ini akan menghapus filenya secara permanen.';
  }

  @override
  String get dialogUpdateAvailable => 'Pembaruan Tersedia';

  @override
  String get dialogUpdateNow => 'Perbarui Sekarang';

  @override
  String get dialogDownloadPlaylist => 'Unduh playlist';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Apakah Anda ingin mengunduh $count lagu dari \"$title\"? Ini akan menambahkan mereka ke antrean unduhan.';
  }

  @override
  String get dialogDownloadAll => 'Unduh Semua';

  @override
  String get playlistEdit => 'Edit Playlist';

  @override
  String get playlistShareFile => 'Bagikan file';

  @override
  String get playlistExportFile => 'Ekspor File';

  @override
  String get playlistPlay => 'Putar';

  @override
  String get playlistAddToQueue => 'Tambah Playlist ke Antrean';

  @override
  String get playlistShare => 'Bagikan Playlist';

  @override
  String get playlistDelete => 'Hapus Playlist';

  @override
  String get playlistEmptyState => 'Belum Ada Lagu!';

  @override
  String get playlistAvailableOffline => 'Tersedia Offline';

  @override
  String get playlistShuffle => 'Acak';

  @override
  String get playlistMoreOptions => 'Opsi Lainnya';

  @override
  String get playlistNoMatchSearch => 'Tidak ada playlist yang cocok';

  @override
  String get playlistCreateNew => 'Buat Playlist Baru';

  @override
  String get playlistCreateFirstOne =>
      'Belum ada playlist. Buat satu untuk memulai!';

  @override
  String get addToPlaylistNoSongSelected => 'Tidak ada lagu yang dipilih';

  @override
  String get createPlaylistDialogBarrierLabel => 'Dialog buat playlist';

  @override
  String get createPlaylistDialogNameHint => 'Lagu Santai';

  @override
  String get createPlaylistDialogCreate => 'Buat';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lagu',
      one: '1 Lagu',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title dihapus dari $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Gagal memuat playlist';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsPlugins => 'Plugin';

  @override
  String get settingsPluginsSubtitle => 'Pasang, muat, dan kelola plugin.';

  @override
  String get settingsUpdates => 'Pembaruan';

  @override
  String get settingsUpdatesSubtitle => 'Periksa pembaruan baru';

  @override
  String get settingsDownloads => 'Unduhan';

  @override
  String get settingsDownloadsSubtitle =>
      'Lokasi unduhan, kualitas unduhan, dan lainnya...';

  @override
  String get settingsLocalTracks => 'Lagu Lokal';

  @override
  String get settingsLocalTracksSubtitle =>
      'Pindai, kelola folder, dan pemindaian otomatis.';

  @override
  String get settingsPlayer => 'Player Settings';

  @override
  String get settingsPlayerSubtitle => 'Stream quality, Auto Play, etc.';

  @override
  String get settingsPluginDefaults => 'Plugin Defaults';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Discover source, resolver priority.';

  @override
  String get settingsUIElements => 'Antarmuka & Layanan';

  @override
  String get settingsUIElementsSubtitle =>
      'Geser otomatis bagan, penyesuaian antarmuka, dll.';

  @override
  String get settingsLastFM => 'Pengaturan Last.FM';

  @override
  String get settingsLastFMSubtitle =>
      'Kunci API, rahasia, dan pengaturan pencatatan putar.';

  @override
  String get settingsStorage => 'Penyimpanan';

  @override
  String get settingsStorageSubtitle =>
      'Cadangan, Cache, Riwayat, Pemulihan dan lainnya...';

  @override
  String get settingsLanguageCountry => 'Bahasa & Negara';

  @override
  String get settingsLanguageCountrySubtitle => 'Pilih bahasa dan negara Anda.';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsAboutSubtitle => 'Info aplikasi, versi, dan lisensi';

  @override
  String get settingsScanning => 'Pemindaian';

  @override
  String get settingsMusicFolders => 'Folder Musik';

  @override
  String get settingsQuality => 'Kualitas Audio';

  @override
  String get settingsHistory => 'Riwayat';

  @override
  String get settingsBackupRestore => 'Cadangkan & Pulihkan';

  @override
  String get settingsAutomatic => 'Otomatis';

  @override
  String get settingsDangerZone => 'Zona Bahaya';

  @override
  String get settingsScrobbling => 'Pencatatan Putar (Scrobble)';

  @override
  String get settingsAuthentication => 'Autentikasi';

  @override
  String get settingsHomeScreen => 'Layar Beranda';

  @override
  String get settingsChartVisibility => 'Visibilitas Bagan';

  @override
  String get settingsLocation => 'Lokasi';

  @override
  String get pluginRepositoryTitle => 'Repositori Plugin';

  @override
  String get pluginRepositorySubtitle =>
      'Temukan plugin dari sumber URL jarak jauh';

  @override
  String get pluginRepositoryAddAction => 'Tambah Repositori';

  @override
  String get pluginRepositoryAddTitle => 'Tambah Repositori';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Masukkan URL file JSON repositori plugin yang valid.';

  @override
  String get pluginRepositoryEmpty => 'Belum ada repositori yang ditambahkan.';

  @override
  String get pluginRepositoryUrlCopied =>
      'URL Repositori disalin ke papan klip';

  @override
  String get pluginRepositoryNoDescription => 'Deskripsi tidak tersedia.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Pembaruan tidak diketahui';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugin',
      one: '1 plugin',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Gagal memuat repositori.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'URL atau file repositori tidak valid.';

  @override
  String get pluginRepositoryErrorRemove => 'Gagal menghapus repositori.';

  @override
  String pluginRepositoryError(String message) {
    return 'Error: $message';
  }

  @override
  String get dialogAddingToDownloadQueue => 'Menambahkan ke antrean unduhan';

  @override
  String get emptyNoInternet => 'Tidak Ada Koneksi Internet!';

  @override
  String get emptyNoContentPlugin =>
      'Tidak ada plugin konten dimuat. Muat Content Resolver di Pengelola Plugin.';

  @override
  String get emptyRefreshingSource =>
      'Menyegarkan sumber Discover... Sumber sebelumnya tidak lagi tersedia.';

  @override
  String get emptyNoTracks => 'Tidak ada lagu tersedia';

  @override
  String get emptyNoResults => 'Pencarian tidak ditemukan';

  @override
  String snackbarDeletedTrack(String title) {
    return 'Berhasil menghapus \"$title\"';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Gagal menghapus \"$title\"';
  }

  @override
  String get snackbarAddedToNextQueue => 'Ditambahkan untuk Diputar Berikutnya';

  @override
  String get snackbarAddedToQueue => 'Ditambahkan ke Antrean';

  @override
  String snackbarAddedToLiked(String title) {
    return '\"$title\" ditambahkan ke Favorit!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Memutar $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'Menambahkan $name ke Antrean';
  }

  @override
  String get snackbarPlaylistQueued =>
      'Playlist ditambahkan ke antrean unduhan';

  @override
  String get snackbarPlaylistUpdated => 'Playlist Diperbarui!';

  @override
  String get snackbarNoInternet => 'Koneksi internet terputus.';

  @override
  String get snackbarImportFailed => 'Impor Gagal!';

  @override
  String get snackbarImportCompleted => 'Impor Selesai';

  @override
  String get snackbarBackupFailed => 'Cadangan Gagal!';

  @override
  String snackbarExportedTo(String path) {
    return 'Diekspor ke: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'ID Media disalin';

  @override
  String get snackbarLinkCopied => 'Tautan disalin';

  @override
  String get snackbarNoLinkAvailable => 'Tautan tidak tersedia';

  @override
  String get snackbarCouldNotOpenLink => 'Tidak dapat membuka tautan';

  @override
  String snackbarPreparingDownload(String title) {
    return 'Menyiapkan unduhan untuk $title...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '\"$title\" sudah diunduh.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '\"$title\" sudah ada di antrean.';
  }

  @override
  String snackbarDownloaded(String title) {
    return 'Selesai mengunduh $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'Error: Layanan unduhan tidak tersedia.';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Menambahkan $count lagu ke antrean unduhan';
  }

  @override
  String get snackbarDeleteTrackFailDevice =>
      'Gagal menghapus trek dari penyimpanan perangkat.';

  @override
  String get searchHintExplore => 'Apa yang ingin Anda dengarkan?';

  @override
  String get searchHintLibrary => 'Cari di perpustakaan...';

  @override
  String get searchHintOfflineMusic => 'Cari lagu Anda...';

  @override
  String get searchHintPlaylists => 'Cari playlist...';

  @override
  String get searchStartTyping => 'Mulai mengetik untuk mencari...';

  @override
  String get searchNoSuggestions => 'Saran tidak ditemukan!';

  @override
  String get searchNoResults =>
      'Pencarian tidak ditemukan!\nSilakan coba kata kunci atau sumber lain.';

  @override
  String get searchFailed => 'Pencarian gagal!';

  @override
  String get searchDiscover => 'Temukan musik keren...';

  @override
  String get searchSources => 'SUMBER';

  @override
  String get searchNoPlugins => 'Plugin tidak terpasang';

  @override
  String get searchTracks => 'Lagu';

  @override
  String get searchAlbums => 'Album';

  @override
  String get searchArtists => 'Artis';

  @override
  String get searchPlaylists => 'Playlist';

  @override
  String get exploreDiscover => 'Temukan';

  @override
  String get exploreRecently => 'Baru-baru Ini';

  @override
  String get exploreLastFmPicks => 'Rekomendasi Last.Fm';

  @override
  String get exploreFailedToLoad => 'Gagal memuat bagian beranda.';

  @override
  String get libraryTitle => 'Perpustakaan';

  @override
  String get libraryEmptyState =>
      'Perpustakaan Anda sepi. Tambahkan lagu untuk meramaikannya!';

  @override
  String libraryIn(String playlistName) {
    return 'di $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Tambah ke Playlist';

  @override
  String get menuSmartReplace => 'Smart Replace';

  @override
  String get menuShare => 'Bagikan';

  @override
  String get menuAvailableOffline => 'Tersedia Offline';

  @override
  String get menuDownload => 'Unduh';

  @override
  String get menuOpenOriginalLink => 'Buka tautan asli';

  @override
  String get menuDeleteTrack => 'Hapus';

  @override
  String get songInfoTitle => 'Judul';

  @override
  String get songInfoArtist => 'Artis';

  @override
  String get songInfoAlbum => 'Album';

  @override
  String get songInfoMediaId => 'ID Media';

  @override
  String get songInfoCopyId => 'Salin ID';

  @override
  String get songInfoCopyLink => 'Salin Tautan';

  @override
  String get songInfoOpenBrowser => 'Buka di browser';

  @override
  String get tooltipRemoveFromLibrary => 'Hapus dari Perpustakaan';

  @override
  String get tooltipSaveToLibrary => 'Simpan ke Perpustakaan';

  @override
  String get tooltipOpenOriginalLink => 'Buka Tautan Asli';

  @override
  String get tooltipShuffle => 'Acak';

  @override
  String get tooltipAvailableOffline => 'Tersedia Offline';

  @override
  String get tooltipDownloadPlaylist => 'Unduh playlist';

  @override
  String get tooltipMoreOptions => 'Opsi Lainnya';

  @override
  String get tooltipInfo => 'Info';

  @override
  String get appuiTitle => 'Antarmuka & Layanan';

  @override
  String get appuiAutoSlideCharts => 'Geser Bagan Otomatis';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Geser bagan secara otomatis di beranda.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Tampilkan saran dari Last.FM. Diperlukan masuk & mulai ulang.';

  @override
  String get appuiNoChartsAvailable =>
      'Tidak ada bagan tersedia. Pasang plugin penyedia bagan.';

  @override
  String get appuiLoginToLastFm => 'Silakan masuk ke Last.FM terlebih dahulu.';

  @override
  String get appuiShowInCarousel => 'Tampilkan di korsel beranda.';

  @override
  String get countrySettingTitle => 'Negara & Bahasa';

  @override
  String get countrySettingAutoDetect => 'Deteksi Negara Otomatis';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Deteksi negara Anda secara otomatis saat aplikasi dibuka.';

  @override
  String get countrySettingCountryLabel => 'Negara';

  @override
  String get countrySettingLanguageLabel => 'Bahasa';

  @override
  String get countrySettingSystemDefault => 'Default Sistem';

  @override
  String get downloadSettingTitle => 'Unduhan';

  @override
  String get downloadSettingQuality => 'Kualitas Unduhan';

  @override
  String get downloadSettingQualitySubtitle =>
      'Kualitas audio default untuk lagu yang diunduh.';

  @override
  String get downloadSettingFolder => 'Folder Unduhan';

  @override
  String get downloadSettingResetFolder => 'Reset Folder Unduhan';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Kembalikan jalur folder unduhan bawaan.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'Scrobble Lagu';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Kirim lagu yang diputar ke profil Last.FM Anda.';

  @override
  String get lastfmAuthFirst => 'Autentikasi API Last.FM Terlebih Dahulu.';

  @override
  String get lastfmAuthenticatedAs => 'Terkoneksi sebagai';

  @override
  String get lastfmAuthFailed => 'Autentikasi gagal:';

  @override
  String get lastfmNotAuthenticated => 'Tidak terkoneksi';

  @override
  String get lastfmSteps =>
      'Langkah autentikasi:\n1. Buat / buka akun Last.FM di last.fm\n2. Dapatkan API Key di last.fm/api/account/create\n3. Masukkan API Key & Secret Anda di bawah\n4. Ketuk \"Mulai Autentikasi\" dan setujui di browser\n5. Ketuk \"Simpan Kunci Sesi\" untuk menyelesaikan';

  @override
  String get lastfmApiKey => 'API Key';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. Mulai Autentikasi';

  @override
  String get lastfmGetSession => '2. Simpan Kunci Sesi';

  @override
  String get lastfmRemoveKeys => 'Hapus Kunci API';

  @override
  String get lastfmStartAuthFirst =>
      'Mulai autentikasi dulu, lalu setujui di browser.';

  @override
  String get localSettingTitle => 'Lagu Lokal';

  @override
  String get localSettingAutoScan => 'Pindai Otomatis Saat Mulai';

  @override
  String get localSettingAutoScanSubtitle =>
      'Pindai lagu lokal secara otomatis saat aplikasi dibuka.';

  @override
  String get localSettingLastScan => 'Pemindaian Terakhir';

  @override
  String get localSettingNeverScanned => 'Belum Pernah';

  @override
  String get localSettingScanInProgress => 'Sedang memindai...';

  @override
  String get localSettingScanNowSubtitle =>
      'Picu pemindaian perpustakaan penuh secara manual.';

  @override
  String get localSettingNoFolders =>
      'Belum ada folder. Tambahkan folder untuk mulai memindai.';

  @override
  String get localSettingAddFolder => 'Tambah Folder';

  @override
  String get playerSettingTitle => 'Pengaturan Pemutar';

  @override
  String get playerSettingStreamingHeader => 'Streaming';

  @override
  String get playerSettingStreamQuality => 'Kualitas Streaming';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Kualitas audio global untuk pemutaran musik online.';

  @override
  String get playerSettingQualityLow => 'Rendah';

  @override
  String get playerSettingQualityMedium => 'Sedang';

  @override
  String get playerSettingQualityHigh => 'Tinggi';

  @override
  String get playerSettingPlaybackHeader => 'Pemutaran';

  @override
  String get playerSettingAutoPlay => 'Putar Otomatis';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Putar lagu serupa secara otomatis saat antrean habis.';

  @override
  String get playerSettingAutoFallback => 'Pemutaran Cadangan Otomatis';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Jika plugin mati, coba penyedia lain yang cocok (hanya untuk pemutaran).';

  @override
  String get playerSettingCrossfade => 'Crossfade';

  @override
  String get playerSettingCrossfadeOff => 'Mati';

  @override
  String get playerSettingCrossfadeInstant => 'Transisi lagu instan';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Transisi tumpang tindih $seconds detik';
  }

  @override
  String get playerSettingEqualizer => 'Equalizer';

  @override
  String get playerSettingEqualizerActive => 'Aktif';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Aktif — Preset $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'Equalizer parametrik 10-band via FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Default Plugin';

  @override
  String get pluginDefaultsDiscoverHeader => 'Sumber Discover';

  @override
  String get pluginDefaultsNoResolver =>
      'Resolver konten tidak dimuat. Pasang plugin untuk memilih sumber Discover.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Gunakan resolver konten pertama yang tersedia.';

  @override
  String get pluginDefaultsPriorityHeader => 'Prioritas Resolver';

  @override
  String get pluginDefaultsNoPriority =>
      'Resolver konten tidak dimuat. Pengaturan prioritas akan muncul setelah plugin dimuat.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Seret untuk mengatur urutan. Resolver dengan prioritas lebih tinggi akan dicoba terlebih dahulu.';

  @override
  String get pluginDefaultsLyricsHeader => 'Prioritas Lirik';

  @override
  String get pluginDefaultsLyricsNone => 'Penyedia lirik tidak dimuat.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Seret untuk mengatur prioritas penyedia lirik.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Saran Pencarian';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'Penyedia saran pencarian tidak dimuat.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Tidak Ada';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Gunakan riwayat pencarian saja.';

  @override
  String get storageSettingTitle => 'Penyimpanan';

  @override
  String get storageClearHistoryEvery => 'Bersihkan Riwayat Setiap';

  @override
  String get storageClearHistorySubtitle =>
      'Bersihkan riwayat putar otomatis setelah periode terpilih.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hari',
      one: '1 Hari',
    );
    return '$_temp0';
  }

  @override
  String get storageBackupLocation => 'Lokasi Cadangan';

  @override
  String get storageBackupLocationAndroid =>
      'Folder Unduhan / direktori data aplikasi';

  @override
  String get storageBackupLocationDownloads => 'Folder Unduhan';

  @override
  String get storageCreateBackup => 'Buat Cadangan';

  @override
  String get storageCreateBackupSubtitle =>
      'Simpan pengaturan dan data Anda ke file cadangan.';

  @override
  String storageBackupCreatedAt(String path) {
    return 'Cadangan berhasil dibuat di $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Gagal membagikan cadangan: $error';
  }

  @override
  String get storageBackupFailed => 'Cadangan Gagal!';

  @override
  String get storageRestoreBackup => 'Pulihkan Cadangan';

  @override
  String get storageRestoreBackupSubtitle =>
      'Pulihkan pengaturan dan data Anda dari file cadangan.';

  @override
  String get storageAutoBackup => 'Cadangkan Otomatis';

  @override
  String get storageAutoBackupSubtitle =>
      'Buat cadangan data Anda secara berkala secara otomatis.';

  @override
  String get storageAutoLyrics => 'Simpan Lirik Otomatis';

  @override
  String get storageAutoLyricsSubtitle =>
      'Simpan lirik secara otomatis saat lagu diputar.';

  @override
  String get storageResetApp => 'Reset Aplikasi StreamBeats';

  @override
  String get storageResetAppSubtitle =>
      'Hapus semua data dan kembalikan aplikasi ke setelan pabrik.';

  @override
  String get storageResetConfirmTitle => 'Konfirmasi Reset';

  @override
  String get storageResetConfirmMessage =>
      'Apakah Anda yakin ingin mereset StreamBeats? Semua data Anda akan dihapus permanen.';

  @override
  String get storageResetButton => 'Reset';

  @override
  String get storageResetSuccess =>
      'Aplikasi berhasil dikembalikan ke setelan default.';

  @override
  String get storageLocationDialogTitle => 'Lokasi Cadangan';

  @override
  String get storageLocationAndroid =>
      'Cadangan disimpan di:\n\n1. Folder Downloads\n2. Android/data/ls.streambeats.musicplayer/data\n\nSalin file cadangan dari lokasi tersebut.';

  @override
  String get storageLocationOther =>
      'Cadangan disimpan di folder Downloads. Silakan salin dari sana.';

  @override
  String get storageRestoreOptionsTitle => 'Opsi Pemulihan';

  @override
  String get storageRestoreOptionsDesc =>
      'Pilih data yang ingin Anda pulihkan dari file cadangan. Uncheck item yang tidak ingin diimpor. Secara default semua dipilih.';

  @override
  String get storageRestoreSelectAll => 'Pilih Semua';

  @override
  String get storageRestoreMediaItems =>
      'Item media (lagu, track, perpustakaan)';

  @override
  String get storageRestoreSearchHistory => 'Riwayat pencarian';

  @override
  String get storageRestoreContinue => 'Lanjutkan';

  @override
  String get storageRestoreNoFile => 'Tidak ada file yang dipilih.';

  @override
  String get storageRestoreSaveFailed => 'Gagal menyimpan file terpilih.';

  @override
  String get storageRestoreConfirmTitle => 'Konfirmasi Pemulihan';

  @override
  String get storageRestoreConfirmPrefix =>
      'Ini akan menimpa dan menggabungkan data saat ini dengan file cadangan:';

  @override
  String get storageRestoreConfirmSuffix =>
      'Data Anda saat ini akan diubah. Lanjutkan?';

  @override
  String get storageRestoreYes => 'Ya, Pulihkan';

  @override
  String get storageRestoreNo => 'Batal';

  @override
  String get storageRestoring => 'Memulihkan data...';

  @override
  String get storageRestoreMediaBullet => '• Item Media';

  @override
  String get storageRestoreHistoryBullet => '• Riwayat Pencarian';

  @override
  String get storageUnexpectedError =>
      'Terjadi kesalahan tidak terduga saat memulihkan.';

  @override
  String get storageRestoreCompleted => 'Pemulihan Selesai';

  @override
  String get storageRestoreFailedTitle => 'Pemulihan Gagal';

  @override
  String get storageRestoreSuccessMessage =>
      'Data berhasil dipulihkan! Mulai ulang aplikasi sekarang untuk hasil terbaik.';

  @override
  String get storageRestoreFailedMessage =>
      'Proses pemulihan gagal dengan error berikut:';

  @override
  String get storageRestoreUnknownError =>
      'Error tidak dikenal saat pemulihan.';

  @override
  String get storageRestoreRestartHint =>
      'Silakan restart aplikasi untuk konsistensi data.';

  @override
  String get updateSettingTitle => 'Pembaruan';

  @override
  String get updateAppUpdatesHeader => 'Pembaruan Aplikasi';

  @override
  String get updateCheckForUpdates => 'Periksa Pembaruan';

  @override
  String get updateCheckSubtitle =>
      'Periksa apakah ada versi baru StreamBeats.';

  @override
  String get updateAutoNotify => 'Notifikasi Pembaruan Otomatis';

  @override
  String get updateAutoNotifySubtitle =>
      'Beri tahu di awal aplikasi jika ada versi baru.';

  @override
  String get updateCheckTitle => 'Periksa Pembaruan';

  @override
  String get updateUpToDate => 'StreamBeats sudah menggunakan versi terbaru!!!';

  @override
  String get updateViewPreRelease => 'Lihat Versi Pra-Rilis Terbaru';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Versi Saat Ini: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'Versi baru StreamBeats telah tersedia!!';

  @override
  String updateVersion(String ver, String build) {
    return 'Versi: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Unduh Sekarang';

  @override
  String get updateChecking => 'Memeriksa ketersediaan versi terbaru...';

  @override
  String get timerTitle => 'Sleep Timer';

  @override
  String get timerInterludeMessage =>
      'Bersiap menghentikan pemutaran musik dalam...';

  @override
  String get timerHours => 'Jam';

  @override
  String get timerMinutes => 'Menit';

  @override
  String get timerSeconds => 'Detik';

  @override
  String get timerStop => 'Hentikan Timer';

  @override
  String get timerFinishedMessage =>
      'Musik telah dihentikan. Selamat Tidur 🥰.';

  @override
  String get timerGotIt => 'Mengerti!';

  @override
  String get timerSetTimeError => 'Silakan atur waktu terlebih dahulu';

  @override
  String get timerStart => 'Mulai Timer';

  @override
  String get notificationsTitle => 'Notifikasi';

  @override
  String get notificationsEmpty => 'Belum ada notifikasi!';

  @override
  String get recentsTitle => 'Riwayat';

  @override
  String playlistByCreator(String creator) {
    return 'oleh $creator';
  }

  @override
  String get playlistTypeAlbum => 'Album';

  @override
  String get playlistTypePlaylist => 'Playlist';

  @override
  String get playlistYou => 'Anda';

  @override
  String get pluginManagerTitle => 'Plugin';

  @override
  String get pluginManagerEmpty =>
      'Belum ada plugin terpasang.\nKetuk + untuk menambahkan file .bex.';

  @override
  String get pluginManagerFilterAll => 'Semua';

  @override
  String get pluginManagerFilterContent => 'Content Resolvers';

  @override
  String get pluginManagerFilterCharts => 'Chart Providers';

  @override
  String get pluginManagerFilterLyrics => 'Lyrics Providers';

  @override
  String get pluginManagerFilterSuggestions => 'Saran Pencarian';

  @override
  String get pluginManagerFilterImporters => 'Content Importers';

  @override
  String get pluginManagerTooltipRefresh => 'Segarkan';

  @override
  String get pluginManagerTooltipInstall => 'Pasang Plugin';

  @override
  String get pluginManagerNoMatch =>
      'Tidak ada plugin yang cocok dengan filter ini';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Gagal memilih file: $error';
  }

  @override
  String get pluginManagerInstalling => 'Memasang plugin...';

  @override
  String get pluginManagerTypeContentResolver => 'Content Resolver';

  @override
  String get pluginManagerTypeChartProvider => 'Chart Provider';

  @override
  String get pluginManagerTypeLyricsProvider => 'Lyrics Provider';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Saran Pencarian';

  @override
  String get pluginManagerTypeContentImporter => 'Content Importer';

  @override
  String get pluginManagerDeleteTitle => 'Hapus Plugin?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Apakah Anda yakin ingin menghapus \"$name\"? Tindakan ini menghapus filenya secara permanen.';
  }

  @override
  String get pluginManagerDeleteAction => 'Hapus';

  @override
  String get pluginManagerCancel => 'Batal';

  @override
  String get pluginManagerEnablePlugin => 'Aktifkan Plugin';

  @override
  String get pluginManagerUnloadPlugin => 'Nonaktifkan Plugin';

  @override
  String get pluginManagerDeleting => 'Menghapus...';

  @override
  String get pluginManagerApiKeysTitle => 'API Keys';

  @override
  String get pluginManagerApiKeysSaved => 'API Keys berhasil disimpan';

  @override
  String get pluginManagerSave => 'Simpan';

  @override
  String get pluginManagerDetailVersion => 'Versi';

  @override
  String get pluginManagerDetailType => 'Tipe';

  @override
  String get pluginManagerDetailPublisher => 'Penerbit';

  @override
  String get pluginManagerDetailLastUpdated => 'Pembaruan Terakhir';

  @override
  String get pluginManagerDetailCreated => 'Dibuat Pada';

  @override
  String get pluginManagerDetailHomepage => 'Situs Web';

  @override
  String get pluginManagerDowngradeTitle => 'Downgrade Plugin?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'Anda akan memasang versi yang lebih lama atau sama dari \"$name\". Lanjutkan?';
  }

  @override
  String get pluginManagerDowngradeAction => 'Tetap Pasang';

  @override
  String get pluginManagerDeleteStorageTitle => 'Hapus Data Plugin?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Hapus juga API keys dan pengaturan tersimpan untuk \"$name\"?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Simpan Data';

  @override
  String get pluginManagerDeleteStorageRemove => 'Hapus Data';

  @override
  String get segmentsSheetTitle => 'Segmen';

  @override
  String get segmentsSheetEmpty => 'Tidak ada segmen tersedia';

  @override
  String get segmentsSheetUntitled => 'Segmen Tanpa Judul';

  @override
  String get smartReplaceTitle => 'Smart Replace';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Pilih pengganti yang dapat diputar untuk \"$title\" dan perbarui referensi playlist tersimpan.';
  }

  @override
  String get smartReplaceClose => 'Tutup';

  @override
  String get smartReplaceNoMatch => 'Pengganti tidak ditemukan';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Tidak ada plugin resolver aktif yang mengembalikan kecocokan yang kuat.';

  @override
  String get smartReplaceBestMatch => 'Kecocokan terbaik';

  @override
  String get smartReplaceSearchFailed => 'Pencarian gagal';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Smart Replace gagal: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Pengganti berhasil diterapkan$queue.';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return 'Digantikan di $count playlist$plural$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' dan memperbarui antrean';

  @override
  String get playerUnknownQueue => 'Tidak Diketahui';

  @override
  String playerLiked(String title) {
    return '\"$title\" disukai!';
  }

  @override
  String playerUnliked(String title) {
    return '\"$title\" batal disukai!';
  }

  @override
  String get offlineNoDownloads => 'Tidak Ada Unduhan';

  @override
  String get offlineTitle => 'Mode Offline';

  @override
  String get offlineSearchHint => 'Cari lagu Anda...';

  @override
  String get offlineRefreshTooltip => 'Segarkan Unduhan';

  @override
  String get offlineCloseSearch => 'Tutup Pencarian';

  @override
  String get offlineSearchTooltip => 'Cari';

  @override
  String get offlineOpenFailed =>
      'Gagal membuka trek offline ini. Coba segarkan unduhan.';

  @override
  String get offlinePlayFailed =>
      'Gagal memutar lagu offline ini. Silakan coba kembali.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lagu',
      one: '1 Lagu',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Gagal memuat album';

  @override
  String get aboutCraftingSubtitle => 'Merangkai simfoni dalam baris kode.';

  @override
  String get aboutFollowGitHub => 'Ikuti di GitHub';

  @override
  String get aboutSendInquiry => 'Kirim penawaran bisnis';

  @override
  String get aboutCreativeHighlights => 'Pembaruan dan sorotan kreatif';

  @override
  String get aboutTipQuote =>
      'Menikmati StreamBeats? Dukungan kecil Anda sangat berarti. ';

  @override
  String get aboutTipButton => 'Saya ingin membantu';

  @override
  String get aboutTipDesc => 'Saya ingin StreamBeats terus berkembang.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Detail Lagu';

  @override
  String get songInfoSectionTechnical => 'Informasi Teknis';

  @override
  String get songInfoSectionActions => 'Tindakan';

  @override
  String get songInfoLabelTitle => 'Judul';

  @override
  String get songInfoLabelArtist => 'Artis';

  @override
  String get songInfoLabelAlbum => 'Album';

  @override
  String get songInfoLabelDuration => 'Durasi';

  @override
  String get songInfoLabelSource => 'Sumber';

  @override
  String get songInfoLabelMediaId => 'ID Media';

  @override
  String get songInfoLabelPluginId => 'ID Plugin';

  @override
  String get songInfoIdCopied => 'ID Media disalin';

  @override
  String get songInfoLinkCopied => 'Tautan disalin';

  @override
  String get songInfoNoLink => 'Tautan tidak tersedia';

  @override
  String get songInfoOpenFailed => 'Tidak dapat membuka tautan';

  @override
  String get songInfoUpdateMetadata => 'Ambil metadata terbaru';

  @override
  String get songInfoMetadataUpdated => 'Metadata diperbarui';

  @override
  String get songInfoMetadataUpdateFailed => 'Gagal memperbarui metadata';

  @override
  String get songInfoMetadataUnavailable =>
      'Pembaruan metadata tidak tersedia untuk sumber ini';

  @override
  String get songInfoSearchTitle => 'Cari lagu ini di StreamBeats';

  @override
  String get songInfoSearchArtist => 'Cari artis ini di StreamBeats';

  @override
  String get songInfoSearchAlbum => 'Cari album ini di StreamBeats';

  @override
  String get eqTitle => 'Equalizer';

  @override
  String get eqResetTooltip => 'Reset ke Awal';

  @override
  String get chartNoItems => 'Tidak ada item di bagan ini';

  @override
  String get chartLoadFailed => 'Gagal memuat bagan';

  @override
  String get chartPlay => 'Putar';

  @override
  String get chartResolving => 'Menghubungkan...';

  @override
  String get chartReady => 'Siap';

  @override
  String get chartAddToPlaylist => 'Tambah ke Playlist';

  @override
  String get chartNoResolver =>
      'Penyedia konten tidak dimuat. Pasang plugin untuk memutar.';

  @override
  String get chartResolveFailed => 'Gagal menghubungkan. Mencoba mencari...';

  @override
  String get chartNoResolverAdd => 'Penyedia konten tidak dimuat.';

  @override
  String get chartNoMatch =>
      'Tidak ditemukan kecocokan. Coba cari secara manual.';

  @override
  String get chartStatPeak => 'Puncak';

  @override
  String get chartStatWeeks => 'Minggu';

  @override
  String get chartStatChange => 'Perubahan';

  @override
  String menuSharePreparing(String title) {
    return 'Menyiapkan $title untuk dibagikan.';
  }

  @override
  String get menuOpenLinkFailed => 'Tidak dapat membuka tautan';

  @override
  String get localMusicFolders => 'Folder Musik';

  @override
  String get localMusicCloseSearch => 'Tutup pencarian';

  @override
  String get localMusicOpenSearch => 'Cari';

  @override
  String get localMusicNoMusicFound => 'Musik lokal tidak ditemukan';

  @override
  String get localMusicNoSearchResults => 'Lagu tidak ditemukan.';

  @override
  String get importSongsTitle => 'Impor Lagu';

  @override
  String get importNoPluginsLoaded =>
      'Plugin pengimpor konten tidak dimuat.\nPasang plugin pengimpor untuk mengimpor playlist dari layanan eksternal.';

  @override
  String get importStreamBeatsFiles => 'Impor File StreamBeats';

  @override
  String get importM3UFiles => 'Impor Playlist M3U';

  @override
  String get importM3UNameDialogTitle => 'Nama Playlist';

  @override
  String get importM3UNameHint => 'Masukkan nama untuk playlist ini';

  @override
  String get importM3UNoTracks => 'Tidak ada lagu valid ditemukan di file M3U.';

  @override
  String get importNoteTitle => 'Catatan';

  @override
  String get importNoteMessage =>
      'Anda hanya dapat mengimpor file yang dibuat oleh StreamBeats.\nJika file Anda dari sumber lain, itu tidak akan berfungsi. Lanjutkan?';

  @override
  String get importTitle => 'Impor';

  @override
  String get importCheckingUrl => 'Memeriksa URL...';

  @override
  String get importFetchingTracks => 'Mengambil lagu...';

  @override
  String get importSavingToLibrary => 'Menyimpan ke perpustakaan...';

  @override
  String get importPasteUrlHint =>
      'Tempel URL playlist atau album untuk diimpor';

  @override
  String get importAction => 'Impor';

  @override
  String importTrackCount(int count) {
    return '$count lagu';
  }

  @override
  String get importResolving => 'Menghubungkan...';

  @override
  String importResolvingProgress(int done, int total) {
    return 'Menghubungkan lagu: $done / $total';
  }

  @override
  String get importReviewTitle => 'Tinjau Impor';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$resolved berhasil, $failed gagal dari total $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Simpan $count Lagu';
  }

  @override
  String importTracksSaved(int count) {
    return '$count lagu berhasil disimpan!';
  }

  @override
  String get importDone => 'Selesai';

  @override
  String get importMore => 'Impor Lebih Banyak';

  @override
  String get importUnknownError => 'Kesalahan tidak dikenal';

  @override
  String get importTryAgain => 'Coba Lagi';

  @override
  String get importSkipTrack => 'Lewati lagu ini';

  @override
  String get importMatchOptions => 'Opsi pencocokan';

  @override
  String get importAutoMatched => 'Cocok otomatis';

  @override
  String get importUserSelected => 'Dipilih';

  @override
  String get importSkipped => 'Dilewati';

  @override
  String get importNoMatch => 'Tidak ditemukan kecocokan';

  @override
  String get importReorderTip =>
      'Tekan lama playlist untuk mengatur ulang urutan';

  @override
  String get importErrorCannotHandleUrl =>
      'Plugin ini tidak dapat memproses URL yang diberikan.';

  @override
  String get importErrorUnexpectedResponse =>
      'Respon tidak terduga dari plugin.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Gagal memeriksa URL: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Gagal mengambil info koleksi: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Gagal mengambil lagu: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Gagal menyimpan playlist: $error';
  }

  @override
  String get playlistPinToTop => 'Sematkan di Atas';

  @override
  String get playlistUnpin => 'Lepas Sematan';

  @override
  String get snackbarImportingMedia => 'Mengimpor Media...';

  @override
  String get snackbarPlaylistSaved => 'Playlist disimpan ke perpustakaan!';

  @override
  String get snackbarInvalidFileFormat => 'Format File Tidak Valid';

  @override
  String get snackbarMediaItemImported => 'Item Media Diimpor';

  @override
  String get snackbarPlaylistImported => 'Playlist Diimpor';

  @override
  String get snackbarOpenImportForUrl =>
      'Buka menu Impor di Perpustakaan untuk mengimpor dari URL ini.';

  @override
  String get snackbarProcessingFile => 'Memproses File...';

  @override
  String snackbarPreparingShare(String title) {
    return 'Menyiapkan $title untuk dibagikan';
  }

  @override
  String snackbarPreparingExport(String title) {
    return 'Menyiapkan $title untuk diekspor.';
  }

  @override
  String get pluginManagerTabInstalled => 'Terpasang';

  @override
  String get pluginManagerTabStore => 'Toko Plugin';

  @override
  String get pluginManagerSelectPackage => 'Pilih Paket Plugin (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'Plugin menggunakan versi manifest usang. Beberapa fitur mungkin bermasalah.';

  @override
  String get pluginManagerStatusActive => 'Aktif';

  @override
  String get pluginManagerStatusInactive => 'Tidak Aktif';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Diperbarui $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugin tersedia',
      one: '1 plugin tersedia',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Manifest usang. Fitur mungkin bermasalah.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Penerbit tidak dikenal';

  @override
  String get pluginRepositoryActionRetry => 'Coba Lagi';

  @override
  String get pluginRepositoryActionOutdated => 'Usang';

  @override
  String get pluginRepositoryActionInstalled => 'Terpasang';

  @override
  String get pluginRepositoryActionInstall => 'Pasang';

  @override
  String get pluginRepositoryActionUnavailable => 'Tidak Tersedia';

  @override
  String get pluginRepositoryInstallFailed => 'Pemasangan gagal.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Gagal mengunduh $name.';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Digantikan di $count playlist$queue.',
      one: 'Digantikan di 1 playlist$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Cari lirik...';

  @override
  String get lyricsSearchEmptyPrompt =>
      'Ketik judul lagu atau artis untuk mencari lirik.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Lirik tidak ditemukan untuk \"$query\"';
  }

  @override
  String get lyricsSearchApplied => 'Lirik berhasil diterapkan';

  @override
  String get lyricsSearchFetchFailed => 'Gagal mengambil lirik';

  @override
  String get lyricsSearchPreview => 'Pratinjau';

  @override
  String get lyricsSearchPreviewTooltip => 'Pratinjau lirik';

  @override
  String get lyricsSearchSynced => 'TER-SINKRONISASI';

  @override
  String get lyricsSearchPreviewLoadFailed => 'Gagal memuat lirik.';

  @override
  String get lyricsSearchApplyAction => 'Terapkan Lirik';

  @override
  String get lyricsSettingsSearchTitle => 'Cari Lirik Kustom';

  @override
  String get lyricsSettingsSearchSubtitle =>
      'Cari lirik alternatif di internet';

  @override
  String get lyricsSettingsSyncTitle => 'Sesuaikan Sinkronisasi (Jeda/Offset)';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Perbaiki lirik yang terlalu cepat atau lambat';

  @override
  String get lyricsSettingsSaveTitle => 'Simpan Offline';

  @override
  String get lyricsSettingsSaveSubtitle => 'Simpan lirik ini di perangkat Anda';

  @override
  String get lyricsSettingsDeleteTitle => 'Hapus Lirik Tersimpan';

  @override
  String get lyricsSettingsDeleteSubtitle => 'Hapus data lirik offline';

  @override
  String get lyricsSyncTapToReset => 'Ketuk untuk reset';

  @override
  String get upNextTitle => 'Selanjutnya';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lagu di antrean',
      one: '1 lagu di antrean',
    );
    return '$_temp0';
  }

  @override
  String get upNextAutoPlay => 'Putar Otomatis';

  @override
  String get tooltipCopyToClipboard => 'Salin ke papan klip';

  @override
  String get snackbarCopiedToClipboard => 'Disalin ke papan klip';

  @override
  String get tooltipSongInfo => 'Informasi Lagu';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'Tidak dapat menghapus lagu yang sedang diputar';

  @override
  String get playerLoopOff => 'Mati';

  @override
  String get playerLoopOne => 'Ulangi Satu';

  @override
  String get playerLoopAll => 'Ulangi Semua';

  @override
  String get snackbarOpeningAlbumPage => 'Membuka halaman album asli.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Versi baru StreamBeats telah tersedia!\n\nVersi: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Plugin \"$id\" berhasil dipasang';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return 'Plugin \"$id\" dimuat';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Plugin \"$id\" berhasil dihapus';
  }

  @override
  String get pluginBootstrapTitle => 'Menyiapkan StreamBeats';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Menyiapkan mesin plugin baru... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Ini hanya terjadi sekali.';

  @override
  String get pluginBootstrapErrorTitle => 'Koneksi Terlalu Lambat';

  @override
  String get pluginBootstrapErrorBody =>
      'Beberapa plugin tidak dapat dipasang. Anda tetap dapat menggunakan StreamBeats — plugin akan dicoba kembali saat peluncuran berikutnya.';

  @override
  String get pluginBootstrapContinue => 'Lanjutkan Saja';
}
