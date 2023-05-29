//救助時に使うページ
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:math';
import 'dart:convert';

class Helppage extends StatefulWidget {
  const Helppage({Key? key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<Helppage> {
  String _location = "";
  String _now = "";
  String _suffererdoc = "";
  String? _qrdatajson;
  Image? _image;
  Uint8List? _uploaddata;
  DateTime? _helpday;
  String? _sufferertext;
  String? _accident;
  String? _discovererName; //発見者の名前を保存する関数
  var qrcodedata1;
  final _formKey = GlobalKey<FormState>();

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

  //時刻を取得する関数
  void _gettime() {
    setState(() {
      var now = DateTime.now();

      _now = "${now.year}年${now.month}月${now.day}日 ${now.hour}時${now.minute}分";
    });
  }

  //場所を取得する関数
  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String latitude = position.latitude.toString();
    String lontitude = position.longitude.toString();
    setState(() {
      _location = "\n緯度:" + latitude + "\n経度:" + lontitude;
    });
  }

  //jsonデータの処理
  String? _getteddata() {
    var jsonString = _qrdatajson;
    try {
      var jsonText = jsonDecode(jsonString!);
      var docid = jsonText["do"];

      var fullname = jsonText["fn"];
      var furigana = jsonText["fr"];
      var sex = jsonText["se"];
      var birthday = jsonText["bs"];
      //もし非公開設定だった時
      if (jsonText["fn"] == "NULL") {
        fullname = "非公開設定";
        furigana = "非公開設定";
        sex = "非公開設定";
        birthday = "非公開設定";
      }

      qrcodedata1 = ("\nユーザーID: " +
          docid +
          "\nお名前: " +
          fullname +
          "\nフリガナ: " +
          furigana +
          "\n性別: " +
          sex +
          "\n誕生日: " +
          birthday);

      return qrcodedata1;
    } catch (e) {
      print("エラー:" + e.toString());
      return "error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("救助要請"),
          backgroundColor: Colors.red,
        ),
        body: Form(
            key: _formKey,
            child: Center(
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
              const FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "まずは落ち着いて！",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  )),
              const FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "その場から動かないで!",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
              const FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "1.から順に、情報を入力してください。\n",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  )),

              const Text(
                "1.位置情報を取得しよう",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  _gettime();
                  _getLocation();
                },
                child: const Text('位置情報取得', style: TextStyle(fontSize: 20)),
              ),
              Text("位置情報取得時刻: " + _now, style: const TextStyle(fontSize: 15)),
              Text("位置情報: " + _location, style: const TextStyle(fontSize: 15)),
              const Text(
                "\n2.遭難者のQRコードタグを読み取ろう",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              //QRコード読み取りボタン
              ElevatedButton(
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QRPage(receive: ''), //これがreturnの値である。
                      ));
                  setState(() {
                    _qrdatajson = result;
                    //ここでは、_qrdatajsonには、ユーザ情報がjsonで入っているか、errorが入っているかの2択。
                    //ここで、jsonファイルを解消するために、
                  });
                },
                child:
                    const Text('QRコードタグ読み取り', style: TextStyle(fontSize: 20)),
              ),
              Container(
                  width: 400,
                  height: 150,
                  child: _qrdatajson != null && _qrdatajson != "error"
                      ? Center(child: Text("遭難者の情報を取得しました\n" + _getteddata()!))
                      : const Center(
                          child: Text(
                              "QRコードタグを読み取ってください。\n遭難者がQRコードタグを所持していない場合、こちらの項目は無視してください。",
                              textAlign: TextAlign.center))),
              const Text(
                "\n3.遭難者の写真を撮ろう",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () async {
                  Uint8List? uint8list = await ImagePickerWeb.getImageAsBytes();
                  Image? img = Image.memory(uint8list!);
                  File? file = File.fromRawPath(uint8list);
                  setState(() {
                    _image = img;
                    _uploaddata = uint8list; //アップロードする写真のデータが入っている
                  });
                },
                child: const Text('写真追加ボタン', style: TextStyle(fontSize: 20)),
              ),
              Container(
                  width: 250,
                  height: 150,
                  child: _image != null
                      ? _image
                      : Center(child: Text("写真を追加してください"))),
              const Text(
                "\n4.遭難者の状態を入力",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                child: const Text("例)左足をねん挫している。出血は無い。意識は明瞭だが、自力歩行不可能",
                    style: TextStyle(color: Colors.grey)),
              ),
              TextFormField(
                maxLines: null,
                minLines: 3,
                onChanged: (String value) {
                  setState(() {
                    _sufferertext = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '遭難者の状態を入力してください';
                  }
                  return null;
                },
              ),
              const Text(
                "\n5.事故発生時の状況を入力",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                child: const Text("例)転倒し30mほど転がるように滑落した",
                    style: TextStyle(color: Colors.grey)),
              ),
              TextFormField(
                maxLines: null,
                minLines: 3,
                onChanged: (String value) {
                  setState(() {
                    _accident = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '事故発生時の状況を入力してください';
                  }
                  return null;
                },
              ),

              const Text(
                "\n6.発見者のお名前を入力してください",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                maxLines: null,
                minLines: 1,
                onChanged: (String value) {
                  setState(() {
                    _discovererName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '事故発生時の状況を入力してください';
                  }
                  return null;
                },
              ),

              //情報送信ボタン(写真添付済みとかも書こうかな)
              Container(
                margin: const EdgeInsets.all(20),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(20.0)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text("入力内容を山岳救助隊に送信しますか?"),
                                actions: [
                                  TextButton(
                                    child: const Text('cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () async {
                                      setState(() {
                                        _helpday = DateTime.now();
                                        _suffererdoc = generateNonce();
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('Sufferer') // コレクションID
                                          .doc(_suffererdoc)
                                          //docIDは16桁でランダム付加。(検索時に用いられ、さらに画像の名前としても使われる)
                                          .set({
                                        'state': "needhelp",
                                        '_suffererdocID':
                                            _suffererdoc, //救助用のdocID。写真とも紐づけられる
                                        '_helpday': _helpday, //救助要請の時間
                                        '_location': _location, //位置情報
                                        'QRjson': _qrdatajson, //jsonファイルが保存される
                                        'suf': _sufferertext, //遭難者の状態が保存される
                                        'accident': _accident, //事故発生時の状況が入力される
                                        'discovererName': _discovererName,
                                      });
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NextPage(
                                            helpday2: _helpday,
                                            location2: _location,
                                            qrdatajson2: _qrdatajson,
                                            suf2: _sufferertext,
                                            accident2: _accident,
                                            qrcodedata2: qrcodedata1,
                                            uploaddata2: _uploaddata,
                                            discovererName2: _discovererName,
                                          ),
                                        ),
                                      );
                                      try {
                                        //写真をアップロードする関数
                                        await FirebaseStorage.instance
                                            .ref("picturefile/" + _suffererdoc)
                                            .putData(
                                                _uploaddata!); //遭難者の写真が、救助用のdocIDと共に紐づけられる

                                      } catch (e) {
                                        print(
                                            'error in uploading image for : ${e.toString()}');
                                      }
                                    },
                                  )
                                ],
                              );
                            });
                      }
                    },
                    child: const FittedBox(
                      child: Text("情報送信(オンライン時に利用してください)",
                          style: TextStyle(fontSize: 20)),
                    )),
              )
            ])))));
  }
}

