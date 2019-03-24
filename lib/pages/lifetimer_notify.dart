import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../widgets/lifetimer_painter.dart';
import '../widgets/flip_counter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LifeTimerNotifyPage extends StatefulWidget {
  @override
  _LifeTimerNotifyPageState createState() => _LifeTimerNotifyPageState();
}

class _LifeTimerNotifyPageState extends State<LifeTimerNotifyPage> {
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
  // 通知
  bool doNotify = false;

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    setState(() {
      digits = [];
      for (int i = 0; i < 60; i++) {
        digits.add(60 - i);
      }
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        now = new DateTime.now();
      });
      notifyLeftTime();
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _buildDialog(context, _getLeftTimePercentStr());
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _buildDialog(context, "onLaunch");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _buildDialog(context, "onResume");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });
    _firebaseMessaging.subscribeToTopic("/topics/all");
  }

  @override
  void dispose() {
    notifyTermController.dispose();
    notifyTermFocusNode.dispose();
    super.dispose();
  }

  void _buildDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new Text("寿命は残り: ${_getLeftTimePercentStr()}"),
            actions: <Widget>[
              new FlatButton(
                child: const Text('CLOSE'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              new FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

  var digits = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("LifeTimer")),
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
            _buildNotifySettings(width),
            _buildFlipCounter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
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
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
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
        onChanged: (birthDate) => _setBirthAndExpectedDeathDate(birthDate),
      ),
    );
  }

  void _setBirthAndExpectedDeathDate(DateTime _birthDate) {
    // var averageDeathAge = 83.98; // year: 83, day: 357, hour: 16, minute: 48
    var averageDaethDuration = Duration(days: 30652, hours: 16, minutes: 48);
    setState(() {
      birthDate = _birthDate;
      expectedDeathDate = birthDate.add(averageDaethDuration);
    });
  }

  Widget _buildBirthTextField() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Text("生年月日: ${_getBirthDate()}"),
    );
  }

  String _getBirthDate() {
    return birthDate != null
        ? formats[InputType.date].format(birthDate)
        : '入力待ち';
  }

  Widget _buildNowTextField() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Text("現在時刻: ${_getNow()}"),
    );
  }

  String _getNow() {
    return now != null ? formats[InputType.both].format(now) : "なし";
  }

  Widget _buildExpectedDateTextField() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          Text("平均寿命から計算されるあなたの推定命日"),
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

  String _getExpectedDeathDate() {
    return expectedDeathDate != null
        ? formats[InputType.date].format(expectedDeathDate)
        : "入力待ち";
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

  Widget _buildRadialProgress(double deviceWidth) {
    double circleSize = deviceWidth * 0.7;
    double textSize = deviceWidth * 0.065;
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomPaint(
            foregroundPainter: LifeTimerPainter(
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
        ],
      ),
    );
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

  // Toggle
  void switchNotify(bool notify) {
    notifyTermFocusNode.unfocus();
    setState(() {
      doNotify = notify;
    });
  }

  FocusNode notifyTermFocusNode = FocusNode();
  final notifyTermController = TextEditingController();

  Widget _buildNotifySettings(double deviceWidth) {
    return Row(
      children: <Widget>[
        Text("通知する"),
        Switch(value: doNotify, onChanged: switchNotify),
        Container(
          width: deviceWidth * 0.5,
          child: TextField(
            keyboardType: TextInputType.number,
            focusNode: notifyTermFocusNode,
            decoration: InputDecoration(labelText: "通知間隔(秒)"),
            controller: notifyTermController,
          ),
        )
      ],
    );
  }

  Future<String> notifyLeftTime() async {
    try {
      int notifyTerm = int.parse(notifyTermController.text);
      print(now.second);
      if (now.second % notifyTerm == 0 && doNotify) {
        setState(() {
          digits = [];
          for (int i = 0; i < notifyTerm; i++) {
            digits.add(notifyTerm - i);
            print(digits);
          }
        });

        String url = "https://fcm.googleapis.com/fcm/send";
        String notifyBody = _getLeftTimePercentStr();
        String notifyTitle = "あなたの残り寿命は";
        Map body = {
          "notification": {"body": notifyBody, "title": notifyTitle},
          "priority": "high",
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "id": "1",
            "status": "done"
          },
          "to": "/topics/all"
        };
        return await post(url, body);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> post(String url, Map jsonMap) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization',
        'key=AAAANhJF6ZM:APA91bElIlTd2ykWYlPEqPlYMdJoNIJGLf8qhFNxBENmTQ3Ftnh7MBglvzAGpA0uB9YJSNO7bgJAz2gt30gxV87gJ0eWGPbUACGCQA9qUmbVpkh3S5O6xI-01dphmZwEvpufL59dN4Js');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  Widget _buildFlipCounter() {
    if (!doNotify) {
      return Container();
    } else {
      return Center(
        child: FlipPanel.builder(
          itemBuilder: (context, index) => Container(
                alignment: Alignment.center,
                width: 120.0,
                height: 128.0,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: Text(
                  '${digits[index]}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 80.0,
                      color: Colors.yellow),
                ),
              ),
          itemsCount: digits.length,
          period: Duration(milliseconds: 1000),
          loop: -1,
        ),
      );
    }
  }
}
