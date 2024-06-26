import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  List<PixabayImage> pixabayImages = [];
  //非同期の関数のため、返り値の方にFutureがつき、asyncキーワードが追加された
  Future<void> fetchImages(String text) async {
    //awaitで待つことで、Respoce型のデータを受け取っている
    //final修飾子にすることで、変数の値が更新されなくなる
    //また、データ型の名前を記載しなくてよくなる
    final response = await Dio().get(
      //?以降のURLはクエリパラメーターと呼ばれ、[パラメーター=値]という形で表される
      //また、各パラメーターは&で区切って表示される
      //qの値にtext変数の値が入るように変更
      'https://pixabay.com/api/',
      //queryParametersによって、URLにおける?以降の部分をMap形式で与える
      queryParameters: {
        'key': '43900472-a82cdd993bf6549e351194a4b',
        'q': text,
        'image_type': 'photo',
        'per_page': 100,
      },
    );
    print(response.data);

    //取得したresponseのデータを変数hitsに代入
    //この時、要素のデータ型はMap<String, dynamic>
    final List hits = response.data['hits'];
    //変数pixabayImagesに変数hitsの要素を新しいリストとして作成する
    //map関数によってPixabayImagesを利用し、各要素を作成している
    //その際、toList関数によって結果をリストとして取得している
    pixabayImages = hits.map((e) => PixabayImage.fromMap(e)).toList();

    setState(() {});
  }

  Future<void> shareImage(String url) async {
    //一時保存用のフォルダ情報を変数dirに代入する
    //この際、Future型になるため、aysnc awaitを使用する
    final dir = await getTemporaryDirectory();

    //Dio().get()でhttp通信におけるGETメソッドを使用し、Response型のresponse変数に結果を代入
    final response = await Dio().get(
      //引数のurlをgetメソッドに代入
      url,
      //optionsプロパティでデータ型を指定
      options: Options(
        //画像をダウンロードする際は、ResponseType.bytesを指定する
        responseType: ResponseType.bytes,
      ),
    );

    //一時保存用のフォルダにimage.pngファイルを作成し、それを変数imageFileの中に代入
    final imageFile =
        await File('${dir.path}/image.png').writeAsBytes(response.data);

    await Share.shareXFiles([XFile(imageFile.path)]);
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
        itemCount: pixabayImages.length,
        //indexにはListの要素が0から順番に入る
        itemBuilder: (context, index) {
          //pixabayImage変数にindex番号に紐づいたListの各要素が順番に代入される
          final pixabayImage = pixabayImages[index];
          //プレビュー用の画像データがあるURLはpreviewURLのvalueに入っている
          return InkWell(
            onTap: () async {
              //高画質の画像をダウンロードするため、webfromatURLを使用
              //keyを指定して要素を取り出すのではなく、インスタンスの引数として取り出している
              shareImage(pixabayImage.webformatURL);
              print(pixabayImage.likes);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  pixabayImage.previewURL,
                  //fitパラメーターで画像ごとの領域いっぱいに画像を表示するようにした
                  fit: BoxFit.cover,
                ),
                //API内のlikes keyの値がいいね数に該当するため、image@['likes']で取得
                //さらに、toString()で文字列型に変換
                Align(
                  //いいね数を右下に表示するためにalignmentプロパティを追加
                  alignment: Alignment.bottomRight,
                  child: Container(
                      color: Colors.white,
                      child: Row(
                        //いいね数を必要最小限のサイズに
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //いいねアイコン用にサムズアップアイコンを追加
                          const Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 14,
                          ),
                          Text('${pixabayImage.likes}'),
                        ],
                      )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
//取得したデータをまとめる変数imageListの機能をクラスとしてまとめる
class PixabayImage {
  final String previewURL;
  final int likes;
  final String webformatURL;

  PixabayImage(
      {
      //引数を名前付きで渡せるようにrequiredキーワードをつける
      //これにより、関数を呼び出す際に下記の引数を省略せずに必ず指定しなければいけなくなった為、APIのkeyの打ち間違えなどが防げるようになった
      //また、thisによって現在のインスタンスの引数を簡単に指定している
      required this.previewURL,
      required this.likes,
      required this.webformatURL});
  //
  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
      previewURL: map['previewURL'],
      likes: map['likes'],
      webformatURL: map['webformatURL'],
    );
  }
}