//
//
//
//
//
//
//
//
//QRコード読み取り時のページは以下
class QRPage extends StatefulWidget {
  final receive;
  QRPage({Key? key, this.receive}) : super(key: key);

  @override
  State<QRPage> createState() => _QRPagePageState();
}

class _QRPagePageState extends State<QRPage> {
  final receive;
  var jsonText;
  _QRPagePageState({Key? key, this.receive});
  String? _scaneddata; //ここに入れた値が引き継がれる(旧)
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcoderesult;
  QRViewController? controller;
  String? qrcodedata; //ここに入れた値が引き継がれる(新)

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, _scaneddata);
          return Future.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('QRコード読み取り'),
            ),
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                    ),
                    Expanded(
                        flex: 4,
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          child: Center(
                            child: (_scaneddata != null &&
                                    _scaneddata != "error")
                                ? Text(
                                    '読み取り成功！左上の戻るボタンを押して下さい\n読み取り内容: ${_getteddata()}')
                                : Text('${_error()}'),
                          ),
                        )),
                  ]),
            )));
  }

  //エラーのテキスト文の処理
  String? _error() {
    if (_scaneddata == null) {
      return "コードをスキャンしてください。"; //まだ何も読み取ってないとき。
    } else {
      return "エラーです。もう一度読み取って下さい"; //読み取ったけど、型に合わないとき。
    }
  }

