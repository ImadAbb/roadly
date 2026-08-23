class CalculationPoint {
  final double position;
  final double value;

  const CalculationPoint({
    required this.position,
    required this.value,
  });

  @override
  String toString() {
    return 'CalculationPoint(x: $position, value: $value)';
  }
}