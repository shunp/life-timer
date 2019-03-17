import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:async';
import 'dart:math';

class LifespanPage extends StatefulWidget {
  @override
  _LifespanPageState createState() => _LifespanPageState();
}

class _LifespanPageState extends State<LifespanPage> {
  final formats = {
    InputType.both: DateFormat("yyyy-MM-dd HH:mm:ss"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  InputType inputType = InputType.both;
  bool editable = true;
  DateTime birthDate;
  DateTime now;
  DateTime expectedDeathDate;

  String _getBirthDate() {
    return birthDate != null
        ? formats[InputType.date].format(birthDate)
        : '入力待ち';
  }

  String _getNow() {
    return now != null ? formats[InputType.both].format(now) : "なし";
  }

  String _getExpectedDeathDate() {
    return expectedDeathDate != null
        ? formats[InputType.date].format(expectedDeathDate)
        : "入力待ち";
  }

  String _getExpectedDeathInDays() {
    var leftTimeDuration = calcLifeTimeDuration();
    return leftTimeDuration != null ? leftTimeDuration.inDays.toString() : "-";
  }

  String _getExpectedDeathInHours() {
    var leftTimeDuration = calcLifeTimeDuration();
    return leftTimeDuration != null ? leftTimeDuration.inHours.toString() : "-";
  }

  String _getExpectedDeathInMinutes() {
    var leftTimeDuration = calcLifeTimeDuration();
    return leftTimeDuration != null
        ? leftTimeDuration.inMinutes.toString()
        : "-";
  }

  String _getExpectedDeathInSeconds() {
    var leftTimeDuration = calcLifeTimeDuration();
    return leftTimeDuration != null
        ? leftTimeDuration.inSeconds.toString()
        : "-";
  }

  Duration calcLifeTimeDuration() {
    return expectedDeathDate != null ? expectedDeathDate.difference(now) : null;
  }

  String calcLeftTimePercent() {
    Duration livingDuration = expectedDeathDate.difference(now);
    Duration averageDeathDuration =
        Duration(days: 30652, hours: 16, minutes: 48);
    int livingDurationInMillis = livingDuration.inMilliseconds;
    int averageDeathDurationInMillis = averageDeathDuration.inMilliseconds;
    print(livingDurationInMillis / averageDeathDurationInMillis);
    return (livingDurationInMillis * 100/ averageDeathDurationInMillis).toStringAsFixed(4) + "%";
  }

  void setBirthAndExpectedDeathDate(DateTime _birthDate) {
    // var averageDeathAge = 83.98; // year: 83, day: 357, hour: 16, minute: 48
    var averageDaethDuration = Duration(days: 30652, hours: 16, minutes: 48);
    setState(() {
      birthDate = _birthDate;
      expectedDeathDate = birthDate.add(averageDaethDuration);
    });
  }

  Widget _buildTitle() {
    return Container(
        // alignment: Alignment.center,
        padding: EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.mood),
            SizedBox(
              width: 5.0,
            ),
            Text(
              'あなたの残された日数を計算します',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ));
  }

  Widget _buildBirthDateInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: DateTimePickerFormField(
        inputType: inputType,
        format: formats[inputType],
        editable: editable,
        decoration: InputDecoration(
            labelText: '生年月日を入力してください', hasFloatingPlaceholder: false),
        onChanged: (birthDate) =>
            setState(() => setBirthAndExpectedDeathDate(birthDate)),
      ),
    );
  }

  Widget _buildBirthTextField() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Text("生年月日: ${_getBirthDate()}"),
    );
  }

  Widget _buildNowTextField() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Text("現在時刻: ${_getNow()}"),
    );
  }

  Widget _buildExpectedDateTextField() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          Text("平均寿命から推定されるあなたの死亡予定日"),
          SizedBox(
            height: 5.0,
          ),
          Text(
            "${_getExpectedDeathDate()}",
            style: TextStyle(fontSize: 30.0, color: Colors.red[300]),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftTimeParams() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text("推定死亡日まで残り",
                style: TextStyle(decoration: TextDecoration.underline)),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 3.0),
            child: Text(
              "日計算　：${_getExpectedDeathInDays()} 日",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 3.0),
            child: Text(
              "時計算　：${_getExpectedDeathInHours()} 時間",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 3.0),
            child: Text(
              "分計算　：${_getExpectedDeathInMinutes()} 分",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 3.0),
            child: Text(
              "秒計算　：${_getExpectedDeathInSeconds()} 秒",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialProgress() {
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          CustomPaint(
            foregroundPainter: MyPainter(
                lineColor: Colors.amber,
                completeColor: Colors.blueAccent,
                completePercent: 40,
                width: 8.0),
            child: Container(
              padding: EdgeInsets.all(10),
              height: 180.0,
              width: 180.0,
              child: RaisedButton(
                color: Colors.blue,
                shape: CircleBorder(),
                child: Text("${calcLeftTimePercent()}"),
                onPressed: () {},
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Icon(Icons.directions_run),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('LifeTimer')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildTitle(),
            _buildBirthDateInputField(),
            _buildBirthTextField(),
            _buildNowTextField(),
            _buildExpectedDateTextField(),
            _buildLeftTimeParams(),
            _buildRadialProgress(),
          ],
        ),
      ));

  // For Debug
  void currentTime() {
    print("birthDate: $birthDate");
    print("now: $now");

    var averageDeathAge = 83.98; // year: 83, day: 357, hour: 16, minute: 48
    var averageDaethDuration = Duration(days: 30652, hours: 16, minutes: 48);
    var expectedDeathDate = birthDate.add(averageDaethDuration);
    var leftDateTime = expectedDeathDate.difference(now);

    print("expectedDeathDate: $expectedDeathDate");
    print("leftDateTime: $leftDateTime");
    print("leftDateTime.inHours: ${leftDateTime.inHours}");
    print("leftDateTime.inDays: ${leftDateTime.inDays}");
    print("leftDateTime.inSeconds: ${leftDateTime.inSeconds}");
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        now = new DateTime.now();
      });
    });
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;

  MyPainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Paint complete = Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);

    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
