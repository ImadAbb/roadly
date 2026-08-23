import 'package:flutter/material.dart';

class ProMaxEffortsCard extends StatelessWidget {
  final double momentMaxPositive;
  final double momentMaxPositivePos;
  final double momentMaxNegative;
  final double momentMaxNegativePos;
  final double shearMaxPositive;
  final double shearMaxPositivePos;
  final double shearMaxNegative;
  final double shearMaxNegativePos;

  const ProMaxEffortsCard({
    super.key,
    required this.momentMaxPositive,
    required this.momentMaxPositivePos,
    required this.momentMaxNegative,
    required this.momentMaxNegativePos,
    required this.shearMaxPositive,
    required this.shearMaxPositivePos,
    required this.shearMaxNegative,
    required this.shearMaxNegativePos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EffortBox(
          label: 'M max',
          value: momentMaxPositive,
          unit: 'kN·m',
          position: momentMaxPositivePos,
          color: const Color(0xFF16A34A),
        ),
        const SizedBox(height: 6),
        _EffortBox(
          label: 'M min',
          value: momentMaxNegative,
          unit: 'kN·m',
          position: momentMaxNegativePos,
          color: const Color(0xFFDC2626),
        ),
        const SizedBox(height: 6),
        _EffortBox(
          label: 'T max',
          value: shearMaxPositive,
          unit: 'kN',
          position: shearMaxPositivePos,
          color: const Color(0xFFEAB308),
        ),
        const SizedBox(height: 6),
        _EffortBox(
          label: 'T min',
          value: shearMaxNegative,
          unit: 'kN',
          position: shearMaxNegativePos,
          color: const Color(0xFF2563EB),
        ),
      ],
    );
  }
}

class _EffortBox extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double position;
  final Color color;

  const _EffortBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.position,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${value.toStringAsFixed(2)} $unit',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'x = ${position.toStringAsFixed(2)} m',
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}