//jsonデータの処理
  String? _getteddata() {
    var jsonString = barcoderesult!.code;
    try {
      jsonText = jsonDecode(jsonString!);
      var docid = jsonText["do"];

      var fullname = jsonText["fn"];
      var furigana = jsonText["fr"];
      var sex = jsonText["se"];
      var birthday = jsonText["bs"];
      //もし非公開設定だった時
      if (jsonText["fn"] == "NULL") {
        fullname = "非公開設定";
        furigana = " 非公開設定";
        sex = "非公開設定";
        birthday = "非公開設定";
      }

      qrcodedata = ("\nユーザーID: " +
          docid +
          "\nお名前: " +
          fullname +
          "\nフリガナ: " +
          furigana +
          "\n性別: " +
          sex +
          "\n誕生日: " +
          birthday);

      return qrcodedata;
    } catch (e) {
      print("エラー:" + e.toString());
      return "error";
    }
  }

//返り値はなし。
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      try {
        jsonText = jsonDecode(scanData.code!);
        setState(() {
          barcoderesult = scanData; //もしjson形式だったら、普通に_scanneddataに結果を入れる。
          _scaneddata = barcoderesult!.code;
        });
      } catch (e) {
        print("エラー:" + e.toString());
        setState(() {
          barcoderesult = scanData; //もしjson形式じゃ無かったら、errorを入れる。
          _scaneddata = "error";
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

//
//
//
//
//
//以下は確認ページ
class NextPage extends StatelessWidget {
  final DateTime? helpday2; //救助要請の時間
  final String location2; //位置情報
  final String? qrdatajson2; //jsonファイルが保存される
  final String? suf2; //遭難者の状態が保存される
  final String? accident2; //事故発生時の状況が入力される
  final String? qrcodedata2; //jsonを読み取りやすくした形が保存される。
  final Uint8List? uploaddata2;
  final String? discovererName2;
  int count = 0;

  NextPage(
      {Key? key,
      this.helpday2,
      required this.location2,
      this.qrdatajson2,
      this.suf2,
      this.accident2,
      this.qrcodedata2,
      this.uploaddata2,
      this.discovererName2})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("救助要請の内容確認")),
        body: Center(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              const FittedBox(
                  child: Text("情報送信が完了しました。",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30))),
              Container(
                  child: helpday2 != null
                      ? Text("送信時間: " + helpday2.toString())
                      : const Text("送信時間: ")),
              const Text("\n遭難者の位置情報:\n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Container(
                child: location2 != null ? Text(location2) : const Text("\n"),
              ),
              const Text("\nQRコードタグの読み取り情報: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Container(
                child: qrcodedata2 != null
                    ? Text(qrcodedata2!)
                    : const Text("QRコードタグなし\n"),
              ),
              const Text(
                "\n遭難者の写真",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                  width: 250,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: uploaddata2 != null
                      ? Image.memory(uploaddata2!)
                      : Center(child: Text("写真はありません"))),
              const Text(
                "\n遭難者の状況:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                child: suf2 != null
                    ? SizedBox(
                        width: double.infinity,
                        child: Text(
                          suf2!,
                          textAlign: TextAlign.left,
                        ))
                    : const Text("\n"),
              ),
              const Text(
                "\n事故発生時の状況: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                child: accident2 != null
                    ? SizedBox(
                        width: double.infinity,
                        child: Text(
                          accident2!,
                          textAlign: TextAlign.left,
                        ))
                    : const Text(""),
              ),

              //追加部分、第一発見者の名前
              const Text(
                "\n発見者のお名前: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                child: discovererName2 != null
                    ? SizedBox(
                        width: double.infinity,
                        child: Text(
                          discovererName2!,
                          textAlign: TextAlign.center,
                        ))
                    : const Text(""),
              ),
              const Text("続いて、110番または119番に通報してください。",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.red)),
              ElevatedButton(
                child: const Text("トップページに戻る", style: TextStyle(fontSize: 30)),
                onPressed: () {
                  Navigator.popUntil(context, (_) => count++ >= 2);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  padding:
                      MaterialStateProperty.all(const EdgeInsets.all(12.0)),
                ),
              ),
              const Text(""),
            ]))));
  }
}
