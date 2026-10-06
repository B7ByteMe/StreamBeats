import 'package:equatable/equatable.dart';
import 'package:streambeats/core/models/exported.dart';

class ChartState extends Equatable {
  final String? activePluginId;

  final ChartStatus chartsStatus;

  final List<ChartSummary> charts;

  final ChartStatus chartDetailStatus;

  final String? activeChartId;

  final List<ChartItem> chartItems;

  final String? error;

  const ChartState({
    this.activePluginId,
    this.chartsStatus = ChartStatus.initial,
    this.charts = const [],
    this.chartDetailStatus = ChartStatus.initial,
    this.activeChartId,
    this.chartItems = const [],
    this.error,
  });

  const ChartState.initial()
      : activePluginId = null,
        chartsStatus = ChartStatus.initial,
        charts = const [],
        chartDetailStatus = ChartStatus.initial,
        activeChartId = null,
        chartItems = const [],
        error = null;

  ChartState copyWith({
    String? activePluginId,
    ChartStatus? chartsStatus,
    List<ChartSummary>? charts,
    ChartStatus? chartDetailStatus,
    String? activeChartId,
    List<ChartItem>? chartItems,
    String? error,
    bool clearError = false,
    bool clearChartItems = false,
    bool clearActiveChart = false,
  }) {
    return ChartState(
      activePluginId: activePluginId ?? this.activePluginId,
      chartsStatus: chartsStatus ?? this.chartsStatus,
      charts: charts ?? this.charts,
      chartDetailStatus: chartDetailStatus ?? this.chartDetailStatus,
      activeChartId:
          clearActiveChart ? null : (activeChartId ?? this.activeChartId),
      chartItems: clearChartItems ? const [] : (chartItems ?? this.chartItems),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        activePluginId,
        chartsStatus,
        charts,
        chartDetailStatus,
        activeChartId,
        chartItems,
        error,
      ];
}

enum ChartStatus { initial, loading, loaded, error }