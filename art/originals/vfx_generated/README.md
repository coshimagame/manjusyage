# VFX-P0-SHEET-001 / VFX-P0-TARGETING-001 — 原本記録

- 取得日: 2026-11-17
- 制作方法: GitHub のラフSVG（`docs/manjushage/visuals/vfx_*.svg`）とP0仕様を確認し、絵柄を文章にしてImageGenに入力。指示は「16bit風生体宇宙STGの3×2素材シート。紅い八角晶に白十字、青い八角晶に白稲妻、白い芯の裂けた赤い花弁、紫の尾を引く銀針、散る紅い花弁、青紫の取得光柱。各絵は独立、文字・背景なし」と「横並びの2枚。白い芯を囲む紅い花輪と、白い瞳・細い照準印を持つ暗赤色の眼。文字・背景なし」。
- 原本:
  - `vfx_p0_sheet_source_v01.png` — SHA-256 `740837204326248A7F3257A2304D64BD80D31351652980CEBB79F4646D4D83A5`
  - `vfx_p0_targeting_source_v01.png` — SHA-256 `51E2E3512471C6DABAD1E5282193E83D179509650E30AA2E6B6C977D2ADEF757`
- 加工: `tools/extract_vfx_sheet.gd` が暗いプレゼン背景を透明化し、nearest縮小したRGBA PNGを `art/active/items/` と `art/active/vfx/` に生成する。V02だけはラフどおりの白黄十字を同ツールで小さなプログラム画像として生成する。
- 採否: 0.9 Stage 1の**試作採用**。人物・機体・敵の公式外見、敵名、物語、アイテム効果を決定するものではない。原画資料は未参照のため、アートブック準拠とは称さない。
- 安全境界: I01/I02は既存のHP+1/charge+25表示のみ。B01/B02/B05/B10は既存のpetal/needle/ring/orb弾の表示のみで、弾数、追尾、速度、当たり判定は変えない。V01/V02/V15は無害な短命演出。
