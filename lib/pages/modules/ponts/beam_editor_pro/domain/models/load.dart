abstract class Load {
  final String id;
  final double position;
  final double value;
  const Load(this.id, this.position, this.value);
}

class PointLoad extends Load {
  const PointLoad(super.id, super.position, super.value);
}

class DistributedLoad extends Load {
  final double positionEnd;
  const DistributedLoad(super.id, super.position, this.positionEnd, super.value);
}

class MomentLoad extends Load {
  const MomentLoad(super.id, super.position, super.value);
}