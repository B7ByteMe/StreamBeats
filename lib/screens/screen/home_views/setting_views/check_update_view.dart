import 'package:streambeats/services/streambeats_updater_tools.dart';
import 'package:flutter/material.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:streambeats/utils/url_launcher.dart';
import 'package:streambeats/l10n/app_localizations.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class CheckUpdateView extends StatelessWidget {
  const CheckUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.updateCheckTitle,
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: getLatestVersion(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (!snapshot.data?["results"]) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Icon(
                      MingCute.cat_fill,
                      size: 80,
                      color: Default_Theme.primaryColor1,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        l10n.updateUpToDate,
                        style: const TextStyle(
                                color: Default_Theme.accentColor2, fontSize: 20)
                            .merge(Default_Theme.secondoryTextStyleMedium),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FilledButton(
                        onPressed: () {
                          launch_Url(Uri.parse(
                              "https://streambeats.valoraofficial.workers.dev/"));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: SizedBox(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                FontAwesome.github_alt_brand,
                                size: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  l10n.updateViewPreRelease,
                                  style: Default_Theme.secondoryTextStyleMedium.copyWith(
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        l10n.updateCurrentVersion(
                            snapshot.data?["currVer"] ?? '',
                            snapshot.data?["currBuild"] ?? ''),
                        style: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.5),
                                fontSize: 12)
                            .merge(Default_Theme.tertiaryTextStyle),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Icon(
                      MingCute.cat_fill,
                      size: 80,
                      color: Default_Theme.primaryColor1,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.updateNewVersionAvailable,
                      style: const TextStyle(
                              color: Default_Theme.accentColor2, fontSize: 20)
                          .merge(Default_Theme.tertiaryTextStyle),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        l10n.updateVersion(snapshot.data?["newVer"] ?? '',
                            snapshot.data?["newBuild"] ?? ''),
                        style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.8),
                                fontSize: 16)
                            .merge(Default_Theme.tertiaryTextStyle),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton(
                        onPressed: () {
                          launch_Url(
                              Uri.parse("https://streambeats.valoraofficial.workers.dev/"));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.open_in_browser_rounded,
                                  size: 25),
                              Text(
                                l10n.updateDownloadNow,
                                style: Default_Theme.secondoryTextStyleMedium.copyWith(
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        l10n.updateCurrentVersion(
                            snapshot.data?["currVer"] ?? '',
                            snapshot.data?["currBuild"] ?? ''),
                        style: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.5),
                                fontSize: 12)
                            .merge(Default_Theme.tertiaryTextStyle),
                      ),
                    ),
                  ],
                );
              }
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2,
                        )),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth * 0.6,
                        child: Text(l10n.updateChecking,
                            style: const TextStyle(
                                    color: Default_Theme.accentColor2,
                                    fontSize: 20)
                                .merge(Default_Theme.tertiaryTextStyle),
                            textAlign: TextAlign.center),
                      );
                    },
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}