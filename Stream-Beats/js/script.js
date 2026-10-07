/**
 * StreamBeats Landing Page Script
 * Official Website: https://streambeats.pages.dev/
 * GitHub: https://github.com/B7ByteMe/StreamBeats
 */

const GITHUB_OWNER = 'B7ByteMe';
const GITHUB_REPO = 'StreamBeats';
const GITHUB_API = `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases`;
const BASE_DOWNLOADS_COUNT = 1247000;

let allReleases = [];
let currentReleaseIndex = 0;
let selectedAndroidApkKey = 'arm64'; // default: arm64-v8a

// ============================================================
// UTILITY FUNCTIONS
// ============================================================

function formatBytes(bytes) {
    if (!bytes || isNaN(bytes)) return '0 B';
    if (bytes < 1024 * 1024) {
        return (bytes / 1024).toFixed(1) + ' KB';
    }
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

function formatDate(dateStr) {
    try {
        const date = new Date(dateStr);
        return date.toLocaleDateString('id-ID', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    } catch {
        return dateStr;
    }
}

function triggerDownload(url, filename) {
    if (!url) return;
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    if (filename) a.download = filename;
    a.target = '_blank';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    // Track download in localStorage
    trackDownload();
}

function trackDownload() {
    const key = 'sb_web_downloads';
    const current = parseInt(localStorage.getItem(key) || '0', 10);
    localStorage.setItem(key, current + 1);

    const countElem = document.getElementById('total-downloads-count');
    if (countElem) {
        const raw = parseInt(countElem.textContent.replace(/[^0-9]/g, ''), 10) || BASE_DOWNLOADS_COUNT;
        const updated = raw + 1;
        countElem.textContent = updated.toLocaleString('id-ID');
        countElem.style.transform = 'scale(1.08)';
        countElem.style.transition = 'transform 0.2s ease';
        setTimeout(() => {
            countElem.style.transform = 'scale(1)';
        }, 200);
    }
}

// ============================================================
// ASSET CATEGORIZATION
// ============================================================

function categorizeAssets(assets = []) {
    const result = {
        android: {
            arm64: null,
            universal: null,
            armv7: null,
            x86_64: null,
            others: []
        },
        windows: {
            installer: null,
            portable: null,
            others: []
        },
        linux: {
            tarball: null,
            deb: null,
            appimage: null,
            others: []
        },
        macos: {
            dmg: null,
            pkg: null,
            others: []
        },
        ios: {
            ipa: null,
            others: []
        }
    };

    assets.forEach(asset => {
        const name = (asset.name || '').toLowerCase();

        // 1. Android APKs
        if (name.endsWith('.apk')) {
            if (name.includes('arm64-v8a') || name.includes('arm64')) {
                result.android.arm64 = asset;
            } else if (name.includes('universal')) {
                result.android.universal = asset;
            } else if (name.includes('armeabi-v7a') || name.includes('armv7') || name.includes('arm-v7')) {
                result.android.armv7 = asset;
            } else if (name.includes('x86_64') || name.includes('x64')) {
                result.android.x86_64 = asset;
            } else {
                result.android.others.push(asset);
            }
        }
        // 2. Windows (.exe, .msi, win .zip)
        else if (name.endsWith('.exe') || name.endsWith('.msix') || name.endsWith('.msi')) {
            result.windows.installer = asset;
        } else if (name.includes('win') && name.endsWith('.zip')) {
            result.windows.portable = asset;
        }
        // 3. Linux (.tar.gz, .deb, .rpm, .appimage, linux .zip)
        else if (name.includes('linux') || name.endsWith('.deb') || name.endsWith('.rpm') || name.endsWith('.appimage')) {
            if (name.endsWith('.tar.gz') || name.endsWith('.tgz')) {
                result.linux.tarball = asset;
            } else if (name.endsWith('.deb')) {
                result.linux.deb = asset;
            } else if (name.endsWith('.appimage')) {
                result.linux.appimage = asset;
            } else {
                result.linux.others.push(asset);
            }
        }
        // 4. macOS (.dmg, .pkg, macos .zip)
        else if (name.endsWith('.dmg') || name.endsWith('.pkg') || (name.includes('mac') && name.endsWith('.zip'))) {
            if (name.endsWith('.dmg')) {
                result.macos.dmg = asset;
            } else if (name.endsWith('.pkg')) {
                result.macos.pkg = asset;
            } else {
                result.macos.others.push(asset);
            }
        }
        // 5. iOS (.ipa)
        else if (name.endsWith('.ipa') || name.includes('ios')) {
            result.ios.ipa = asset;
        }
    });

    return result;
}

// ============================================================
// RENDER RELEASE TO DOM
// ============================================================

function renderRelease(index) {
    const container = document.getElementById('release-assets');
    if (!container) return;

    const release = allReleases[index];
    if (!release) {
        container.innerHTML = `
            <div class="error-state">
                <p>Tidak ada rilis yang dapat dimuat. Kunjungi <a href="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases" target="_blank">GitHub Releases</a>.</p>
            </div>
        `;
        return;
    }

    currentReleaseIndex = index;
    const assets = release.assets || [];
    const cat = categorizeAssets(assets);

    const releaseTag = release.tag_name || release.name || 'v3.2.7';
    const releaseDate = formatDate(release.published_at || release.created_at);
    const isPreRelease = !!release.prerelease;

    // Helper to get active Android asset
    let activeAndroidAsset = cat.android[selectedAndroidApkKey];
    if (!activeAndroidAsset) {
        // Fallback to first available android asset
        activeAndroidAsset = cat.android.arm64 || cat.android.universal || cat.android.armv7 || cat.android.x86_64 || cat.android.others[0];
        if (activeAndroidAsset) {
            if (activeAndroidAsset === cat.android.arm64) selectedAndroidApkKey = 'arm64';
            else if (activeAndroidAsset === cat.android.universal) selectedAndroidApkKey = 'universal';
            else if (activeAndroidAsset === cat.android.armv7) selectedAndroidApkKey = 'armv7';
            else if (activeAndroidAsset === cat.android.x86_64) selectedAndroidApkKey = 'x86_64';
        }
    }

    // Windows asset
    const winAsset = cat.windows.installer || cat.windows.portable || cat.windows.others[0];

    // Linux asset
    const linuxAsset = cat.linux.tarball || cat.linux.deb || cat.linux.appimage || cat.linux.others[0];

    // macOS asset
    const macAsset = cat.macos.dmg || cat.macos.pkg || cat.macos.others[0];

    // iOS asset
    const iosAsset = cat.ios.ipa || cat.ios.others[0];

    container.innerHTML = `
        <!-- Release Info Banner -->
        <div class="release-info-banner">
            <div class="release-info-left">
                <span class="release-tag-badge"><i class="fa-solid fa-tag"></i> ${escapeHtml(releaseTag)}</span>
                <span class="release-date-text"><i class="fa-regular fa-calendar"></i> ${escapeHtml(releaseDate)}</span>
                <span class="release-status-badge ${isPreRelease ? 'badge-gold' : 'badge-green'}">
                    ${isPreRelease ? '⚠️ Pre-release' : '✅ Rilis Stabil'}
                </span>
            </div>
            <div class="release-info-right">
                <a href="${release.html_url || `https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/tag/${releaseTag}`}" target="_blank" class="release-notes-link">
                    Catatan Rilis di GitHub <i class="fa-solid fa-arrow-up-right-from-square"></i>
                </a>
            </div>
        </div>

        <!-- Primary Platforms Grid (Android, Windows, Linux) -->
        <div class="platform-cards-grid">
            
            <!-- 1. KOTAK KHUSUS ANDROID -->
            <div class="platform-card featured-card android-card" id="card-android">
                <div class="platform-card-header">
                    <div class="platform-icon-wrap platform-icon-android">
                        <i class="fa-brands fa-android"></i>
                    </div>
                    <span class="platform-badge badge-green">Paling Populer</span>
                </div>

                <div class="platform-title-area">
                    <h3>Android</h3>
                    <p>Mendukung Android 7.0 hingga Android 15+. Tanpa iklan, lirik karaoke sinkron, dan hemat daya.</p>
                </div>

                <!-- Pilihan Jenis APK -->
                <div class="apk-selector-container">
                    <div class="apk-selector-label">
                        <span><i class="fa-solid fa-microchip"></i> Pilih Arsitektur APK:</span>
                        <span id="selected-apk-badge" style="color: #3DDC84; font-weight:700;">64-bit (Modern)</span>
                    </div>
                    <div class="apk-pills-grid">
                        <button type="button" class="apk-pill ${selectedAndroidApkKey === 'arm64' ? 'active' : ''}" data-apk="arm64">
                            <strong><i class="fa-solid fa-star" style="font-size:0.65rem; color:#F6C844;"></i> arm64-v8a</strong>
                            <span>HP Modern 64-bit (2018+)</span>
                        </button>
                        <button type="button" class="apk-pill ${selectedAndroidApkKey === 'universal' ? 'active' : ''}" data-apk="universal">
                            <strong><i class="fa-solid fa-cubes"></i> Universal</strong>
                            <span>Semua Processor HP</span>
                        </button>
                        <button type="button" class="apk-pill ${selectedAndroidApkKey === 'armv7' ? 'active' : ''}" data-apk="armv7">
                            <strong><i class="fa-solid fa-mobile"></i> armeabi-v7a</strong>
                            <span>HP Lama / 32-bit</span>
                        </button>
                        <button type="button" class="apk-pill ${selectedAndroidApkKey === 'x86_64' ? 'active' : ''}" data-apk="x86_64">
                            <strong><i class="fa-solid fa-laptop"></i> x86_64</strong>
                            <span>Emulator PC / Intel</span>
                        </button>
                    </div>
                </div>

                <ul class="platform-features-list">
                    <li><i class="fa-solid fa-circle-check"></i> <span>Dukungan Background Play & Notifikasi Musik</span></li>
                    <li><i class="fa-solid fa-circle-check"></i> <span>Offline Caching & Lirik Karaoke Layar Penuh</span></li>
                </ul>

                <div class="platform-card-footer">
                    ${activeAndroidAsset ? `
                        <button type="button" class="btn-platform-download btn-android-main" data-download-url="${escapeHtml(activeAndroidAsset.browser_download_url)}" data-filename="${escapeHtml(activeAndroidAsset.name)}">
                            <i class="fa-solid fa-download"></i>
                            <span class="btn-text">Unduh ${escapeHtml(activeAndroidAsset.name)}</span>
                        </button>
                        <div class="platform-meta-info">
                            <span><i class="fa-solid fa-hard-drive"></i> Ukuran: <strong>${formatBytes(activeAndroidAsset.size)}</strong></span>
                            <span><i class="fa-solid fa-cloud-arrow-down"></i> ${activeAndroidAsset.download_count || 0} unduhan</span>
                        </div>
                    ` : `
                        <a href="${release.html_url}" target="_blank" class="btn-platform-outline">
                            <i class="fa-brands fa-github"></i> Unduh APK via GitHub
                        </a>
                        <div class="platform-meta-info">
                            <span>APK sedang diproses di GitHub Actions</span>
                        </div>
                    `}

                    <!-- Toggle Accordion Semua APK -->
                    <div class="apk-accordion-toggle" id="toggle-all-apks">
                        <i class="fa-solid fa-list"></i> Tampilkan Semua Tautan APK <i class="fa-solid fa-chevron-down"></i>
                    </div>
                    <div class="all-apk-list" id="all-apk-list">
                        ${renderAllApkItems(cat.android)}
                    </div>
                </div>
            </div>

            <!-- 2. KOTAK KHUSUS WINDOWS -->
            <div class="platform-card windows-card" id="card-windows">
                <div class="platform-card-header">
                    <div class="platform-icon-wrap platform-icon-windows">
                        <i class="fa-brands fa-windows"></i>
                    </div>
                    <span class="platform-badge badge-blue">Windows 10 / 11</span>
                </div>

                <div class="platform-title-area">
                    <h3>Windows</h3>
                    <p>Kompatibel dengan PC & Laptop Windows 10 dan Windows 11 (64-bit). Dilengkapi installer resmi Inno Setup.</p>
                </div>

                <ul class="platform-features-list" style="margin-top: 24px;">
                    <li><i class="fa-solid fa-circle-check"></i> <span>Desktop & Start Menu Shortcut otomatis</span></li>
                    <li><i class="fa-solid fa-circle-check"></i> <span>Integrasi Tombol Media Keyboard & Tray Audio</span></li>
                    <li><i class="fa-solid fa-circle-check"></i> <span>Dukungan Discord Rich Presence & Last.fm</span></li>
                </ul>

                <div class="platform-card-footer">
                    ${winAsset ? `
                        <button type="button" class="btn-platform-download" data-download-url="${escapeHtml(winAsset.browser_download_url)}" data-filename="${escapeHtml(winAsset.name)}">
                            <i class="fa-solid fa-download"></i>
                            <span>Unduh ${escapeHtml(winAsset.name)}</span>
                        </button>
                        <div class="platform-meta-info">
                            <span><i class="fa-solid fa-hard-drive"></i> Ukuran: <strong>${formatBytes(winAsset.size)}</strong></span>
                            <span><i class="fa-solid fa-cloud-arrow-down"></i> ${winAsset.download_count || 0} unduhan</span>
                        </div>
                    ` : `
                        <a href="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases" target="_blank" class="btn-platform-outline">
                            <i class="fa-brands fa-github"></i> Cek Installer Windows di GitHub
                        </a>
                        <div class="platform-meta-info">
                            <span>Installer Windows (.exe)</span>
                        </div>
                    `}
                </div>
            </div>

            <!-- 3. KOTAK KHUSUS LINUX -->
            <div class="platform-card linux-card" id="card-linux">
                <div class="platform-card-header">
                    <div class="platform-icon-wrap platform-icon-linux">
                        <i class="fa-brands fa-linux"></i>
                    </div>
                    <span class="platform-badge badge-gold">Linux x64</span>
                </div>

                <div class="platform-title-area">
                    <h3>Linux</h3>
                    <p>Kompatibel dengan Ubuntu, Debian, Arch Linux, Fedora, Manjaro, dan distro Linux modern (64-bit).</p>
                </div>

                <ul class="platform-features-list" style="margin-top: 24px;">
                    <li><i class="fa-solid fa-circle-check"></i> <span>Format Bundle Arsip Standalone (.tar.gz)</span></li>
                    <li><i class="fa-solid fa-circle-check"></i> <span>Dukungan Audio ALSA / PulseAudio / PipeWire</span></li>
                    <li><i class="fa-solid fa-circle-check"></i> <span>Ekstrak arsip lalu jalankan binary <code>./streambeats</code></span></li>
                </ul>

                <div class="platform-card-footer">
                    ${linuxAsset ? `
                        <button type="button" class="btn-platform-download" data-download-url="${escapeHtml(linuxAsset.browser_download_url)}" data-filename="${escapeHtml(linuxAsset.name)}">
                            <i class="fa-solid fa-download"></i>
                            <span>Unduh ${escapeHtml(linuxAsset.name)}</span>
                        </button>
                        <div class="platform-meta-info">
                            <span><i class="fa-solid fa-hard-drive"></i> Ukuran: <strong>${formatBytes(linuxAsset.size)}</strong></span>
                            <span><i class="fa-solid fa-cloud-arrow-down"></i> ${linuxAsset.download_count || 0} unduhan</span>
                        </div>
                    ` : `
                        <a href="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases" target="_blank" class="btn-platform-outline">
                            <i class="fa-brands fa-github"></i> Cek Arsip Linux di GitHub
                        </a>
                        <div class="platform-meta-info">
                            <span>Paket Linux x64</span>
                        </div>
                    `}
                </div>
            </div>
        </div>

        <!-- Secondary Platforms Grid (macOS & iOS) -->
        <div class="platform-cards-row-secondary">
            
            <!-- 4. KOTAK KHUSUS MACOS -->
            <div class="platform-card macos-card" id="card-macos">
                <div class="platform-card-header">
                    <div class="platform-icon-wrap platform-icon-macos">
                        <i class="fa-brands fa-apple"></i>
                    </div>
                    <span class="platform-badge">MacBook & iMac</span>
                </div>

                <div class="platform-title-area">
                    <h3>macOS (MacBook)</h3>
                    <p>Mendukung Apple Silicon (M1/M2/M3/M4) dan Mac Intel (macOS 11 Big Sur ke atas). Nikmati audio bebas iklan di Mac.</p>
                </div>

                <ul class="platform-features-list">
                    <li><i class="fa-solid fa-circle-check"></i> <span>Akselerasi hardware penuh & UI tema dark elegan</span></li>
                    <li><i class="fa-solid fa-circle-check"></i> <span>Tersedia via paket source Flutter atau rilis DMG</span></li>
                </ul>

                <div class="platform-card-footer">
                    ${macAsset ? `
                        <button type="button" class="btn-platform-download" data-download-url="${escapeHtml(macAsset.browser_download_url)}" data-filename="${escapeHtml(macAsset.name)}">
                            <i class="fa-solid fa-download"></i> Unduh ${escapeHtml(macAsset.name)}
                        </button>
                    ` : `
                        <a href="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}" target="_blank" class="btn-platform-outline">
                            <i class="fa-brands fa-github"></i> Rilis macOS & Panduan Build
                        </a>
                    `}
                    <div class="platform-meta-info">
                        ${macAsset ? `
                            <span><i class="fa-solid fa-hard-drive"></i> Ukuran: <strong>${formatBytes(macAsset.size)}</strong></span>
                            <span><i class="fa-solid fa-cloud-arrow-down"></i> ${macAsset.download_count || 0} unduhan</span>
                        ` : `
                            <span>Apple Silicon (ARM64) & Intel</span>
                            <span>Official Build</span>
                        `}
                    </div>
                </div>
            </div>

            <!-- 5. KOTAK KHUSUS IOS -->
            <div class="platform-card ios-card" id="card-ios">
                <div class="platform-card-header">
                    <div class="platform-icon-wrap platform-icon-ios">
                        <i class="fa-solid fa-mobile-screen"></i>
                    </div>
                    <span class="platform-badge">iPhone / iPad</span>
                </div>

                <div class="platform-title-area">
                    <h3>iOS (iPhone & iPad)</h3>
                    <p>Dukungan instalasi mandiri (Sideloading) tanpa jailbreak via AltStore, TrollStore, Scarlet, atau Sideloadly.</p>
                </div>

                <ul class="platform-features-list">
                    <li><i class="fa-solid fa-circle-check"></i> <span>Kompatibel dengan iOS 15.0 hingga iOS 18+</span></li>
                    <li><i class="fa-solid fa-circle-check"></i> <span>Audio streaming lancar, lirik offline, & zero tracker</span></li>
                </ul>

                <div class="platform-card-footer">
                    ${iosAsset ? `
                        <button type="button" class="btn-platform-download" data-download-url="${escapeHtml(iosAsset.browser_download_url)}" data-filename="${escapeHtml(iosAsset.name)}">
                            <i class="fa-solid fa-download"></i> Unduh ${escapeHtml(iosAsset.name)}
                        </button>
                    ` : `
                        <a href="https://whatsapp.com/channel/0029Vb8V2qh8V0tpL0VDky0M" target="_blank" class="btn-platform-outline">
                            <i class="fa-brands fa-whatsapp"></i> Gabung Saluran Info Rilis iOS
                        </a>
                    `}
                    <div class="platform-meta-info">
                        ${iosAsset ? `
                            <span><i class="fa-solid fa-hard-drive"></i> Ukuran: <strong>${formatBytes(iosAsset.size)}</strong></span>
                            <span><i class="fa-solid fa-cloud-arrow-down"></i> ${iosAsset.download_count || 0} unduhan</span>
                        ` : `
                            <span>Sideload IPA / TestFlight</span>
                            <span>Komunitas</span>
                        `}
                    </div>
                </div>
            </div>
        </div>
    `;

    // Attach Event Listeners
    attachCardListeners(cat);
}

function renderAllApkItems(androidCat) {
    const items = [];
    const mapping = [
        { key: 'arm64', label: 'arm64-v8a (HP Modern 64-bit)', asset: androidCat.arm64 },
        { key: 'universal', label: 'Universal (Semua Arsitektur)', asset: androidCat.universal },
        { key: 'armv7', label: 'armeabi-v7a (HP Lama 32-bit)', asset: androidCat.armv7 },
        { key: 'x86_64', label: 'x86_64 (Emulator PC & Intel)', asset: androidCat.x86_64 }
    ];

    mapping.forEach(m => {
        if (m.asset) {
            items.push(`
                <div class="all-apk-item">
                    <div>
                        <strong>${escapeHtml(m.label)}</strong>
                        <div style="font-size:0.7rem; color:#8E8E93;">${escapeHtml(m.asset.name)} • ${formatBytes(m.asset.size)}</div>
                    </div>
                    <button type="button" class="btn-small btn-primary trigger-dl" data-download-url="${escapeHtml(m.asset.browser_download_url)}" data-filename="${escapeHtml(m.asset.name)}">
                        <i class="fa-solid fa-download"></i> Unduh
                    </button>
                </div>
            `);
        }
    });

    if (androidCat.others && androidCat.others.length > 0) {
        androidCat.others.forEach(asset => {
            items.push(`
                <div class="all-apk-item">
                    <div>
                        <strong>${escapeHtml(asset.name)}</strong>
                        <div style="font-size:0.7rem; color:#8E8E93;">${formatBytes(asset.size)}</div>
                    </div>
                    <button type="button" class="btn-small btn-primary trigger-dl" data-download-url="${escapeHtml(asset.browser_download_url)}" data-filename="${escapeHtml(asset.name)}">
                        <i class="fa-solid fa-download"></i> Unduh
                    </button>
                </div>
            `);
        });
    }

    return items.join('');
}

function attachCardListeners(cat) {
    // 1. Download Buttons Listener
    const buttons = document.querySelectorAll('[data-download-url]');
    buttons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            const url = btn.getAttribute('data-download-url');
            const filename = btn.getAttribute('data-filename');
            triggerDownload(url, filename);
        });
    });

    // 2. APK Pills Selector Listener
    const pills = document.querySelectorAll('.apk-pill');
    pills.forEach(pill => {
        pill.addEventListener('click', (e) => {
            e.preventDefault();
            const apkKey = pill.getAttribute('data-apk');
            selectedAndroidApkKey = apkKey;

            // Update active state on pills
            pills.forEach(p => p.classList.remove('active'));
            pill.classList.add('active');

            // Update main Android button & badge
            const targetAsset = cat.android[apkKey];
            const mainBtn = document.querySelector('.btn-android-main');
            const badge = document.getElementById('selected-apk-badge');

            const labelMap = {
                arm64: '64-bit (Modern)',
                universal: 'Universal (Semua HP)',
                armv7: '32-bit (HP Lama)',
                x86_64: 'x86_64 (Emulator)'
            };

            if (badge) badge.textContent = labelMap[apkKey] || apkKey;

            if (mainBtn && targetAsset) {
                mainBtn.setAttribute('data-download-url', targetAsset.browser_download_url);
                mainBtn.setAttribute('data-filename', targetAsset.name);
                const textElem = mainBtn.querySelector('.btn-text');
                if (textElem) {
                    textElem.textContent = `Unduh ${targetAsset.name}`;
                }
                const metaArea = mainBtn.nextElementSibling;
                if (metaArea && metaArea.classList.contains('platform-meta-info')) {
                    metaArea.innerHTML = `
                        <span><i class="fa-solid fa-hard-drive"></i> Ukuran: <strong>${formatBytes(targetAsset.size)}</strong></span>
                        <span><i class="fa-solid fa-cloud-arrow-down"></i> ${targetAsset.download_count || 0} unduhan</span>
                    `;
                }
            }
        });
    });

    // 3. Toggle All APKs Accordion
    const toggleBtn = document.getElementById('toggle-all-apks');
    const apkList = document.getElementById('all-apk-list');
    if (toggleBtn && apkList) {
        toggleBtn.addEventListener('click', () => {
            const isShown = apkList.classList.toggle('show');
            toggleBtn.innerHTML = isShown
                ? `<i class="fa-solid fa-list"></i> Sembunyikan Varian APK <i class="fa-solid fa-chevron-up"></i>`
                : `<i class="fa-solid fa-list"></i> Tampilkan Semua Tautan APK <i class="fa-solid fa-chevron-down"></i>`;
        });
    }
}

function escapeHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

// ============================================================
// FETCH RELEASES FROM GITHUB API
// ============================================================

async function fetchReleases() {
    const dropdown = document.getElementById('release-dropdown');
    const container = document.getElementById('release-assets');
    if (!dropdown || !container) return;

    container.innerHTML = `
        <div class="loading-state">
            <div class="loading-spinner"></div>
            <div>Menghubungkan ke GitHub API & memuat daftar rilis terbaru...</div>
        </div>
    `;

    try {
        const response = await fetch(`${GITHUB_API}?per_page=20`, {
            headers: { 'Accept': 'application/vnd.github.v3+json' }
        });

        if (!response.ok) {
            throw new Error(`GitHub API Error: ${response.status} ${response.statusText}`);
        }

        allReleases = await response.json();

        if (!allReleases || allReleases.length === 0) {
            container.innerHTML = `
                <div class="error-state">
                    <p>Tidak ditemukan rilis di repositori ini.</p>
                </div>
            `;
            return;
        }

        // Calculate Total Downloads
        let totalApiDownloads = 0;
        allReleases.forEach(rel => {
            if (rel.assets && Array.isArray(rel.assets)) {
                rel.assets.forEach(a => {
                    totalApiDownloads += (a.download_count || 0);
                });
            }
        });

        const localDl = parseInt(localStorage.getItem('sb_web_downloads') || '0', 10);
        const grandTotal = BASE_DOWNLOADS_COUNT + totalApiDownloads + localDl;

        const countElem = document.getElementById('total-downloads-count');
        if (countElem) {
            countElem.textContent = grandTotal.toLocaleString('id-ID');
        }

        const subtitleElem = document.getElementById('download-stats-subtitle');
        if (subtitleElem) {
            subtitleElem.textContent = `Platform Utama ${BASE_DOWNLOADS_COUNT.toLocaleString('id-ID')} + Unduhan Web ${(totalApiDownloads + localDl).toLocaleString('id-ID')}`;
        }

        const latestVersionText = document.getElementById('latest-version-text');
        if (latestVersionText && allReleases[0]) {
            latestVersionText.textContent = allReleases[0].tag_name || allReleases[0].name || 'v3.2.7';
        }

        // Populate Dropdown
        dropdown.innerHTML = '';
        allReleases.forEach((rel, idx) => {
            const opt = document.createElement('option');
            opt.value = idx;
            const tagName = rel.tag_name || rel.name || `Release ${idx + 1}`;
            const isLatest = idx === 0;
            const isPre = !!rel.prerelease;

            let label = tagName;
            if (isLatest && !isPre) label += '  ✅ Rilis Terbaru (Stabil)';
            else if (isPre) label += '  ⚠️ Pre-release';

            opt.textContent = label;
            dropdown.appendChild(opt);
        });

        dropdown.addEventListener('change', () => {
            renderRelease(parseInt(dropdown.value, 10));
        });

        // Initial Render Latest
        renderRelease(0);

    } catch (err) {
        console.error('Failed to fetch releases:', err);
        dropdown.innerHTML = `<option>Gagal memuat rilis GitHub</option>`;
        container.innerHTML = `
            <div class="error-state">
                <p>Gagal memuat daftar rilis dari GitHub (${escapeHtml(err.message)}).</p>
                <p style="margin-top:8px;">Silakan unduh langsung dari halaman resmi: <a href="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases" target="_blank"><strong>GitHub Releases →</strong></a></p>
            </div>
        `;
    }
}

