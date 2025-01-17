
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
    sectionEnd = widget.max ?? 100;
    totalDuration = widget.duration ?? 100;
    pos = widget.value ?? sectionStart;

    // Ensure valid range
    if (sectionStart >= sectionEnd) {
      sectionEnd = sectionStart + 1;
    }
    if(sectionEnd >= totalDuration){
        totalDuration = sectionEnd;
    }
    if( pos >= sectionEnd ) {
      pos = sectionStart;
    }
  }

  @override
  void didUpdateWidget(covariant SliderWithCustomTrack oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update state when widget properties change
    if (widget.min != oldWidget.min || widget.max != oldWidget.max) {
      sectionStart = widget.min ?? 0;
      sectionEnd = widget.max ?? 100;
    }
    if (widget.duration != oldWidget.duration) {
      totalDuration = widget.duration ?? 100;
    }
    if (widget.value != oldWidget.value) {
      pos = widget.value ?? sectionStart;
    }
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
            onChanged: (newValue) {
              setState(() {
                // Clamp the value within min and max
                pos = newValue.clamp(sectionStart, sectionEnd);
              });

              if (widget.onChanged != null) {
                widget.onChanged!(pos);
              }
            },
            min: sectionStart,
            max: sectionEnd,
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

    // Avoid division-by-zero by ensuring max > min
    if (max <= min) return;

    // Normalize sectionStart and sectionEnd to within the track
    final double sectionStartX = trackLeft + ((sectionStart - min) / (max - min)) * trackWidth;
    final double sectionEndX = trackLeft + ((sectionEnd - min) / (max - min)) * trackWidth;

    // Paint the track
    final Paint activePaint = Paint()..color = sliderTheme.activeTrackColor!;
    final Paint inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;
    final Paint purplePaint = Paint()..color = Colors.purpleAccent;

    // Draw inactive track after thumb
    final Rect inactiveAfterRect = Rect.fromLTWH(thumbCenter.dx, trackRect.top, trackLeft + trackWidth - thumbCenter.dx, trackRect.height);
    context.canvas.drawRect(inactiveAfterRect, inactivePaint);

    // Draw active track (everything left of thumb)
    final Rect activeTrackRect = Rect.fromLTWH(trackLeft, trackRect.top, thumbCenter.dx - trackLeft, trackRect.height);
    context.canvas.drawRect(activeTrackRect, activePaint);

    // Draw the purple section
    if (sectionEndX > sectionStartX) {
      final Rect purpleRect = Rect.fromLTWH(sectionStartX, trackRect.top, sectionEndX - sectionStartX, trackRect.height);
      context.canvas.drawRect(purpleRect, purplePaint);
    }
  }
}
