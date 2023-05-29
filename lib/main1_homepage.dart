import 'package:flutter/material.dart';
import 'package:mountain_rescue_app/sub1_helppage.dart';
import 'package:mountain_rescue_app/sub2_registration.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "山岳遭難救助要請支援アプリ",
          ),
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          const Text("本アプリケーションは、山岳遭難救助要請を支援するアプリケーションです。",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          const Text(
            "救助要請に事前登録は不要です。",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 20,
            ),
          ),
          const Text("救助を求めている方がいたら速やかに救助要請ボタンを押してください。\n",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          const Text("詳しい利用方法につきましては、以下のリンクからご覧下さい。",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          TextButton(
              onPressed: () {
                var url =
                    'https://drive.google.com/file/d/1SBTKc1mZZhHzj0bK6X0apk4vhcFaHWkV/view';
                launch(url);
              },
              child: const Text("マニュアルはコチラ", style: TextStyle(fontSize: 20))),
          const Text("システム利用後、アンケートご回答にご協力お願いします。",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          TextButton(
              onPressed: () {
                var url =
                    'https://docs.google.com/forms/d/e/1FAIpQLSdbqGRr7hXWAAIk7S7aCHGCGngRpTK2Z0gKXSTRErKNg3xjMg/viewform';
                launch(url);
              },
              child:
                  const Text("アンケートご回答はコチラ", style: TextStyle(fontSize: 20))),
          Container(
              margin: const EdgeInsets.all(20),
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20.0)),
                  ),
                  onPressed: () => {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const Helppage();
                        }))
                      },
                  child: const Text("救助要請", style: TextStyle(fontSize: 30)))),
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  padding:
                      MaterialStateProperty.all(const EdgeInsets.all(20.0)),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const RegistrationPage();
                  }));
                },
                child: const Text("ユーザ登録", style: TextStyle(fontSize: 30))),
          ),
        ])));
  }
}
