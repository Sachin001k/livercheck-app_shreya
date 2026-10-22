/// Foods for the daily log's meal picker, with typical home portions and
/// approximate calories (ICMR-NIN / IFCT 2017 averages for common Indian
/// recipes). DRAFT values — portions and oil vary a lot between homes.
library;

import '../translations.dart';

enum MealCategory { breakfast, mains, snacks, drinksSweets }

/// Emoji and translation key for each group's heading.
const mealCategoryLabels = {
  MealCategory.breakfast: (emoji: '🌅', key: 'ml_catBreakfast'),
  MealCategory.mains: (emoji: '🍛', key: 'ml_catMains'),
  MealCategory.snacks: (emoji: '🥨', key: 'ml_catSnacks'),
  MealCategory.drinksSweets: (emoji: '🥤', key: 'ml_catDrinksSweets'),
};

/// Heading for [category] in [lang], e.g. "🌅 Breakfast".
String mealCategoryLabel(MealCategory category, AppLanguage lang) {
  final l = mealCategoryLabels[category]!;
  return '${l.emoji} ${tr(lang, l.key)}';
}

class MealFood {
  final String id;
  final String emoji;
  /// Translation keys for the food's name and portion size. The [id] is
  /// what gets saved, so names can change without breaking old logs.
  final String nameKey;
  final String portionKey;
  final int kcal;
  final MealCategory category;

  /// Counts as one serving of fruit or vegetables.
  final bool fruitVeg;

  /// Counts as one sweet / sugary item.
  final bool sweet;

  const MealFood(
    this.id,
    this.emoji,
    this.nameKey,
    this.portionKey,
    this.kcal,
    this.category, {
    this.fruitVeg = false,
    this.sweet = false,
  });

  String name(AppLanguage lang) => tr(lang, nameKey);
  String portion(AppLanguage lang) => tr(lang, portionKey);

  /// True if [query] (lower case) is in the name in [lang] or in English.
  bool matches(String query, AppLanguage lang) =>
      query.isEmpty ||
      name(lang).toLowerCase().contains(query) ||
      name(AppLanguage.en).toLowerCase().contains(query);
}

const List<MealFood> mealFoods = [
  // Breakfast
  MealFood('poha', '🍚', 'ml_poha', 'ml_pPlate', 250, MealCategory.breakfast),
  MealFood('upma', '🥣', 'ml_upma', 'ml_pPlate', 250, MealCategory.breakfast),
  MealFood('idli', '⚪', 'ml_idli', 'ml_pPiece', 60, MealCategory.breakfast),
  MealFood('dosa', '🫓', 'ml_dosa', 'ml_pDosa', 170, MealCategory.breakfast),
  MealFood(
    'paratha',
    '🫓',
    'ml_paratha',
    'ml_pPiece',
    200,
    MealCategory.breakfast,
  ),
  MealFood(
    'aloo_paratha',
    '🥔',
    'ml_alooParatha',
    'ml_pPiece',
    300,
    MealCategory.breakfast,
  ),
  MealFood('bread', '🍞', 'ml_bread', 'ml_pSlice', 70, MealCategory.breakfast),
  MealFood(
    'oats',
    '🥣',
    'ml_oats',
    'ml_pBowl',
    150,
    MealCategory.breakfast,
  ),
  MealFood('egg', '🥚', 'ml_egg', 'ml_pEgg', 75, MealCategory.breakfast),
  MealFood('omelette', '🍳', 'ml_omelette', 'ml_pTwoEggs', 190, MealCategory.breakfast),

  // Lunch & dinner
  MealFood('roti', '🫓', 'ml_roti', 'ml_pRoti', 100, MealCategory.mains),
  MealFood('rice', '🍚', 'ml_rice', 'ml_pKatori', 200, MealCategory.mains),
  MealFood('dal', '🥣', 'ml_dal', 'ml_pKatori', 150, MealCategory.mains),
  MealFood('rajma', '🫘', 'ml_rajma', 'ml_pKatori', 200, MealCategory.mains),
  MealFood(
    'sabzi',
    '🥬',
    'ml_sabzi',
    'ml_pKatori',
    120,
    MealCategory.mains,
    fruitVeg: true,
  ),
  MealFood('paneer', '🧀', 'ml_paneer', 'ml_pKatori', 280, MealCategory.mains),
  MealFood(
    'chicken',
    '🍗',
    'ml_chicken',
    'ml_pKatori',
    250,
    MealCategory.mains,
  ),
  MealFood('fish', '🐟', 'ml_fish', 'ml_pKatori', 200, MealCategory.mains),
  MealFood('curd', '🥛', 'ml_curd', 'ml_pKatori', 100, MealCategory.mains),
  MealFood(
    'salad',
    '🥗',
    'ml_salad',
    'ml_pBowl',
    40,
    MealCategory.mains,
    fruitVeg: true,
  ),
  MealFood('khichdi', '🍲', 'ml_khichdi', 'ml_pBowl', 250, MealCategory.mains),
  MealFood('biryani', '🍛', 'ml_biryani', 'ml_pPlate', 500, MealCategory.mains),
  MealFood(
    'thali',
    '🍱',
    'ml_thali',
    'ml_pThali',
    700,
    MealCategory.mains,
    fruitVeg: true,
  ),

  // Snacks & fruit
  MealFood(
    'fruit',
    '🍎',
    'ml_fruit',
    'ml_pMedium',
    70,
    MealCategory.snacks,
    fruitVeg: true,
  ),
  MealFood('nuts', '🥜', 'ml_nuts', 'ml_pHandful', 180, MealCategory.snacks),
  MealFood(
    'sprouts',
    '🌱',
    'ml_sprouts',
    'ml_pBowl',
    150,
    MealCategory.snacks,
    fruitVeg: true,
  ),
  MealFood(
    'makhana',
    '🍿',
    'ml_makhana',
    'ml_pBowl',
    100,
    MealCategory.snacks,
  ),
  MealFood('samosa', '🥟', 'ml_samosa', 'ml_pPiece', 250, MealCategory.snacks),
  MealFood('pakora', '🍤', 'ml_pakora', 'ml_pFourPieces', 200, MealCategory.snacks),
  MealFood(
    'biscuits',
    '🍪',
    'ml_biscuits',
    'ml_pFourBiscuits',
    120,
    MealCategory.snacks,
  ),
  MealFood(
    'namkeen',
    '🥨',
    'ml_namkeen',
    'ml_pHandful',
    160,
    MealCategory.snacks,
  ),

  // Drinks & sweets
  MealFood(
    'chai',
    '🍵',
    'ml_chai',
    'ml_pCup',
    80,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'coffee_milk',
    '☕',
    'ml_coffeeMilk',
    'ml_pCup',
    90,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'black_tea',
    '🫖',
    'ml_blackTea',
    'ml_pCup',
    5,
    MealCategory.drinksSweets,
  ),
  MealFood(
    'cold_drink',
    '🥤',
    'ml_coldDrink',
    'ml_pGlass',
    130,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'juice',
    '🧃',
    'ml_juice',
    'ml_pGlass',
    100,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'lassi',
    '🥛',
    'ml_lassi',
    'ml_pGlass',
    220,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'mithai',
    '🍬',
    'ml_mithai',
    'ml_pPiece',
    150,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'ice_cream',
    '🍨',
    'ml_iceCream',
    'ml_pScoop',
    140,
    MealCategory.drinksSweets,
    sweet: true,
  ),
  MealFood(
    'chocolate',
    '🍫',
    'ml_chocolate',
    'ml_pSmallBar',
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
