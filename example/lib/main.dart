import 'package:flutter/material.dart';
import 'package:flutter_zalo_login/flutter_zalo_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ZaloLoginResult zaloLoginResult;
  ZaloProfileModel zaloInfo;

  @override
  void initState() {
    super.initState();
    ZaloLogin.channel.invokeMethod('init');
  }

  void _loginZalo() async {
    print(await ZaloLogin.channel.invokeMethod('getPlatformVersion'));

    var res = await ZaloLogin().logIn();
    setState(() {
      zaloLoginResult = res;
    });
    print(res);
  }

  void _logoutZalo() async {
    await ZaloLogin().logOut();
    setState(() {
      zaloLoginResult = null;
    });
  }

  void _getInfo() async {
    var info = await ZaloLogin().getInfo();
    setState(() {
      zaloInfo = info;
    });
    print(info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("Đăng nhập bằng Zalo"),
              onPressed: _loginZalo,
              color: Theme.of(context).primaryColor,
            ),
            FlatButton(
              child: Text("get info"),
              onPressed: _getInfo,
              color: Theme.of(context).accentColor,
            ),
            FlatButton(
              child: Text("Đăng xuất"),
              onPressed: _logoutZalo,
              color: Theme.of(context).buttonColor,
            ),
            Text(
              'Zalo info:',
            ),
            if (zaloLoginResult != null)
              Text(
                zaloLoginResult.toJson().toString(),
              ),
            if (zaloInfo != null)
              Text(
                zaloInfo.toJson().toString(),
              ),
            if (zaloInfo != null) Image.network(zaloInfo.picture.data.url),
          ],
        ),
      ),
    );
  }
}
