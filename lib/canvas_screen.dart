import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  _CanvasScreenState createState() => _CanvasScreenState();
}

class Drawing {
  Offset points;
  Paint painter;

  Drawing({required this.points, required this.painter});
}

class _CanvasScreenState extends State<CanvasScreen> {
  List<Drawing> offsets = [];
  double _sWidth = 10;
  Color selectedColor = Colors.black;
  int length = 0;

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            TextButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openColorPicker() async {
    _openDialog(
      "Color picker",
      MaterialColorPicker(
        selectedColor: selectedColor,
        onColorChange: (color) => setState(() => selectedColor = color),
        onBack: () => print("Back button pressed"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canvas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    offsets.add(Drawing(
                        points: details.localPosition,
                        painter: Paint()
                          ..strokeWidth = _sWidth
                          ..strokeCap = StrokeCap.round
                          ..isAntiAlias = true
                          ..color = selectedColor));
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    offsets.add(Drawing(
                        points: details.localPosition,
                        painter: Paint()
                          ..strokeWidth = _sWidth
                          ..strokeCap = StrokeCap.round
                          ..isAntiAlias= true
                          ..color = selectedColor));
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    offsets.add(Drawing(
                        points: Offset(double.infinity, double.infinity),
                        painter: Paint()));
                  });
                },
                child: CustomPaint(
                  painter: Painter(
                    offsets: offsets,
                    strokeWidth: _sWidth.toDouble(),
                    startIndex: 0,
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _openColorPicker();
                  },
                  icon: Icon(FontAwesomeIcons.paintBrush),
                ),
                Expanded(
                    child: Slider(
                  value: _sWidth,
                  min: 1,
                  max: 10,
                  divisions: 10,
                  label: "${_sWidth.round()}",
                  onChanged: (double value) {
                    setState(() {
                      _sWidth = value;
                    });
                  },
                )),
                IconButton(
                  onPressed: () {
                    setState(() {
                      for (int i = offsets.length - 2; i > 0; i--) {
                        if (offsets.length <= 3) {
                          offsets.clear();
                          break;
                        }
                        if (offsets[i].points.dx == double.infinity &&
                            offsets[i].points.dy == double.infinity) {
                          break;
                        }

                        offsets.removeAt(i);
                      }
                      for (int i = offsets.length - 1; i > 0; i++) {
                        if (offsets[i].points.dx == double.infinity &&
                            offsets[i].points.dy == double.infinity) {
                          offsets.removeAt(i);
                        }
                      }
                    });
                  },
                  icon: Icon(FontAwesomeIcons.undo),
                ), // undo
                IconButton(
                  onPressed: () {
                    setState(() {
                      offsets.clear();
                    });
                  },
                  icon: Icon(FontAwesomeIcons.trash),
                ), //trash
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Painter extends CustomPainter {
  Painter(
      {required this.offsets,
      required this.strokeWidth,
      required this.startIndex});

  List<Drawing> offsets;
  double strokeWidth;
  int startIndex;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = startIndex; i < offsets.length; i++) {
      Paint p = offsets[i].painter;
      if (i + 1 >= offsets.length) {
        canvas.drawLine(offsets[i].points, offsets[i].points, p);
      } else {
        canvas.drawLine(offsets[i].points, offsets[i + 1].points, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
