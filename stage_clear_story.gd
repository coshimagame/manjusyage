extends RefCounted
# Provisional stage-one interlude. Dialogue is NOT adopted canon.
# Kept independent from the result screen and the approved character art.
const LINES: Array = [
	["クゥ", "みんな、無事ね。よかった……。"],
	["コルミィ", "あの赤い星、最後に花が咲いたよ！"],
	["ジヨーザ", "敵は、あの場所を守ろうとしていたのかもしれない。"],
	["マフィオ", "ねえ、あの光の形、まだ覚えてるよ。"],
	["クゥ", "そうね。忘れないで。あの子たちにも、帰る場所があったこと。"],
	["ムゥの記録", "急ぐときほど、帰る道を残せ。"],
	["コルミィ", "……ムゥ？　今の、誰の声？"],
	["クゥ", "次の境界へ向かいましょう。答えは、まだそこにあるわ。"]
]

static func line_at(index: int) -> Array:
	return LINES[clampi(index, 0, LINES.size() - 1)]

static func is_last(index: int) -> bool:
	return index >= LINES.size() - 1
