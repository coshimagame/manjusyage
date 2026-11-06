extends RefCounted
# Stage interlude content is intentionally minimal until final dialogue is approved.
# The stage runner supports all eight boundaries without inventing canon dialogue.
const ENTRIES = {
	1: {"title":"第1面のあと", "speaker":"記録", "lines":["赤い残響を越えた。","ムゥの整備室で、次の出撃に備える。"]},
	2: {"title":"第2面のあと", "speaker":"記録", "lines":["次の世界線へ向かう準備が始まる。"]},
	3: {"title":"第3面のあと", "speaker":"記録", "lines":["世界線の違いが、少しずつ姿を現す。"]},
	4: {"title":"第4面のあと", "speaker":"記録", "lines":["仲間たちの選択が、次の道を開く。"]},
	5: {"title":"第5面のあと", "speaker":"記録", "lines":["過去の記憶が、別の世界線と交差する。"]},
	6: {"title":"第6面のあと", "speaker":"記録", "lines":["クゥをめぐる真実に近づいていく。"]},
	7: {"title":"第7面のあと", "speaker":"記録", "lines":["エリィとマリィの戦いを越え、最後の決断へ。"]},
	8: {"title":"最終面のあと", "speaker":"記録", "lines":["この世界線の旅は、ひとつの終わりを迎えた。"]}
}
static func page(stage: int) -> Dictionary:
	return ENTRIES.get(clampi(stage,1,8),{})
