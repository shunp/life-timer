import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:async';
import 'dart:math';

class LifeTimerPage extends StatefulWidget {
  @override
  _LifeTimerPageState createState() => _LifeTimerPageState();
}

class _LifeTimerPageState extends State<LifeTimerPage> {
  // 日時フォーマット
  final formats = {
    InputType.both: DateFormat("yyyy-MM-dd HH:mm:ss"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // 日時
  DateTime birthDate;
  DateTime now;
  DateTime expectedDeathDate;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        now = new DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
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
              _buildRadialProgress(width),
            ],
          ),
        ));
  }

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
    var leftTimeDuration = _calcLifeTimeDuration();
    return leftTimeDuration != null ? leftTimeDuration.inDays.toString() : "-";
  }

  String _getExpectedDeathInHours() {
    var leftTimeDuration = _calcLifeTimeDuration();
    return leftTimeDuration != null ? leftTimeDuration.inHours.toString() : "-";
  }

  String _getExpectedDeathInMinutes() {
    var leftTimeDuration = _calcLifeTimeDuration();
    return leftTimeDuration != null
        ? leftTimeDuration.inMinutes.toString()
        : "-";
  }

  String _getExpectedDeathInSeconds() {
    var leftTimeDuration = _calcLifeTimeDuration();
    return leftTimeDuration != null
        ? leftTimeDuration.inSeconds.toString()
        : "-";
  }

  Duration _calcLifeTimeDuration() {
    return expectedDeathDate != null ? expectedDeathDate.difference(now) : null;
  }

  String _getLeftTimePercentStr() {
    if (expectedDeathDate == null) {
      return "- %";
    }
    return _calcLeftTimePersent().toStringAsFixed(8) + "%";
  }

  double _calcLeftTimePersent() {
    if (expectedDeathDate == null) {
      return 0.0;
    }
    Duration livingDuration = expectedDeathDate.difference(now);
    Duration averageDeathDuration =
        Duration(days: 30652, hours: 16, minutes: 48);
    int livingDurationInMillis = livingDuration.inMilliseconds;
    int averageDeathDurationInMillis = averageDeathDuration.inMilliseconds;
    return livingDurationInMillis * 100 / averageDeathDurationInMillis;
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
        padding: EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.mood),
            SizedBox(
              width: 5.0,
            ),
            Text(
              'あなたに残された日数を計算します',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ));
  }

  Widget _buildBirthDateInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: DateTimePickerFormField(
        inputType: InputType.date,
        format: formats[InputType.date],
        editable: true,
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

  Widget _buildRadialProgress(double deviceWidth) {
    double circleSize = deviceWidth * 0.7;
    double textSize = deviceWidth * 0.065;
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomPaint(
            foregroundPainter: MyPainter(
                lineColor: Colors.grey,
                completeColor: Colors.blueAccent,
                completePercent: _calcLeftTimePersent(),
                width: 8.0),
            child: Container(
              padding: EdgeInsets.all(10),
              height: circleSize,
              width: circleSize,
              child: RaisedButton(
                color: Colors.blue,
                shape: CircleBorder(),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.directions_run,
                      size: textSize,
                    ),
                    Text(
                      "${_getLeftTimePercentStr()}",
                      style: TextStyle(fontSize: textSize),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ),
          // Container(
          //   padding: EdgeInsets.all(10),
          //   child: Text("残りの時間を大切に！", style: TextStyle(
          //     fontSize: 15.0,

          //   ),
          //   ),

          // )
        ],
      ),
    );
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
