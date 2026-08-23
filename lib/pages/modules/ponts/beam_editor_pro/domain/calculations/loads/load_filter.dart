import '../../models/load.dart';

class LoadFilter {
  const LoadFilter._();

  static List<PointLoad> pointLoads(List<Load> loads) {
    return loads.whereType<PointLoad>().toList();
  }

  static List<DistributedLoad> distributedLoads(List<Load> loads) {
    return loads.whereType<DistributedLoad>().toList();
  }

  static List<MomentLoad> momentLoads(List<Load> loads) {
    return loads.whereType<MomentLoad>().toList();
  }
}