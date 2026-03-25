import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カオス錬金術',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AlchemistScreen(),
    );
  }
}

class AlchemistScreen extends StatefulWidget {
  const AlchemistScreen({super.key});

  @override
  State<AlchemistScreen> createState() => _AlchemistScreenState();
}

class _AlchemistScreenState extends State<AlchemistScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  
  // 初期状態のデザイン
  String _shape = "未生成";
  Color _color1 = Colors.grey.shade300;
  Color _color2 = Colors.grey.shade400;

  // AIが返す「#FF5733」のような文字列をFlutterのColorに変換する関数
  Color _hexToColor(String hexString) {
    String hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // 不透明度100%を追加
    }
    return Color(int.parse(hex, radix: 16));
  }

  // Gemini APIを呼び出してデザインを生成する関数
  Future<void> _generateDesign() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 実行時に渡すAPIキーを取得
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('APIキーが設定されていません');
      }

      // Gemini APIのエンドポイント（モデルは一般的な1.5 Flashを指定しています）
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=$apiKey');

      // AIへのプロンプト（指示）
      final prompt = '''
ユーザーが入力した単語：「${_controller.text}」
この単語から連想される3Dモデルの「形」と、2色の「カラーグラデーション」を考えてください。
形は [Sphere, Cube, Diamond, Star, Cylinder] の中から1つ選んでください。
出力は必ず以下のJSONフォーマットのみにしてください。
{"shape": "Diamond", "color1": "#FF5733", "color2": "#33FF57"}
''';

      // APIへ送信するデータ
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ],
          // JSON形式での出力を強制する設定
          "generationConfig": {
            "responseMimeType": "application/json",
          }
        }),
      );

      if (response.statusCode == 200) {
        // 結果の解析（パース）
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final String aiText = responseData['candidates'][0]['content']['parts'][0]['text'];
        
        // AIが返したJSON文字列をMapに変換
        final Map<String, dynamic> designData = jsonDecode(aiText);

        // 画面の更新（setState）
        setState(() {
          _shape = designData['shape'] ?? 'Unknown';
          _color1 = _hexToColor(designData['color1'] ?? '#808080');
          _color2 = _hexToColor(designData['color2'] ?? '#808080');
        });
      } else {
        throw Exception('APIエラー: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIカオス錬金術', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 結果表示エリア ---
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  // AIの指定した色でグラデーションを描画
                  gradient: LinearGradient(
                    colors: [_color1, _color2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _color1.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8), // 少し下に影を落として立体感を出す
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    _shape,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(2, 2))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // --- 入力画面エリア ---
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: '錬金したい単語を入力',
                  hintText: '例：徹夜明けのバグ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateDesign,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          '生成する',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}