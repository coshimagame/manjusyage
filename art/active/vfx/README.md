# Stage 1 P0 items / VFX

`vfx_p0_manifest_v01.csv` と `vfx_p0_sheet_v01.json` がID・生成元・切り出し座標を保持する。画像は `tools/extract_vfx_sheet.gd` で再生成できる。

| ID | PNG | 実ゲーム接続 | 状態 |
| --- | --- | --- | --- |
| I01 | `../items/item_hp_p0.png` | `kind == 0` の回復表示 | 試作採用・HP効果不変 |
| I02 | `../items/item_energy_p0.png` | `kind == 1` のEnergy表示 | 試作採用・charge効果不変 |
| B01 | `bullet_petal_p0.png` | `form == petal` | 試作採用・危険弾 |
| B02 | `bullet_needle_p0.png` | `form == needle` | 試作採用・危険弾 |
| B05 | `bullet_flower_ring_p0.png` | `form == ring` | 試作採用・危険弾 |
| B10 | `bullet_target_eye_p0.png` | `form == orb` | 試作採用・表示のみ（追尾追加なし） |
| V01 | `defeat_petals_p0.png` | 撃破confirm | 試作採用・無害 |
| V02 | `hit_flash_p0.png` | 命中flash | 試作採用・無害 |
| V15 | `pickup_pillar_p0.png` | 取得collect | 試作採用・無害 |

欠損時の描画フォールバックは`visual_v09.gd`の従来図形描画。GitHubラフSVGは最終ゲーム用PNGではなく、`docs/manjushage/visuals/`に原本として保持する。
