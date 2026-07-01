import 'package:roadly/pages/modules/ponts/beam_editor_v1/editeur_de_poutre/structure/classes.dart';

//ABSTRACT COMMAND
abstract class Command {
  final String label;
  Command(this.label);

  void execute(Beam beam);
}

//AJOUTER UN(COMMAND)
class AddSupportCommand extends Command {
  final double position;
  final SupportType type;

  AddSupportCommand(this.position, this.type)
    : super("Aj. support");

  @override
  void execute (Beam beam) {
    beam.addSupport(Support(position, type));
  }
}

class AddLoadCommand extends Command {
  final double position;
  final double value;
  final LoadType type;
  final double? xEnd;

  AddLoadCommand(this.position, this.value, this.type, {this.xEnd}) : super("Aj. charge");

@override
  void execute(Beam beam) {
    if (type == LoadType.ponctuelle) {
      beam.addLoad(PointLoad(position, value));
    } else if (type == LoadType.repartie && xEnd != null) {
      beam.addLoad(DistributedLoad(position, xEnd!, value));
    }
  }
}

class DeleteCommand extends Command {
  DeleteCommand() : super("SUPPR");

  @override
  void execute(Beam beam) {
    beam.supports.clear();
    beam.loads.clear();
  }
}

class Modify extends Command {
  Modify() : super("Modifieer");

  @override
  void execute(Beam beam) {
  }
}
