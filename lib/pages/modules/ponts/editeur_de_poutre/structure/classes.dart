//POUTRE
class Beam {
  double length;
  List<Support> supports = [];
  List<Load> loads = [];

  Beam(this.length);

  void addSupport(Support s) => supports.add(s);
  void addLoad(Load l) => loads.add(l);
}

//TYPE D'APPUIS
enum SupportType {
  simple,
  encastrement
}

//SUPPORT
class Support {
  double x;
  SupportType type;

  Support(this.x, this.type);
}

//LOAD ABSTRAITE
abstract class Load {
  double x;
  double value;

  Load(this.x, this.value);
}

//PointLoad
class PointLoad extends Load{
  PointLoad(super.x, super.value);
}

//DistributedLoad
class DistributedLoad extends Load{
  double xEnd;
  DistributedLoad(super.x, this.xEnd, super.value);
}

//TYPE DE CHARGE
enum LoadType {
  ponctuelle,
  repartie,
}
