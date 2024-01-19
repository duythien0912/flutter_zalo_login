import 'dart:developer';

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
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ZaloProfileModel? zaloInfo = ZaloProfileModel(
    birthday: "",
    gender: "",
    id: "",
    name: "",
    picture: null,
  );

  ZaloLoginResult? zaloLoginResult = ZaloLoginResult(
    errorCode: -1,
    errorMessage: "",
    oauthCode: "",
    userId: "",
  );

  bool _authenticated = false;
  String _hashKey = '';

  @override
  void initState() {
    super.initState();
    _initZalo();
  }

  void _initZalo() async {
    String hashKey = await ZaloLogin().init();
    setState(() {
      _hashKey = hashKey;
    });
    log('$hashKey');
  }

  void _loginZalo() async {
    ZaloLoginResult res = await ZaloLogin().logIn();
    setState(() {
      zaloLoginResult = res;
    });
    log('${res.toJson()}');
  }

  void _isAuthenticated() async {
    bool isAuthenticated = await ZaloLogin().isAuthenticated();
    log('$isAuthenticated');
    setState(() {
      _authenticated = isAuthenticated;
    });
  }

  void _logoutZalo() async {
    await ZaloLogin().logOut();
    setState(() {
      zaloLoginResult = null;
      zaloInfo = null;
      _authenticated = false;
    });
  }

  void _getInfo() async {
    ZaloProfileModel info = await ZaloLogin().getInfo();
    setState(() {
      zaloInfo = info;
    });
    log('${info.toJson()}');
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
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                VerticalDivider(),
                SizedBox(
                  child: TextButton(
                    child: Text(
                      "Init Zalo",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _initZalo,
                    // color: Theme.of(context).accentColor,
                  ),
                  width: 150,
                ),
                VerticalDivider(),
                if (_hashKey.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "hashKey: " + _hashKey,
                          // overflow: TextOverflow.ellipsis,
                          // maxLines: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                VerticalDivider(),
                SizedBox(
                  child: TextButton(
                    child: Text(
                      "Login Zalo",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _loginZalo,
                    // color: Theme.of(context).accentColor,
                  ),
                  width: 150,
                ),
                VerticalDivider(),
                if (zaloLoginResult != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "oauthCode: " +
                              (zaloLoginResult?.oauthCode.toString() ?? ''),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text("errorCode: " +
                            (zaloLoginResult?.errorCode.toString() ?? '')),
                        Text("userId: " + (zaloLoginResult?.userId ?? '')),
                      ],
                    ),
                  ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                VerticalDivider(),
                SizedBox(
                  width: 150,
                  child: TextButton(
                    child: Text(
                      "Is Authenticated",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _isAuthenticated,
                    // color: Theme.of(context).accentColor,
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  child: Text(
                    "Is Authenticated: " + _authenticated.toString(),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                VerticalDivider(),
                SizedBox(
                  width: 150,
                  child: TextButton(
                    child: Text(
                      "Get info",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _getInfo,
                    // color: Theme.of(context).accentColor,
                  ),
                ),
                VerticalDivider(),
                if (zaloInfo != null && zaloInfo?.id != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (zaloInfo != null && zaloInfo?.picture != null)
                          Image.network(zaloInfo?.picture?.data?.url ?? ''),
                        Text(
                          "id: " + (zaloInfo?.id ?? ''),
                        ),
                        Text(
                          "name: " + (zaloInfo?.name ?? ''),
                        ),
                        Text(
                          "birthday: " + (zaloInfo?.birthday ?? ''),
                        ),
                        Text(
                          "gender: " + (zaloInfo?.gender ?? ''),
                        ),
                      ],
                    ),
                  )
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                VerticalDivider(),
                SizedBox(
                  width: 150,
                  child: TextButton(
                    child: Text("Logout"),
                    onPressed: _logoutZalo,
                    // color: Theme.of(context).buttonColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
