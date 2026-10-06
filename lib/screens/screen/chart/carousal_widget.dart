import 'dart:developer';
import 'dart:async';
import 'package:streambeats/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:streambeats/core/di/service_locator.dart';
import 'package:streambeats/plugins/blocs/chart/chart_bloc.dart';
import 'package:streambeats/plugins/blocs/chart/chart_event.dart';
import 'package:streambeats/plugins/blocs/chart/chart_state.dart';
import 'package:streambeats/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:streambeats/plugins/blocs/plugin/plugin_state.dart';
import 'package:streambeats/screens/screen/chart/chart_view.dart';
import 'package:streambeats/screens/screen/chart/chart_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CaraouselWidget extends StatefulWidget {
  const CaraouselWidget({super.key});

  @override
  State<CaraouselWidget> createState() => _CaraouselWidgetState();
}

class _CaraouselWidgetState extends State<CaraouselWidget> {
  late final ChartBloc _chartBloc;
  ValueNotifier<bool> autoSlideCharts = ValueNotifier(true);
  StreamSubscription<SettingsState>? _settingsSub;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _chartBloc = ChartBloc(pluginService: ServiceLocator.pluginService);
    autoSlideCharts.value = context.read<SettingsCubit>().state.autoSlideCharts;
    _settingsSub = context.read<SettingsCubit>().stream.listen((event) {
      if (autoSlideCharts.value != event.autoSlideCharts) {
        autoSlideCharts.value = event.autoSlideCharts;
      }
    });
    _loadChartsFromPlugin();
  }

  void _loadChartsFromPlugin() {
    final chartProviders =
        context.read<PluginBloc>().state.loadedChartProviders;
    if (chartProviders.isNotEmpty) {
      final pluginId = chartProviders.first.manifest.id;
      log('Loading charts from plugin: $pluginId', name: 'ChartCarousel');
      _chartBloc.add(LoadCharts(pluginId: pluginId));
    } else {
      log('No chart provider plugins loaded — charts unavailable',
          name: 'ChartCarousel');
    }
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _chartBloc.close();
    autoSlideCharts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChartBloc, ChartState>(
      bloc: _chartBloc,
      listenWhen: (previous, current) =>
          previous.chartsStatus != ChartStatus.loaded &&
          current.chartsStatus == ChartStatus.loaded,
      listener: (context, chartState) {
        final pluginId = chartState.activePluginId;
        if (pluginId == null || chartState.charts.isEmpty) return;
        final settingsState = context.read<SettingsCubit>().state;
        final visibleIds = chartState.charts
            .where((c) => settingsState.chartMap[c.title] ?? true)
            .map((c) => c.id)
            .toSet();
        if (visibleIds.isNotEmpty) {
          _chartBloc.add(PrefetchAllChartDetails(
            pluginId: pluginId,
            chartIds: visibleIds,
          ));
        }
      },
      child: BlocBuilder<PluginBloc, PluginState>(
        builder: (context, pluginState) {
          if (pluginState.loadedChartProviders.isEmpty) {
            _chartBloc.add(const ClearCharts());
          } else if (_chartBloc.state.chartsStatus == ChartStatus.initial) {
            _loadChartsFromPlugin();
          }
          return BlocBuilder<ChartBloc, ChartState>(
            bloc: _chartBloc,
            builder: (context, chartState) {
              if (chartState.charts.isEmpty) return const SizedBox.shrink();

              final settingsState = context.watch<SettingsCubit>().state;
              final visibleCharts = chartState.charts
                  .where((c) => settingsState.chartMap[c.title] ?? true)
                  .toList();

              if (visibleCharts.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero carousel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: autoSlideCharts,
                        builder: (context, autoPlay, child) {
                          return CarouselSlider.builder(
                            itemCount: visibleCharts.length,
                            itemBuilder: (context, index, realIndex) {
                              final chart = visibleCharts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChartScreen(
                                        pluginId:
                                            _chartBloc.state.activePluginId ??
                                                '',
                                        chartId: chart.id,
                                        chartTitle: chart.title,
                                      ),
                                    ),
                                  );
                                },
                                child: ChartWidget(
                                  chart: chart,
                                  pluginId:
                                      _chartBloc.state.activePluginId ?? '',
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: ResponsiveBreakpoints.of(context).isMobile
                                  ? MediaQuery.of(context).size.height * 0.28
                                  : 220,
                              viewportFraction: 1.0,
                              autoPlay: autoPlay,
                              autoPlayInterval:
                                  const Duration(milliseconds: 4000),
                              initialPage: 0,
                              pauseAutoPlayOnTouch: true,
                              enableInfiniteScroll: visibleCharts.length > 1,
                              onPageChanged: (index, reason) {
                                setState(() => _currentIndex = index);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Page indicator dots
                    if (visibleCharts.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            visibleCharts.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentIndex == index ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}