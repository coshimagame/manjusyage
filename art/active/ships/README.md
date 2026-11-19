# 3機の参照画像 v01

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
