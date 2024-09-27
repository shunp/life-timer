import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../widgets/lifetimer_painter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  // 文字列
  String name;

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        now = new DateTime.now();
      });
      // 通知タイミング
      
      String url = "https://fcm.googleapis.com/fcm/send";
      // Map<String, dynamic> body = NotifyMessage.toMap();
      var a = createPost(url);
      print(a);
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _buildDialog(context, "onMessage");
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

  void _buildDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new Text("Message: $message"),
            actions: <Widget>[
              new FlatButton(
                child: const Text('CLOSE'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              new FlatButton(
                child: const Text('SHOW'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

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
            _buildNameInputField(),
            Image.asset(
              'images/gakki_mu.jpg',
              width: 600,
              height: 250,
              fit: BoxFit.cover,
            ),
            _buildGakkiComment(),
            _buildBirthTextField(),
            _buildNowTextField(),
            _buildExpectedDateTextField(),
            _buildLeftTimeParams(),
            _buildRadialProgress(width),
          ],
        ),
      ),
    );
  }

  void setName(String _name) {
    setState(() {
      name = _name;
    });
  }

  String _getName() {
    return name != null ? name : "平匡";
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
                onPressed: () async {
                  print("onpress");
                  String url = "https://fcm.googleapis.com/fcm/send";
                  // Map<String, dynamic> body = NotifyMessage.toMap();
                  var a = await createPost(url);
                  print(a);
                  print("finish");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGakkiComment() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          Text("「${_getName()}さん！！"
              "寿命が残り${_getExpectedDeathInDays()}日くらいだそうですよ！」",
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        decoration: InputDecoration(
            labelText: '名前を入力してください', hasFloatingPlaceholder: false),
        onChanged: (name) =>
            setState(() => setName(name)),
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

  Future<String> createPost(String url) async {
    Map<String, String> headers = {
      "Authorization":
          "key=AAAANhJF6ZM:APA91bElIlTd2ykWYlPEqPlYMdJoNIJGLf8qhFNxBENmTQ3Ftnh7MBglvzAGpA0uB9YJSNO7bgJAz2gt30gxV87gJ0eWGPbUACGCQA9qUmbVpkh3S5O6xI-01dphmZwEvpufL59dN4Js"
    };
    Map body = {
      "notification": {"body": "this is a body", "title": "this is a title"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": "/topics/all"
    };
    await apiRequest(url, body);
  }

  Future<String> apiRequest(String url, Map jsonMap) async {
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
}
