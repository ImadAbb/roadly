import '../../models/beam.dart';
import '../../models/load.dart';

class LoadPositions {
  const LoadPositions._();

  /// Retourne toutes les positions importantes où le comportement
  /// des efforts internes peut changer.
  static List<double> importantPositions(Beam beam) {
    final positions = <double>[
      0.0,
      beam.beamLength,
    ];

    for (final load in beam.loads) {
      if (load is PointLoad) {
        positions.add(load.position);
      }

      if (load is DistributedLoad) {
        positions.add(load.position);
        positions.add(load.positionEnd);
      }

      if (load is MomentLoad) {
        positions.add(load.position);
      }
    }

    for (final support in beam.supports) {
      positions.add(support.position);
    }

    positions.sort();

    return _removeDuplicates(positions);
  }

  static List<double> _removeDuplicates(
    List<double> positions,
  ) {
    if (positions.isEmpty) {
      return [];
    }

    final result = <double>[positions.first];

    for (var i = 1; i < positions.length; i++) {
      if ((positions[i] - result.last).abs() > 1e-9) {
        result.add(positions[i]);
      }
    }

    return result;
  }
}