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
  //非同期の関数のため、返り値の方にFutureがつき、asyncキーワードが追加された
  Future<void> fetchImages() async {
    //awaitで待つことで、Respoce型のデータを受け取っている
    Response response = await Dio().get(
        'https://pixabay.com/api/?key=43900472-a82cdd993bf6549e351194a4b&q=yellow+flowers&image_type=photo');
    print(response.data);
  }

  //初回に一度だけ実行されるinitState関数を作成
  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
