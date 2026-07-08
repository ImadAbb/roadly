import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  final String message;
  final Color color;

  const InfoBanner({super.key, required this.message, this.color = Colors.orange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}


class ExpandableInfoBanner extends StatefulWidget {
  final String message;
  final Color color;

  const ExpandableInfoBanner({
    super.key,
    required this.message,
    this.color = Colors.orange,
  });

  @override
  State<ExpandableInfoBanner> createState() => _ExpandableInfoBannerState();
}

class _ExpandableInfoBannerState extends State<ExpandableInfoBanner> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: widget.color),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Text(
                      widget.message,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.justify,
                    )
                  : ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.5, 1.0],
                      ).createShader(rect),
                      blendMode: BlendMode.dstIn,
                      child: Text(
                        widget.message,
                        maxLines: 3,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
            ),
          ),
          IconButton(
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.color,
            ),
            onPressed: () => setState(() => isExpanded = !isExpanded),
          ),
        ],
      ),
    );
  }
}
