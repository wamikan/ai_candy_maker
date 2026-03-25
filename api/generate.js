export default async function handler(req, res) {
  // POSTリクエスト以外は弾くセキュリティ対策
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  // Flutterから送られてきたプロンプト（指示）を受け取る
  const { prompt } = req.body;
  
  // Vercelの環境変数からAPIキーを安全に読み込む（ブラウザには絶対にバレない）
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'APIキーがサーバーに設定されていません' });
  }

  try {
    // サーバー側からGemini APIを叩く
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=${apiKey}`;
    const geminiRes = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: 'application/json' }
      })
    });

    const data = await geminiRes.json();
    
    // Geminiから返ってきた結果を、そのままFlutter（ブラウザ）に返す
    return res.status(200).json(data);
    
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'AIからの生成に失敗しました' });
  }
}