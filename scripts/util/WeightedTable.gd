class_name WeightedTable
## Utility for weighted random selection from a table of items.

var _items: Array = []
var _weights: Array[float] = []
var _total_weight: float = 0.0

func add_item(item: Variant, weight: float) -> void:
	_items.append(item)
	_weights.append(weight)
	_total_weight += weight

func pick(random_seed: int = -1) -> Variant:
	if _items.is_empty():
		push_warning("WeightedTable: Attempted to pick from empty table.")
		return null
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	if random_seed >= 0:
		rng.seed = random_seed
	var roll: float = rng.randf() * _total_weight
	var cumulative: float = 0.0
	for i in range(_items.size()):
		cumulative += _weights[i]
		if roll <= cumulative:
			return _items[i]
	return _items[-1]

func clear() -> void:
	_items.clear()
	_weights.clear()
	_total_weight = 0.0

func size() -> int:
	return _items.size()
