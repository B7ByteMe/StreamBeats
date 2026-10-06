import 'package:flutter/material.dart';

class PagingScrollPhysics extends ScrollPhysics {
  const PagingScrollPhysics(
      {required this.itemCount, required this.viewSize, super.parent});

  final double viewSize;

  final int itemCount;

  @override
  PagingScrollPhysics applyTo(ScrollPhysics? ancestor) => PagingScrollPhysics(
      itemCount: itemCount, viewSize: viewSize, parent: buildParent(ancestor));

  double _getPage(double current, double itemDimension) =>
      current / itemDimension;

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    final pixels = position.maxScrollExtent + viewSize;
    final itemDimension = pixels / itemCount;
    var page = _getPage(position.pixels, itemDimension);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    final pageRound = page.round();
    final itemsPerPage = viewSize ~/ itemDimension;
    final showingLastItem = pageRound == itemCount - itemsPerPage;
    if (showingLastItem) return pixels - viewSize;

    return pageRound * itemDimension;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}