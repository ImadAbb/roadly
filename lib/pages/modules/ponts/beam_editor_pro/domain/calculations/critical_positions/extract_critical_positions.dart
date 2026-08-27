import '../../models/beam.dart';
import '../../models/load.dart';

List<double> extractCriticalPositions(Beam beam) {
  final criticalPositions = <double>{};

  // bornes de la poutre
  criticalPositions.add(0);
  criticalPositions.add(beam.beamLength);

  // positions des supports
  for (final support in beam.supports) {
    criticalPositions.add(support.position);
  }

  // positions des charges
  for (final load in beam.loads) {
    if (load is PointLoad) {
      criticalPositions.add(load.position);
    }
    if (load is DistributedLoad) {
      criticalPositions.add(load.position);
      criticalPositions.add(load.positionEnd);
    }
  }

  final sorted = criticalPositions.toList()..sort();
  return sorted;
}
