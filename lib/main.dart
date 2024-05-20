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
  Future<void> fetchImages() async {
    //awaitで待つことで、Respoce型のデータを受け取っている
    Response response = await Dio().get(
        //?以降のURLはクエリパラメーターと呼ばれ、[パラメーター=値]という形で表される
        //また、各パラメーターは&で区切って表示される
        'https://pixabay.com/api/?key=43900472-a82cdd993bf6549e351194a4b&q=いちご&image_type=photo&per_page=100');
    print(response.data);

    //定義したリストに取得したデータを代入し、setState関数で画面を更新する
    imageList = response.data['hits'];
    setState(() {});
  }

  //初回に一度だけ実行されるinitState関数を作成
  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(fillColor: Colors.white, filled: true),
          onSubmitted: (text) {
            print(text);
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
          return Image.network(image['previewURL']);
        },
      ),
    );
  }
}
