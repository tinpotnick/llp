
import 'package:flutter/material.dart';

class SliderWithCustomTrack extends StatefulWidget {

  final double? min;
  final double? max;
  final void Function(double)? onChanged;
  final double? value;
  final double? duration;

  const SliderWithCustomTrack({
    super.key,
    this.min,
    this.max,
    this.duration,
    this.onChanged,
    this.value,
  });

  @override
  SliderWithCustomTrackState createState() => SliderWithCustomTrackState();
}

class SliderWithCustomTrackState extends State<SliderWithCustomTrack> {
  
  // Define the section where the track is purple
  double sectionStart = 0;
  double sectionEnd = 0;
  double totalDuration = 0;
  double pos = 0;

  @override
  void initState() {
    super.initState();

    sectionStart = widget.min ?? 0;
    sectionEnd = widget.max ?? 0;
    totalDuration = widget.duration ?? 0;

    pos = widget.value ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: CustomSectionSliderTrackShape(
              sectionStart: sectionStart,
              sectionEnd: sectionEnd,
              min: 0,
              max: totalDuration
            ),
          ),
          child: Slider(
            value: pos,
            onChanged: (newvalue) {
              setState(() {
                pos = newvalue;
              });

              if( widget.onChanged != null ) {
                widget.onChanged!(newvalue);
              }
            },
            min: 0,
            max: totalDuration,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class CustomSectionSliderTrackShape extends SliderTrackShape {
  final double sectionStart;
  final double sectionEnd;
  final double min;
  final double max;

  CustomSectionSliderTrackShape({
    required this.sectionStart,
    required this.sectionEnd,
    required this.min,
    required this.max,
  });

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final double trackWidth = trackRect.width;
    final double trackLeft = trackRect.left;

    // Calculate the start and end points for the purple section
    final double sectionStartX = trackLeft + ((sectionStart - min) / (max - min)) * trackWidth;
    final double sectionEndX = trackLeft + ((sectionEnd - min) / (max - min)) * trackWidth;

    final Paint activePaint = Paint()..color = sliderTheme.activeTrackColor!;
    final Paint inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;
    final Paint sectionLeftPaint = Paint()..color = Colors.purpleAccent; // Purple if left of thumb
    final Paint sectionRightPaint = Paint()..color = Colors.purple; // Purple if right of thumb

    // Draw inactive track after the thumb
    final Rect inactiveAfterRect = Rect.fromLTWH(thumbCenter.dx, trackRect.top, trackLeft + trackWidth - thumbCenter.dx, trackRect.height);
    context.canvas.drawRect(inactiveAfterRect, inactivePaint);

    // Draw active track (everything left of the thumb)
    final Rect activeTrackRect = Rect.fromLTWH(trackLeft, trackRect.top, thumbCenter.dx - trackLeft, trackRect.height);
    context.canvas.drawRect(activeTrackRect, activePaint);

    // Draw the purple section
    if (thumbCenter.dx <= sectionStartX) {
      // Thumb is entirely left of the purple section
      final Rect purpleRect = Rect.fromLTWH(sectionStartX, trackRect.top, sectionEndX - sectionStartX, trackRect.height);
      context.canvas.drawRect(purpleRect, sectionRightPaint);
    } else if (thumbCenter.dx >= sectionEndX) {
      // Thumb is entirely right of the purple section
      final Rect purpleRect = Rect.fromLTWH(sectionStartX, trackRect.top, sectionEndX - sectionStartX, trackRect.height);
      context.canvas.drawRect(purpleRect, sectionLeftPaint);
    } else {
      // Thumb is inside the purple section, split into two parts
      final Rect purpleLeftRect = Rect.fromLTWH(sectionStartX, trackRect.top, thumbCenter.dx - sectionStartX, trackRect.height);
      final Rect purpleRightRect = Rect.fromLTWH(thumbCenter.dx, trackRect.top, sectionEndX - thumbCenter.dx, trackRect.height);

      context.canvas.drawRect(purpleLeftRect, sectionLeftPaint);
      context.canvas.drawRect(purpleRightRect, sectionRightPaint);
    }
  }
}
