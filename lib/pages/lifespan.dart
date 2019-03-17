import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:async';

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
  // Duration leftTimeDuration;

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
    return leftTimeDuration != null
        ? leftTimeDuration.inHours.toString()
        : "-";
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

  void setBirthAndExpectedDeathDate(DateTime _birthDate) {
    // var averageDeathAge = 83.98; // year: 83, day: 357, hour: 16, minute: 48
    var averageDaethDuration = Duration(days: 30652, hours: 16, minutes: 48);
    setState(() {
      birthDate = _birthDate;
      expectedDeathDate = birthDate.add(averageDaethDuration);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('LifeTimer')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text('Lifetimer: あなたの残り日数を計算します'),
            //
            // The widget.
            //
            DateTimePickerFormField(
              inputType: inputType,
              format: formats[inputType],
              editable: editable,
              decoration: InputDecoration(
                  labelText: '生年月日を入力してください', hasFloatingPlaceholder: false),
              onChanged: (birthDate) =>
                  setState(() => setBirthAndExpectedDeathDate(birthDate)),
            ),

            Text("生年月日: ${_getBirthDate()}"),
            SizedBox(height: 16.0),

            Text("現在時刻: ${_getNow()}"),
            SizedBox(height: 16.0),

            Text("平均寿命から推定されるあなたの死亡予定日: ${_getExpectedDeathDate()}"),
            SizedBox(height: 16.0),

            Text("推定死亡日まで残り"),
            Text("日計算　：${_getExpectedDeathInDays()} 日"),
            Text("時計算　：${_getExpectedDeathInHours()} 時間"),
            Text("分計算　：${_getExpectedDeathInMinutes()} 分"),
            Text("秒計算　：${_getExpectedDeathInSeconds()} 秒"),
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
