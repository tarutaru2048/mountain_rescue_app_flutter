//ユーザ登録用ページ
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  DateTime _birthday = DateTime.now();
  String _birthdaytext = '誕生日を入力してね';
  String _birthdaytextshort = '';
  DateTime _createday = DateTime.now();
//  String _namelast = '';
//  String _namefirst = '';
  String _fullname = '';
  String _furigana = '';
  String _sex = 'male';
  String _sextext = '男';
  int _publish = 0; //公開設定 0が公開
  String _publishtext = "公開する";

  //名前周辺をちょっと変更。

  String _doc = ''; //docIDを格納
  String _json = ''; //苗字名前,性別,誕生日,公開設定等をまとめた１つのjsonファイル。これがQRコードとなる。

  final _formKey = GlobalKey<FormState>();
  final textEditingController = TextEditingController();

  //性別変更のラジオボタン用の関数
  void _changesex(String? value) {
    setState(() {
      _sex = value!;
      if (_sex == "male") {
        _sextext = "男";
      } else if (_sex == "female") {
        _sextext = "女";
      } else {
        _sextext = "回答しない";
      }
    });
  }

  //公開設定のラジオボタン用の関数
  void _changepub(int? value) {
    setState(() {
      _publish = value!;
      if (_publish == 0) {
        _publishtext = "公開する";
      } else {
        _publishtext = "公開しない";
      }
    });
  }

  //TextFormFieldにDatePickerで入力するための関数

  //ランダムな文字列の作成(uid,Document IDの生成の為)
  String generateNonce([int length = 16]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    final randomStr =
        List.generate(length, (_) => charset[random.nextInt(charset.length)])
            .join();
    return randomStr;
  }

  //jsonファイルを生成する関数。引数に公開設定を取る。でも関数としては汚い気がする。まあいっか...
  String makingjson(int publish) {
    if (publish == 0) {
      String makingjson = '{"do":"' +
          _doc +
          '","fn":"' +
          _fullname +
          '","fr":"' +
          _furigana +
          '","se":"' +
          _sex +
          '","bs":"' +
          _birthdaytextshort +
          '"}';
      return makingjson;
    } else {
      String makingjson = '{"do":"' +
          _doc +
          '","fn":"' +
          "NULL" +
          '","fr":"' +
          "NULL" +
          '","se":"' +
          "NULL" +
          '","bs":"' +
          "NULL" +
          '"}';
      return makingjson;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("ユーザ登録")),
        body: Form(
            //Formではさむ必要がある。
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //お名前入力フォーム(フルネーム)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'お名前(フルネーム)'),
                    onChanged: (String value) {
                      setState(() {
                        _fullname = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'お名前を入力してください';
                      }
                      return null;
                    },
                  ),
                  //フリガナ入力フォーム
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'フリガナ'),
                    onChanged: (String value) {
                      setState(() {
                        _furigana = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'フリガナを入力してください';
                      }
                      return null;
                    },
                  ),

                  //誕生日入力
                  TextFormField(
                    decoration: const InputDecoration(labelText: '誕生日'),
                    controller: textEditingController,
                    onTap: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(1900, 1, 1),
                          maxTime: DateTime.now(),
                          onChanged: (date) {}, onConfirm: (date) {
                        setState(() {
                          _birthday = date;
                          _birthdaytextshort = date.year.toString() +
                              "-" +
                              date.month.toString() +
                              "-" +
                              date.day.toString();
                          _birthdaytext = date.year.toString() +
                              "年" +
                              date.month.toString() +
                              "月" +
                              date.day.toString() +
                              "日";
                          textEditingController.text = _birthdaytext;
                        });
                      }, currentTime: DateTime.now(), locale: LocaleType.jp);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '誕生日を入力してください';
                      }
                      return null;
                    },
                  ),

                  //性別入力
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("性別"),
                      Row(
                        children: [
                          Radio(
                            value: "male",
                            groupValue: _sex,
                            activeColor: Colors.blue,
                            onChanged: _changesex,
                          ),
                          const Text('男')
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: "female",
                            groupValue: _sex,
                            activeColor: Colors.blue,
                            onChanged: _changesex,
                          ),
                          const Text('女')
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: "no_answer",
                            groupValue: _sex,
                            activeColor: Colors.blue,
                            onChanged: _changesex,
                          ),
                          const Text('回答しない')
                        ],
                      ),
                    ],
                  ),

                  //公開設定
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("公開設定 ※"),
                      Row(
                        children: [
                          Radio(
                            value: 0,
                            groupValue: _publish,
                            activeColor: Colors.blue,
                            onChanged: _changepub,
                          ),
                          const Text('公開する')
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 1,
                            groupValue: _publish,
                            activeColor: Colors.blue,
                            onChanged: _changepub,
                          ),
                          const Text('公開しない')
                        ],
                      ),
                    ],
                  ),

                  Padding(
                    //情報確定ボタン(QRコード作成ボタン)
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text("以下の内容でユーザー登録しますか？"),
                                content: Text("誕生日: " +
                                    _birthdaytext +
                                    "\nお名前: " +
                                    _fullname +
                                    "\nフリガナ: " +
                                    _furigana +
                                    "\n性別: " +
                                    _sextext +
                                    "\n公開設定: " +
                                    _publishtext),
                                actions: [
                                  TextButton(
                                    child: const Text('cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () async {
                                      //情報をクラウドに保存し、次のページに遷移。次のページでは、QRコードを作成する。
                                      setState(() {
                                        _createday = DateTime.now();
                                        _doc = generateNonce();
                                        //json形式のファイルを作っている。公開設定を反映させる形式で、公開設定をpublishに渡す
                                        _json = makingjson(_publish);
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('User') // コレクションID
                                          .doc(
                                              _doc) //docIDは16桁でランダム付加。(検索時に用いられる。)
                                          .set({
                                        'birthday': _birthday,
                                        'createdate': _createday,
                                        'fullname': _fullname,
                                        'furigana': _furigana,
                                        'sex': _sex,
                                      }); // データが以上の形で保存される。
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              // （2） 実際に表示するページ(ウィジェット)を指定する(つーかあらかじめjson形式に纏めちゃえよ)
                                              builder: (context) => NextPage(
                                                    fullname2: _fullname,
                                                    furigana2: _furigana,
                                                    birthdaytext2:
                                                        _birthdaytext,
                                                    sextext2: _sextext,
                                                    json2: _json,
                                                  )));
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text(
                        'QRコード生成',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const Text(
                    "※公開するを選択した場合、お名前と誕生日、性別が発見者にも公開されます。\n公開しないを選択した場合、上記の内容は発見者には公開されませんが、山岳救助隊の方には名前、誕生日、性別が公開されます。",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            )));
  }
}

//Statelessで作れたら楽だけどどうかな?
class NextPage extends StatelessWidget {
  final String fullname2;
  final String furigana2;
  final String birthdaytext2;
  final String sextext2;
  final String json2;
  int count = 0;

  NextPage(
      {Key? key,
      required this.fullname2,
      required this.furigana2,
      required this.birthdaytext2,
      required this.sextext2,
      required this.json2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("内容確認画面")),
        body: Center(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
              const Text("QRコードが生成されました。", style: TextStyle(fontSize: 15)),
              const Text(
                  "以下のQRコードをスクリーンショットし、保存してください。\n保存したQRコードを印刷し、登山中に持参してください。",
                  style: TextStyle(fontSize: 15)),
              QrImage(
                data: json2,
                version: QrVersions.auto,
                size: 300.0,
                padding: const EdgeInsets.all(50),
              ),
              Text(
                  "お名前: " +
                      fullname2 +
                      "\nフリガナ: " +
                      furigana2 +
                      "\n性別: " +
                      sextext2 +
                      "\n生年月日: " +
                      birthdaytext2,
                  style: const TextStyle(fontSize: 15)),
              const Text(
                  "\n注意：一度トップページに戻ると再度QRコードタグを表示させることは出来ませんので、必ずスクリーンショットをして保存してください。\n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ElevatedButton(
                child: const Text("トップページに戻る", style: TextStyle(fontSize: 30)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  padding:
                      MaterialStateProperty.all(const EdgeInsets.all(12.0)),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (_) => count++ >= 2);
                },
              ),
            ]))));
  }
}
