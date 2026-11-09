extends RefCounted
## 敵100種の実装向け仮カタログ。正式設定・既存アートを上書きしない。
## 通常敵76 + 小/中/大ボス各8 = 100。スクロール方向ごとの軌道を保持。
const STAGE_NAMES = ["赤い残響", "追憶の海", "孤独な庭", "分岐する空", "忘却の要塞", "白い彼岸", "輪廻の終点", "曼珠沙華"]
const MOTIONS = ["straight", "sine", "zigzag", "arc", "dive", "orbit", "stop_go", "weave"]
const ATTACKS = ["single", "aimed", "spread3", "fan5", "burst", "laser_warn", "mine", "spiral"]
const THEMES = ["免疫", "記憶", "花園", "境界", "要塞", "彼岸", "輪廻", "中枢"]

static func all_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for stage in range(1, 9):
		var count := 10 if stage <= 4 else 9
		for slot in range(1, count + 1):
			ids.append("E%02d-%02d" % [stage, slot])
		for rank in ["S", "M", "L"]:
			ids.append("B%02d-%s" % [stage, rank])
	return ids

static func get_enemy(enemy_id: String) -> Dictionary:
	var parts := enemy_id.split("-")
	if parts.size() != 2 or parts[0].length() != 3:
		return {}
	var stage := int(parts[0].substr(1))
	if stage < 1 or stage > 8:
		return {}
	var boss := parts[0].begins_with("B")
	var slot := 0
	var rank := ""
	if boss:
		rank = parts[1]
		if not ["S", "M", "L"].has(rank): return {}
	else:
		if not parts[0].begins_with("E") or not parts[1].is_valid_int(): return {}
		slot = int(parts[1])
		if slot < 1 or slot > (10 if stage <= 4 else 9): return {}
	var variant := (stage * 11 + slot * 3 + ["S", "M", "L"].find(rank)) if boss else (stage * 11 + slot * 3)
	var motion_h := MOTIONS[variant % MOTIONS.size()]
	var motion_v := MOTIONS[(variant + 3) % MOTIONS.size()]
	var attack := ATTACKS[(variant + (2 if boss else 0)) % ATTACKS.size()]
	var hp := (30 if rank == "S" else (100 if rank == "M" else 350)) if boss else (2 + slot / 3)
	return {
		"id": enemy_id, "stage": stage, "stage_name": STAGE_NAMES[stage - 1],
		"name_proposal": "%s%s%02d" % [THEMES[stage - 1], ("小ボス" if rank == "S" else ("中ボス" if rank == "M" else "大ボス")) if boss else "兵", slot],
		"kind": "boss" if boss else "normal", "rank": rank,
		"hp_proposal": hp, "attack": attack, "motion_horizontal": motion_h, "motion_vertical": motion_v,
		"speed_proposal": 44.0 + float(slot) * 7.0 if not boss else 30.0,
		"sprite_horizontal": "res://art/enemies/%s_h.png" % enemy_id.to_lower(),
		"sprite_vertical": "res://art/enemies/%s_v.png" % enemy_id.to_lower(),
		"sound_event": "enemy/%s" % enemy_id.to_lower(),
		"status": "proposal", "asset_status": "missing"
	}

## 進行軸に沿った敵のローカル変位（秒）。spawn位置に加算して使う。
## 640x360を想定するが、座標値はステージ側で調整可能。
static func offset_at(enemy_id: String, seconds: float, vertical_scroll: bool) -> Vector2:
	var spec := get_enemy(enemy_id)
	if spec.is_empty(): return Vector2.ZERO
	var t := maxf(0.0, seconds)
	var speed := float(spec["speed_proposal"])
	var motion: String = spec["motion_vertical"] if vertical_scroll else spec["motion_horizontal"]
	var forward := speed * t
	var lateral := 0.0
	match motion:
		"sine": lateral = sin(t * 3.0) * 24.0
		"zigzag": lateral = (absf(fposmod(t * 1.8, 2.0) - 1.0) * 2.0 - 1.0) * 28.0
		"arc": lateral = sin(minf(t / 3.0, 1.0) * PI) * 42.0
		"dive": lateral = minf(t * t * 12.0, 65.0)
		"orbit": lateral = sin(t * 4.0) * 32.0
		"stop_go": forward = speed * (floorf(t / 1.4) * 0.9 + minf(fposmod(t, 1.4), 0.45))
		"weave": lateral = sin(t * 2.5) * 18.0 + sin(t * 5.5) * 9.0
	if vertical_scroll: return Vector2(lateral, forward)
	return Vector2(-forward, lateral)

static func validate_catalog() -> bool:
	var ids := all_ids()
	if ids.size() != 100: return false
	var unique := {}
	for enemy_id in ids:
		if unique.has(enemy_id) or get_enemy(enemy_id).is_empty(): return false
		unique[enemy_id] = true
	return true

