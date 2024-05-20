import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List imageList = [];
  //非同期の関数のため、返り値の方にFutureがつき、asyncキーワードが追加された
  Future<void> fetchImages(String text) async {
    //awaitで待つことで、Respoce型のデータを受け取っている
    Response response = await Dio().get(
        //?以降のURLはクエリパラメーターと呼ばれ、[パラメーター=値]という形で表される
        //また、各パラメーターは&で区切って表示される
        //qの値にtext変数の値が入るように変更
        'https://pixabay.com/api/?key=43900472-a82cdd993bf6549e351194a4b&q=$text&image_type=photo&per_page=100');
    print(response.data);

    //定義したリストに取得したデータを代入し、setState関数で画面を更新する
    imageList = response.data['hits'];
    setState(() {});
  }

  //初回に一度だけ実行されるinitState関数を作成
  @override
  void initState() {
    super.initState();
    //fetchImages関数に引数を追加したため、初期の値を入力
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //文字列入力用にTextFieldウィジェットを追加
        title: TextField(
          decoration: InputDecoration(fillColor: Colors.white, filled: true),
          //TextFieldの確定ボタンが押下された際の処理
          onSubmitted: (text) {
            print(text);
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //画像を横に並べる際の個数を3個に指定
            crossAxisCount: 3),
        //Listの要素数をitemCountプロパティlengthで取得する(今回は20)
        itemCount: imageList.length,
        //indexにはListの要素が0から順番に入る
        itemBuilder: (context, index) {
          //image変数にindex番号に紐づいたListの各要素が順番に代入される
          Map<String, dynamic> image = imageList[index];
          //プレビュー用の画像データがあるURLはpreviewURLのvalueに入っている
          return Stack(
            children: [
              Image.network(image['previewURL']),
              //API内のlikes keyの値がいいね数に該当するため、image@['likes']で取得
              //さらに、toString()で文字列型に変換
              Container(
                  color: Colors.white, child: Text(image['likes'].toString())),
            ],
          );
        },
      ),
    );
  }
}