// ============================================================
// PETALS ANIMATION & NAVIGATION
// ============================================================

function createPetals() {
    const container = document.getElementById('petals-container');
    if (!container) return;

    const count = 18;
    for (let i = 0; i < count; i++) {
        setTimeout(() => {
            const petal = document.createElement('div');
            petal.classList.add('petal');
            const left = Math.random() * 100;
            const size = Math.random() * 8 + 6;
            const duration = Math.random() * 10 + 10;
            const delay = Math.random() * 10;

            petal.style.left = `${left}vw`;
            petal.style.width = `${size}px`;
            petal.style.height = `${size}px`;
            petal.style.animationDuration = `${duration}s`;
            petal.style.animationDelay = `${delay}s`;

            container.appendChild(petal);
        }, i * 250);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    // Mobile navigation toggle
    const mobileBtn = document.querySelector('.mobile-menu-btn');
    const navLinks = document.querySelector('.nav-links');

    if (mobileBtn && navLinks) {
        mobileBtn.addEventListener('click', () => {
            if (navLinks.style.display === 'flex') {
                navLinks.style.display = 'none';
            } else {
                navLinks.style.display = 'flex';
                navLinks.style.flexDirection = 'column';
                navLinks.style.position = 'absolute';
                navLinks.style.top = '100%';
                navLinks.style.left = '0';
                navLinks.style.width = '100%';
                navLinks.style.backgroundColor = 'rgba(10, 10, 12, 0.98)';
                navLinks.style.padding = '20px';
                navLinks.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.5)';
            }
        });
    }

    // Smooth scroll for nav anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (!href || href === '#') return;
            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                window.scrollTo({
                    top: target.offsetTop - 60,
                    behavior: 'smooth'
                });
                if (window.innerWidth <= 900 && navLinks) {
                    navLinks.style.display = 'none';
                }
            }
        });
    });

    createPetals();
    fetchReleases();
});