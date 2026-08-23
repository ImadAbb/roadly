import 'package:roadly/pages/modules/ponts/beam_editor_pro/core/models/load_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/core/models/support_classes.dart';

class Beam {
  double beamLenght;
  final List<Support> supports;
  final List<Load> loads;

  Beam({required this.beamLenght, List<Support>? supports, List<Load>? loads})
    : supports = supports ?? [],
      loads = loads ?? [];
      
  void updateBeamLength(double newLength) {
    beamLenght = newLength;

    for (var i = 0; i < supports.length; i++) {
      final support = supports[i];

      if (support.type == SupportType.encastrement_ &&
          support.isEncastrementRightSide == true) {
        supports[i] = Support(
          id: support.id,
          position: newLength,
          type: support.type,
          isEncastrementRightSide: true,
        );
      }
    }
  }

  // ═══════════════════════════════════════
  // SUPPORTS
  // ═══════════════════════════════════════

  void addSupport(Support support) {
    if (support.id.isEmpty) {
      support = Support(
        id: _generateSupportId(),
        position: support.position,
        type: support.type,
        isEncastrementRightSide: support.isEncastrementRightSide,
      );
    }

    supports.add(support);
  }

  void removeSupport(Support support) {
    supports.remove(support);
  }

  void updateSupport(Support oldSupport, Support newSupport) {
    final index = supports.indexOf(oldSupport);

    if (index != -1) {
      supports[index] = newSupport;
    }
  }

  String _generateSupportId() {
    var index = 1;

    while (supports.any((support) => support.id == 'support_$index')) {
      index++;
    }

    return 'support_$index';
  }

  // ═══════════════════════════════════════
  // CHARGES
  // ═══════════════════════════════════════

  void addLoad(Load load) {
    if (load.id.isEmpty) {
      load = _copyLoadWithId(load, _generateLoadId());
    }

    loads.add(load);
  }

  void removeLoad(Load load) {
    loads.remove(load);
  }

  void updateLoad(Load oldLoad, Load newLoad) {
    final index = loads.indexOf(oldLoad);

    if (index != -1) {
      loads[index] = newLoad;
    }
  }

  String _generateLoadId() {
    var index = 1;

    while (loads.any((load) => load.id == 'load_$index')) {
      index++;
    }

    return 'load_$index';
  }

  // ═══════════════════════════════════════
  // COPIE D'UNE CHARGE AVEC UN NOUVEL ID
  // ═══════════════════════════════════════

  Load _copyLoadWithId(Load load, String id) {
    if (load is PointLoad) {
      return PointLoad(id, load.position, load.value);
    }

    if (load is DistributedLoad) {
      return DistributedLoad(id, load.position, load.positionEnd, load.value);
    }

    if (load is MomentLoad) {
      return MomentLoad(id, load.position, load.value);
    }

    return load;
  }
}
