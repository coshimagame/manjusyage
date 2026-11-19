# 3機の参照画像 v01

## 2026-11-20 横スクロール・縦スクロール差分

各世界のムゥの設計に共通する細い機首、埋め込み式操縦席、対の翼を残した。内蔵ImageGenで参照絵を入力し、横は右向きの直交側面、縦は左右対称の真上からの輪郭を指定。格子状の輪郭と少数色を使い、ゲーム内56px幅でシルエットが読めるよう制作した。下のPNGは透過原本をそのまま複製。Gameの描画時に透明余白を除き、縦素材は機首を上に向ける。

| 操縦士・視点 | 試遊素材 | 参照と制作指示 | 原本SHA-256 |
| --- | --- | --- | --- |
| コルミィ・横 | `cormii_muu_v02_h.png` | 同機の上面図から赤い反り翼・象牙色の機首・橙の放熱口を側面へ | `17537c2aebbd74b4d936d989480af2ebda0c2bd6a0e5122914518284f60c0f88` |
| コルミィ・縦 | `cormii_muu_v02_v.png` | 青い共通機の骨格に彼岸花のような二股の翼と橙の放熱口 | `f1c023608200268c48b5888e4aea81805b140d3969fb53671389d4262a112c7d` |
| ジヨーザ・横 | `jiyoza_muu_v02_h.png` | `jiyoza_reference_v01.png`から長い青銀の二股機首、背びれと水色の走査窓を側面へ | `666c95e12f80615d845bcefd855a20704178bddfe12730bd92f6d5e9d27fb3e5` |
| ジヨーザ・縦 | `jiyoza_muu_v02_v.png` | 同じ参照から真上に開く銀青の翼と対の走査窓、細長い中央機首 | `da06763fc70b7e1e913563245c84278138e014e8219d54a5ede5d8b8060f1d28` |
| マフィオ・横 | `mafio_gold_black_v03_h.png` | 先に採用した金×黒 v02から黒い厚い胴体、金の外装、紫の窓、上下の捕食口を側面へ | `c2251c93fc2a18495b410a45eb921d530da7846993efa5ac5f7cbcdb66dc0876` |
| マフィオ・縦 | `mafio_gold_black_v02.png` | 先に採用した金×黒案を使用 | `eda413e8e4aeee43554a09ad7bbd505784282384c6130dd0ed99f530e8e92702` |

いずれも0.9試遊採用。今回提示した別のマフィオ上面案は見送り。旧v01・v02の原本も保持する。

以前のCodex作業の `manjushage-transparent/ships/` から、透明PNGを無加工で取り込んだ。参照元は `art/ui/character_hub_ui_20261106.png` と `art/ui/character_system_ui_20261106.png`。後者のSHA-256は今回添付された「曼珠沙華 キャラクター別UI図鑑.png」と一致する。

- コルミィ `cormii_reference_v01.png` / SHA-256 `a99a08016a027a25125247feefd9b17c6b70af5e974b980a157d33583bfe5971`
- ジヨーザ `jiyoza_reference_v01.png` / SHA-256 `2ac657f9ef4c79d7eb4618f4f3d160929ec50bea5f79f3ed00a946a70f85937f`
- マフィオ `mafio_reference_v01.png` / SHA-256 `a2752f303e19f55aecc7243fde22f749f846e5938c4a2f23b5a44aad656a070e`

元のmanifestは3枚とも「参照画像に基づく生成素材」と記録。今回の追加生成なし。Godotで透過余白の内側だけを切り出して表示する。3機は第1ステージ、タイトル、ステータスで試作採用。コルミィ機は第2ステージのボス試作にも使用。

## 2026-11-20 マフィオ 金×黒 v02

- 参照は「曼珠沙華 オフィシャルアートブック展開.png」内の「03 MACHINES」のマフィオ機（資料ID LIB-ART-003、SHA-256 `cba95752c33fa1501708feadbdc4bb1d75a75e667ef9bfdee60101275ee1d88c`）。参照PNGは既存のダウンロード原本を保持。
- `mafio_gold_black_v02.png` は内蔵ImageGenの生成原本（1774×887、RGBA、SHA-256 `eda413e8e4aeee43554a09ad7bbd505784282384c6130dd0ed99f530e8e92702`）。画像の透明度を保存し、`art_catalog.gd`で余白を除いて描画。第1ステージの横・縦、タイトル、ステータスに試作採用。
- 生成指示

> Use case: stylized-concept. Asset type: one MANJUSHAGE in-game sprite. Image 1 is the user's concept art board. Use ONLY the gold-and-black Mafio craft from its '03 MACHINES' gold column and the smaller matching gold fighter in the upper character sheet as design references. Translate that black-bodied machine to an orthographic dorsal/top view, nose exactly right, on true transparent alpha. Preserve the long angular spear nose, segmented black fuselage, swept split amber-gold blades, paired deep notches that separate main and secondary fins, and gold armor concentrated at the outer edges. Matte dark charcoal and near black make up roughly sixty percent of the hull; the pale highlights should be tiny gold edge glints, never broad white or silver panels. Compact burnt amber intake slits, a small dark-purple inset, no colored rim light outside the silhouette. Game-ready deliberate 16-bit pixel clusters, hard silhouette, simple contiguous color shapes readable at 56 by 29 px, face strictly RIGHT. Single complete isolated spacecraft, centered, generous alpha margins, no text, no labels, no star field, no shadow, no panel, no people, no projectiles, no engines firing.
