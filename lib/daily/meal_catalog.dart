/// Foods for the daily log's meal picker, with typical home portions and
/// approximate calories (ICMR-NIN / IFCT 2017 averages for common Indian
/// recipes). DRAFT values — portions and oil vary a lot between homes.
library;

enum MealCategory { breakfast, mains, snacks, drinksSweets }

const mealCategoryLabels = {
  MealCategory.breakfast: '🌅 Breakfast',
  MealCategory.mains: '🍛 Lunch & dinner',
  MealCategory.snacks: '🥨 Snacks & fruit',
  MealCategory.drinksSweets: '🥤 Drinks & sweets',
};

class MealFood {
  final String id;
  final String emoji;
  final String name;
  final String portion;
  final int kcal;
  final MealCategory category;

  /// Counts as one serving of fruit or vegetables.
  final bool fruitVeg;

  /// Counts as one sweet / sugary item.
  final bool sweet;

  const MealFood(
    this.id,
    this.emoji,
    this.name,
    this.portion,
    this.kcal,
    this.category, {
    this.fruitVeg = false,
    this.sweet = false,
  });
}

const List<MealFood> mealFoods = [
  // Breakfast
  MealFood('poha', '🍚', 'Poha', '1 plate', 250, MealCategory.breakfast),
  MealFood('upma', '🥣', 'Upma', '1 plate', 250, MealCategory.breakfast),
  MealFood('idli', '⚪', 'Idli', '1 piece', 60, MealCategory.breakfast),
  MealFood('dosa', '🫓', 'Plain dosa', '1 dosa', 170, MealCategory.breakfast),
  MealFood(
    'paratha',
    '🫓',
    'Plain paratha',
    '1 piece',
    200,
    MealCategory.breakfast,
  ),
  MealFood(
    'aloo_paratha',
    '🥔',
    'Aloo paratha',
    '1 piece',
    300,
    MealCategory.breakfast,
  ),
  MealFood('bread', '🍞', 'Bread', '1 slice', 70, MealCategory.breakfast),
  MealFood(
    'oats',
    '🥣',
    'Oats porridge',
    '1 bowl',
    150,
    MealCategory.breakfast,
  ),
  MealFood('egg', '🥚', 'Boiled egg', '1 egg', 75, MealCategory.breakfast),
  MealFood('omelette', '🍳', 'Omelette', '2 eggs', 190, MealCategory.breakfast),

  // Lunch & dinner
  MealFood('roti', '🫓', 'Roti / chapati', '1 roti', 100, MealCategory.mains),
  MealFood('rice', '🍚', 'Rice', '1 katori', 200, MealCategory.mains),
  MealFood('dal', '🥣', 'Dal', '1 katori', 150, MealCategory.mains),
  MealFood('rajma', '🫘', 'Rajma / chole', '1 katori', 200, MealCategory.mains),
  MealFood(
    'sabzi',
    '🥬',
    'Vegetable sabzi',
    '1 katori',
    120,
    MealCategory.mains,
    fruitVeg: true,
  ),
  MealFood('paneer', '🧀', 'Paneer sabzi', '1 katori', 280, MealCategory.mains),
  MealFood(
    'chicken',
    '🍗',
    'Chicken curry',
    '1 katori',
    250,
    MealCategory.mains,
  ),
  MealFood('fish', '🐟', 'Fish curry', '1 katori', 200, MealCategory.mains),
  MealFood('curd', '🥛', 'Curd / raita', '1 katori', 100, MealCategory.mains),
  MealFood(
    'salad',
    '🥗',
    'Salad',
    '1 bowl',
    40,
    MealCategory.mains,
    fruitVeg: true,
  ),
  MealFood('khichdi', '🍲', 'Khichdi', '1 bowl', 250, MealCategory.mains),
  MealFood('biryani', '🍛', 'Biryani', '1 plate', 500, MealCategory.mains),
  MealFood(
    'thali',
    '🍱',
    'Full home thali',
    '1 thali',
    700,
    MealCategory.mains,
    fruitVeg: true,
  ),

  // Snacks & fruit
  MealFood(
    'fruit',
    '🍎',
    'Fruit',
    '1 medium',
    70,
    MealCategory.snacks,
    fruitVeg: true,
  ),
  MealFood('nuts', '🥜', 'Nuts', '1 handful', 180, MealCategory.snacks),
  MealFood(
    'sprouts',
    '🌱',
    'Sprouts chaat',
    '1 bowl',
    150,
    MealCategory.snacks,
    fruitVeg: true,
  ),
  MealFood(
    'makhana',
    '🍿',
    'Roasted makhana',
    '1 bowl',
    100,
    MealCategory.snacks,
  ),
  MealFood('samosa', '🥟', 'Samosa', '1 piece', 250, MealCategory.snacks),
  MealFood('pakora', '🍤', 'Pakora', '4 pieces', 200, MealCategory.snacks),
  MealFood(
    'biscuits',
    '🍪',
    'Biscuits',
    '4 biscuits',
    120,
    MealCategory.snacks,
  ),
  MealFood(
    'namkeen',
    '🥨',
    'Namkeen / chips',
    '1 handful',
    160,
    MealCategory.snacks,
  ),

  // Drinks & sweets
  MealFood(
    'chai',
    '🍵',
    'Chai with sugar',
    '1 cup',
    80,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'coffee_milk',
    '☕',
    'Coffee with sugar',
    '1 cup',
    90,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'black_tea',
    '🫖',
    'Black tea / coffee, no sugar',
    '1 cup',
    5,
    MealCategory.drinksSweets,
  ),
  MealFood(
    'cold_drink',
    '🥤',
    'Cold drink',
    '1 glass',
    130,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'juice',
    '🧃',
    'Packaged juice',
    '1 glass',
    100,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'lassi',
    '🥛',
    'Sweet lassi',
    '1 glass',
    220,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'mithai',
    '🍬',
    'Mithai',
    '1 piece',
    150,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'ice_cream',
    '🍨',
    'Ice cream',
    '1 scoop',
    140,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'chocolate',
    '🍫',
    'Chocolate',
    '1 small bar',
    200,
    MealCategory.drinksSweets,
    sweet: true,
  ),
];

final Map<String, MealFood> mealFoodsById = {
  for (final f in mealFoods) f.id: f,
};

/// Totals for a set of picked foods ({food id: number of portions}).
({int kcal, int fruitVeg, int sweets, int items}) mealTotals(
  Map<String, int> picked,
) {
  var kcal = 0, fruitVeg = 0, sweets = 0, items = 0;
  picked.forEach((id, count) {
    final food = mealFoodsById[id];
    if (food == null || count <= 0) return;
    kcal += food.kcal * count;
    items += count;
    if (food.fruitVeg) fruitVeg += count;
    if (food.sweet) sweets += count;
  });
  return (kcal: kcal, fruitVeg: fruitVeg, sweets: sweets, items: items);
}
