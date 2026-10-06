sealed class ChartEvent {
  const ChartEvent();
}

class LoadCharts extends ChartEvent {
  final String pluginId;
  const LoadCharts({required this.pluginId});
}

class LoadChartDetails extends ChartEvent {
  final String pluginId;
  final String chartId;
  const LoadChartDetails({required this.pluginId, required this.chartId});
}

class ForceRefreshChartDetails extends ChartEvent {
  final String pluginId;
  final String chartId;
  const ForceRefreshChartDetails({
    required this.pluginId,
    required this.chartId,
  });
}

class PrefetchAllChartDetails extends ChartEvent {
  final String pluginId;
  final Set<String> chartIds;
  const PrefetchAllChartDetails({
    required this.pluginId,
    required this.chartIds,
  });
}

class SetActiveChartPlugin extends ChartEvent {
  final String pluginId;
  const SetActiveChartPlugin({required this.pluginId});
}

class ClearCharts extends ChartEvent {
  const ClearCharts();
}