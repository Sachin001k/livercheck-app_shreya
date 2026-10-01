/// Home page content: food recommendations, health suggestions and FAQs.
///
/// DUMMY DATA — placeholder text to shape the UI. Replace it with content
/// reviewed by a doctor or dietitian before release. Later this can move
/// into a Supabase table so it can be updated without a new app release
/// (see README → Roadmap).
library;

class FoodTip {
  final String emoji;
  final String name;
  final String why;

  /// True for "eat more", false for "limit".
  final bool recommended;

  /// Full information shown when the card is tapped. Null until written.
  final FoodDetail? detail;

  const FoodTip({
    required this.emoji,
    required this.name,
    required this.why,
    required this.recommended,
    this.detail,
  });
}

/// Everything shown in a food's pop-up.
class FoodDetail {
  /// The portion the calories and nutrients refer to, e.g. "1 katori (100 g)".
  final String serving;
  final int kcal;
  final List<Nutrient> nutrients;

  /// Safe daily amount for children, adults and elders.
  final List<IntakeGuide> intake;

  /// Positives: which diseases or organs it helps. Hidden when empty.
  final List<HealthPoint> benefits;

  /// Negatives: which organs too much of it can affect.
  final List<HealthPoint> overconsumption;

  /// Healthier alternatives, mainly for "limit" foods. Hidden when empty.
  final List<HealthPoint> swaps;

  final List<String> precautions;

  const FoodDetail({
    required this.serving,
    required this.kcal,
    required this.nutrients,
    required this.intake,
    this.benefits = const [],
    required this.overconsumption,
    this.swaps = const [],
    required this.precautions,
  });
}

class Nutrient {
  final String name;
  final String amount;

  const Nutrient(this.name, this.amount);
}

enum AgeGroup { children, adults, elders }

class IntakeGuide {
  final AgeGroup group;

  /// Who this row covers, e.g. "1–9 years".
  final String ages;
  final String amount;
  final String? note;

  const IntakeGuide({
    required this.group,
    required this.ages,
    required this.amount,
    this.note,
  });
}

/// One benefit or risk: an emoji, what it affects, and why.
class HealthPoint {
  final String emoji;
  final String title;
  final String body;

  const HealthPoint(this.emoji, this.title, this.body);
}

class HealthTip {
  final String emoji;
  final String title;
  final String body;

  const HealthTip({
    required this.emoji,
    required this.title,
    required this.body,
  });
}

class Faq {
  final String question;
  final String answer;

  const Faq({required this.question, required this.answer});
}

const List<FoodTip> foodTips = [
  FoodTip(
    emoji: '🥬',
    name: 'Leafy greens',
    why: 'Palak, methi and other greens are rich in fibre and antioxidants.',
    recommended: true,
    detail: FoodDetail(
      serving: '1 katori cooked palak (≈100 g)',
      kcal: 23,
      nutrients: [
        // Boiled spinach, per 100 g (USDA FoodData Central).
        Nutrient('Protein', '3 g'),
        Nutrient('Fibre', '2.4 g'),
        Nutrient('Iron', '3.6 mg'),
        Nutrient('Folate', '146 µg'),
        Nutrient('Vitamin K', '494 µg'),
        Nutrient('Vitamin C', '10 mg'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: '½–1 katori (50–75 g) a day',
          note: 'Serve well cooked and mashed. Not for babies under 6 months.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: '1 katori (≈100 g) a day',
          note: 'Part of the 300–400 g of vegetables advised daily.',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: '1 katori (≈100 g) a day',
          note: 'Cook soft for easier chewing and digestion.',
        ),
      ],
      benefits: [
        HealthPoint(
          '🍃',
          'Liver',
          'Fibre and antioxidants help reduce fat build-up in the liver.',
        ),
        HealthPoint(
          '❤️',
          'Heart disease',
          'Natural nitrates and folate help keep blood pressure in check.',
        ),
        HealthPoint(
          '🩸',
          'Anaemia',
          'Iron and folate support healthy red blood cells.',
        ),
        HealthPoint(
          '🦴',
          'Weak bones',
          'Vitamin K helps the body use calcium to keep bones strong.',
        ),
        HealthPoint(
          '👁️',
          'Eye problems',
          'Lutein and zeaxanthin protect against cataract and age-related vision loss.',
        ),
        HealthPoint(
          '🍬',
          'Type 2 diabetes',
          'Very low in calories and slow to digest, so blood sugar stays steady.',
        ),
      ],
      overconsumption: [
        HealthPoint(
          '🫘',
          'Kidneys',
          'Palak is high in oxalate, which can form kidney stones in people prone to them.',
        ),
        HealthPoint(
          '🩸',
          'Blood clotting',
          'Large, changing amounts of vitamin K can interfere with blood thinners such as warfarin.',
        ),
        HealthPoint(
          '🤢',
          'Digestion',
          'Too much fibre at once can cause gas, bloating or loose motions.',
        ),
      ],
      precautions: [
        'Wash leaves thoroughly under running water to remove soil and pesticides.',
        'Boil or blanch palak and throw away the water to cut oxalate.',
        'Add lemon or amla to help the body absorb the iron.',
        'Had kidney stones? Prefer methi or other greens, and ask your doctor.',
        'On blood thinners? Keep the amount steady each day rather than stopping.',
        'Do not reheat cooked greens many times, especially for small children.',
      ],
    ),
  ),
  FoodTip(
    emoji: '🌾',
    name: 'Millets & whole grains',
    why: 'Ragi, jowar and bajra release energy slowly and help control sugar.',
    recommended: true,
    detail: FoodDetail(
      serving: '1 ragi roti (≈30 g flour)',
      kcal: 96,
      nutrients: [
        // Ragi flour, scaled from per-100 g values (IFCT 2017).
        Nutrient('Carbs', '20 g'),
        Nutrient('Fibre', '3.4 g'),
        Nutrient('Protein', '2.2 g'),
        Nutrient('Calcium', '109 mg'),
        Nutrient('Iron', '1.4 mg'),
        Nutrient('Magnesium', '44 mg'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: '1–2 small rotis or 1 katori ragi porridge a day',
          note:
              'Ragi porridge (ragi malt) is a traditional first food after 6 months.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: 'Make at least half your daily grains whole grains',
          note:
              'For example, swap 2–3 of your usual rotis or rice portions for millets.',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: '2–3 portions a day',
          note: 'Soft porridge or upma is easier to chew and digest.',
        ),
      ],
      benefits: [
        HealthPoint(
          '🍃',
          'Liver',
          'Swapping refined grains for whole grains helps lower liver fat.',
        ),
        HealthPoint(
          '🍬',
          'Type 2 diabetes',
          'Fibre slows digestion, so blood sugar rises gently after meals.',
        ),
        HealthPoint(
          '❤️',
          'Heart disease',
          'Soluble fibre helps lower LDL ("bad") cholesterol.',
        ),
        HealthPoint(
          '🦴',
          'Weak bones',
          'Ragi has about 3 times more calcium than milk, weight for weight.',
        ),
        HealthPoint(
          '🩸',
          'Anaemia',
          'Bajra and ragi add iron to vegetarian diets.',
        ),
        HealthPoint(
          '🚽',
          'Constipation',
          'Fibre keeps digestion regular and feeds healthy gut bacteria.',
        ),
      ],
      overconsumption: [
        HealthPoint(
          '🍬',
          'Blood sugar',
          'Millets are still carbohydrates. Large portions can still raise blood sugar.',
        ),
        HealthPoint(
          '🤢',
          'Digestion',
          'A sudden jump in fibre can cause gas and bloating.',
        ),
        HealthPoint(
          '🦋',
          'Thyroid',
          'Very large daily amounts of bajra may affect the thyroid when iodine intake is low.',
        ),
        HealthPoint(
          '🫘',
          'Kidneys',
          'Rich in potassium and phosphorus. People with kidney disease may need to limit them.',
        ),
      ],
      precautions: [
        'Switch gradually over 2–3 weeks and drink plenty of water.',
        'Soak, sprout or ferment millets to help the body absorb iron and zinc.',
        'Keep portions sensible: a millet roti still counts as a roti.',
        'Use iodised salt if you eat bajra every day.',
        'Packaged "multigrain" biscuits and snacks are often mostly maida. Read the label.',
        'Have kidney disease? Ask your doctor how much is right for you.',
      ],
    ),
  ),
  FoodTip(
    emoji: '🫘',
    name: 'Dal & legumes',
    why: 'Good plant protein that keeps you full for longer.',
    recommended: true,
    detail: FoodDetail(
      serving: '1 katori cooked dal (≈30 g raw masoor)',
      kcal: 106,
      nutrients: [
        // Masoor dal, scaled from per-100 g raw values (IFCT 2017).
        Nutrient('Protein', '7 g'),
        Nutrient('Fibre', '3.2 g'),
        Nutrient('Iron', '2 mg'),
        Nutrient('Folate', '144 µg'),
        Nutrient('Potassium', '203 mg'),
        Nutrient('Zinc', '1.4 mg'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: '½–1 katori, twice a day',
          note: 'Moong dal khichdi is gentle and easy to digest.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: '2–3 katoris a day',
          note:
              'Mix it up: dal, chana, rajma, sprouts. About 85 g raw pulses daily.',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: '2 katoris a day',
          note: 'Well-cooked moong or masoor is easiest on the stomach.',
        ),
      ],
      benefits: [
        HealthPoint(
          '🍃',
          'Liver',
          'Plant protein instead of red and processed meat helps reduce liver fat.',
        ),
        HealthPoint(
          '❤️',
          'Heart disease',
          'Fibre and potassium help lower cholesterol and blood pressure.',
        ),
        HealthPoint(
          '🍬',
          'Type 2 diabetes',
          'Low glycaemic index, so blood sugar rises slowly.',
        ),
        HealthPoint(
          '💪',
          'Muscle loss',
          'Protein helps keep muscles strong, especially after 60.',
        ),
        HealthPoint('🩸', 'Anaemia', 'A good source of iron and folate.'),
      ],
      overconsumption: [
        HealthPoint(
          '🤢',
          'Digestion',
          'Natural sugars in pulses can cause gas and bloating.',
        ),
        HealthPoint(
          '🫘',
          'Kidneys',
          'High in protein, potassium and phosphorus. People with kidney disease may need to limit them.',
        ),
        HealthPoint(
          '⚖️',
          'Weight',
          'A heavy ghee or butter tadka can double the calories.',
        ),
      ],
      precautions: [
        'Soak for 6–8 hours and throw away the water to reduce gas.',
        'Never eat raw or undercooked rajma. It contains a toxin destroyed only by thorough boiling.',
        'Pressure cook until fully soft.',
        'Add jeera, hing or ginger to help digestion.',
        'Pair with rice or roti for complete protein.',
        'Go easy on ghee and butter in the tadka.',
      ],
    ),
  ),
  FoodTip(
    emoji: '🥜',
    name: 'Walnuts & almonds',
    why: 'A small handful a day adds healthy fats.',
    recommended: true,
    detail: FoodDetail(
      serving: '1 small handful, 30 g (≈15 almonds + 4 walnut halves)',
      kcal: 181,
      nutrients: [
        // 20 g almonds + 10 g walnuts (USDA FoodData Central).
        Nutrient('Healthy fats', '16 g'),
        Nutrient('Protein', '5.7 g'),
        Nutrient('Fibre', '3.2 g'),
        Nutrient('Vitamin E', '5 mg'),
        Nutrient('Magnesium', '70 mg'),
        Nutrient('Omega-3', '0.9 g'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: '10–15 g a day',
          note:
              'Give powdered or finely chopped. Whole nuts can choke children under 5.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: '30 g (1 small handful) a day',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: '20–30 g a day',
          note: 'Soaked or powdered nuts are easier to chew.',
        ),
      ],
      benefits: [
        HealthPoint(
          '🍃',
          'Liver',
          'Vitamin E and omega-3 fats help protect the liver from fat damage.',
        ),
        HealthPoint(
          '❤️',
          'Heart disease',
          'Regular nut eaters have lower LDL cholesterol and fewer heart attacks.',
        ),
        HealthPoint(
          '🧠',
          'Memory loss',
          'Walnut omega-3s support brain health as you age.',
        ),
        HealthPoint(
          '🍬',
          'Type 2 diabetes',
          'Healthy fats and fibre improve how the body handles sugar.',
        ),
      ],
      overconsumption: [
        HealthPoint(
          '⚖️',
          'Weight',
          'Nuts are calorie-dense. Two handfuls instead of one adds about 180 kcal.',
        ),
        HealthPoint(
          '🤢',
          'Digestion',
          'Large amounts can cause bloating or loose motions.',
        ),
        HealthPoint(
          '🫘',
          'Kidneys',
          'Almonds contain oxalate, which can add to kidney stones in people prone to them.',
        ),
        HealthPoint(
          '🤧',
          'Allergy',
          'Tree nut allergy can cause severe reactions in some people.',
        ),
      ],
      precautions: [
        'Portion out one handful instead of eating from the packet.',
        'Choose plain nuts. Avoid salted, sugar-coated or fried masala nuts.',
        'Soak almonds overnight if they are hard to digest.',
        'Throw away nuts that taste bitter or look mouldy. Mould (aflatoxin) damages the liver.',
        'Store in an airtight container in a cool, dry place.',
        'Watch for signs of allergy the first time a child eats nuts.',
      ],
    ),
  ),
  FoodTip(
    emoji: '☕',
    name: 'Black coffee',
    why: 'Linked with lower liver fibrosis risk — skip the sugar.',
    recommended: true,
    detail: FoodDetail(
      serving: '1 cup (240 ml) brewed black coffee, no sugar',
      kcal: 2,
      nutrients: [
        Nutrient('Caffeine', '≈95 mg'),
        Nutrient('Potassium', '116 mg'),
        Nutrient('Magnesium', '7 mg'),
        Nutrient('Sugar', '0 g'),
        Nutrient('Fat', '0 g'),
        Nutrient('Polyphenols', 'High'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: 'Avoid',
          note: 'Caffeine is not recommended for children.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: '2–3 cups a day',
          note:
              'Up to 400 mg caffeine a day. If pregnant, no more than 200 mg (about 2 cups).',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: '1–2 cups a day',
          note: 'Have it before noon to protect sleep.',
        ),
      ],
      benefits: [
        HealthPoint(
          '🍃',
          'Liver fibrosis',
          'Regular coffee drinkers have lower rates of liver scarring and cirrhosis.',
        ),
        HealthPoint(
          '🎗️',
          'Liver cancer',
          'Studies link 2–3 cups a day with a lower risk of liver cancer.',
        ),
        HealthPoint(
          '🍬',
          'Type 2 diabetes',
          'Long-term coffee drinking is linked with lower diabetes risk.',
        ),
        HealthPoint(
          '🧠',
          "Parkinson's disease",
          'Caffeine is linked with a lower risk of Parkinson\'s.',
        ),
      ],
      overconsumption: [
        HealthPoint(
          '😴',
          'Sleep & nerves',
          'Too much causes poor sleep, anxiety and jitters.',
        ),
        HealthPoint(
          '❤️',
          'Heart',
          'Can cause palpitations and a short rise in blood pressure.',
        ),
        HealthPoint(
          '🔥',
          'Stomach',
          'Can worsen acidity and reflux, especially on an empty stomach.',
        ),
        HealthPoint(
          '🦴',
          'Bones',
          'Very high intake slightly reduces calcium absorption.',
        ),
      ],
      precautions: [
        'Skip the sugar and cream. Sugar adds liver fat and cancels the benefit.',
        'Avoid coffee after about 4 pm.',
        'Have it after breakfast if you get acidity.',
        'Paper-filtered coffee is better for cholesterol than boiled, unfiltered coffee.',
        'Pregnant? Keep to 2 cups or fewer a day.',
        'Have heart rhythm problems or high BP? Ask your doctor first.',
      ],
    ),
  ),
  FoodTip(
    emoji: '🥤',
    name: 'Sugary drinks',
    why:
        'Soft drinks and packaged juices add fructose, which builds liver fat.',
    recommended: false,
    detail: FoodDetail(
      serving: '1 can of cola (330 ml)',
      kcal: 139,
      nutrients: [
        Nutrient('Sugar', '35 g (≈9 tsp)'),
        Nutrient('Carbs', '35 g'),
        Nutrient('Caffeine', '≈34 mg'),
        Nutrient('Fibre', '0 g'),
        Nutrient('Protein', '0 g'),
        Nutrient('Vitamins', 'None'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: 'Avoid',
          note:
              'One can has more sugar than a child should have in a whole day.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: 'Best avoided; an occasional small glass at most',
          note:
              'WHO advises under 25 g (6 tsp) of added sugar a day from all foods.',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: 'Avoid',
          note: 'Choose water, chaas or unsweetened nimbu pani.',
        ),
      ],
      benefits: [
        HealthPoint(
          '🆘',
          'Low blood sugar (hypo)',
          'For people on diabetes medicines, a small glass of juice can quickly correct a sugar low.',
        ),
      ],
      overconsumption: [
        HealthPoint(
          '🍃',
          'Liver',
          'The liver turns fructose straight into fat. Sugary drinks are a leading cause of fatty liver.',
        ),
        HealthPoint(
          '🍬',
          'Pancreas & blood sugar',
          'Daily sugary drinks raise the risk of insulin resistance and type 2 diabetes.',
        ),
        HealthPoint('❤️', 'Heart', 'Raise triglycerides and blood pressure.'),
        HealthPoint(
          '🦷',
          'Teeth',
          'Sugar and acid together cause tooth decay.',
        ),
        HealthPoint(
          '⚖️',
          'Weight',
          'Liquid calories don\'t fill you up, so they add weight quickly.',
        ),
      ],
      swaps: [
        HealthPoint(
          '🍋',
          'Nimbu pani',
          'Fresh lime water with a pinch of salt. No sugar, or very little.',
        ),
        HealthPoint(
          '🥛',
          'Chaas (buttermilk)',
          'Cooling, with protein and gut-friendly bacteria.',
        ),
        HealthPoint(
          '🥥',
          'Coconut water',
          'Natural electrolytes. Have one glass, not several.',
        ),
        HealthPoint(
          '🍊',
          'Whole fruit',
          'Eat the orange instead of drinking the juice. The fibre slows the sugar.',
        ),
      ],
      precautions: [
        '"Fruit drink" and "nectar" usually mean added sugar. Read the label.',
        'Even 100% fruit juice is high in sugar. Keep to one small glass.',
        'More than 5 g sugar per 100 ml is high.',
        'Diet sodas avoid sugar, but plain water is still the best choice.',
        'Don\'t give sugary drinks to children.',
      ],
    ),
  ),
  FoodTip(
    emoji: '🍟',
    name: 'Fried snacks',
    why: 'Samosas, pakoras and chips are high in unhealthy fats.',
    recommended: false,
    detail: FoodDetail(
      serving: '1 medium samosa (≈70 g)',
      kcal: 240,
      nutrients: [
        // Approximate: varies a lot with size, filling and oil.
        Nutrient('Fat', '≈14 g'),
        Nutrient('Carbs', '≈25 g'),
        Nutrient('Protein', '≈4 g'),
        Nutrient('Fibre', '≈2 g'),
        Nutrient('Sodium', '≈350 mg'),
        Nutrient('Trans fat', 'High if oil is reused'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: 'An occasional treat, once a week at most',
          note: 'Keep it to a small portion.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: 'Once a week or less',
          note: 'One piece, not a plateful.',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: 'Rarely',
          note: 'Heavy to digest. Best avoided with heart disease or high BP.',
        ),
      ],
      overconsumption: [
        HealthPoint(
          '🍃',
          'Liver',
          'Extra calories and saturated fats build up as liver fat.',
        ),
        HealthPoint(
          '❤️',
          'Heart',
          'Trans fats from reused oil raise bad cholesterol and lower good cholesterol.',
        ),
        HealthPoint('🩺', 'Blood pressure', 'High salt raises blood pressure.'),
        HealthPoint(
          '🔥',
          'Stomach',
          'Oily food often triggers acidity and indigestion.',
        ),
        HealthPoint(
          '⚖️',
          'Weight',
          'One samosa is about the calories of two rotis with dal.',
        ),
      ],
      swaps: [
        HealthPoint(
          '🫘',
          'Roasted chana',
          'Crunchy, high in protein and fibre.',
        ),
        HealthPoint(
          '🍿',
          'Roasted makhana',
          'Light and low in fat. Roast with a little ghee and spices.',
        ),
        HealthPoint(
          '🥗',
          'Sprouts chaat',
          'Tangy and filling, with lots of fibre.',
        ),
        HealthPoint(
          '🍥',
          'Steamed snacks',
          'Dhokla, idli or momos (steamed, not fried).',
        ),
      ],
      precautions: [
        'Avoid street snacks fried in dark, reused oil.',
        'At home, don\'t reuse frying oil more than 2–3 times (FSSAI advice).',
        'Try an air fryer or oven for samosas and pakoras.',
        'Eat with mint chutney and salad instead of ketchup.',
        'Stick to one piece and eat it slowly.',
      ],
    ),
  ),
  FoodTip(
    emoji: '🍞',
    name: 'Maida & refined carbs',
    why: 'White bread, biscuits and bakery items spike blood sugar.',
    recommended: false,
    detail: FoodDetail(
      serving: '2 slices white bread (≈50 g)',
      kcal: 133,
      nutrients: [
        // White bread, per 50 g (USDA FoodData Central).
        Nutrient('Carbs', '25 g'),
        Nutrient('Fibre', '1.4 g'),
        Nutrient('Protein', '4.4 g'),
        Nutrient('Sugar', '2.5 g'),
        Nutrient('Sodium', '245 mg'),
        Nutrient('Glycaemic index', 'High (≈75)'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          ages: '1–9 years',
          amount: 'Occasionally',
          note: 'Choose whole-wheat bread and home-made snacks instead.',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          ages: '18–59 years',
          amount: 'Keep to a minimum',
          note: 'Swap for whole grains most days.',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          ages: '60+ years',
          amount: 'Occasionally',
          note: 'Soft whole-wheat options are just as easy to chew.',
        ),
      ],
      benefits: [
        HealthPoint(
          '🤒',
          'Upset stomach',
          'Plain toast is gentle on the stomach when recovering from loose motions or vomiting.',
        ),
      ],
      overconsumption: [
        HealthPoint(
          '🍃',
          'Liver',
          'Quick sugar spikes push the liver to store more fat.',
        ),
        HealthPoint(
          '🍬',
          'Blood sugar',
          'Digests almost like sugar, raising the risk of type 2 diabetes.',
        ),
        HealthPoint(
          '🚽',
          'Gut',
          'Very little fibre, which can lead to constipation.',
        ),
        HealthPoint(
          '❤️',
          'Heart',
          'Raises triglycerides, a type of fat in the blood.',
        ),
        HealthPoint(
          '⚖️',
          'Weight',
          'Leaves you hungry again soon, so you eat more.',
        ),
      ],
      swaps: [
        HealthPoint(
          '🫓',
          'Whole-wheat roti',
          'Atta keeps the bran and fibre that maida loses.',
        ),
        HealthPoint(
          '🍞',
          '100% whole-wheat bread',
          'Check that "whole wheat" is the first ingredient.',
        ),
        HealthPoint(
          '🌾',
          'Ragi or jowar roti',
          'Millets add fibre, calcium and iron.',
        ),
        HealthPoint(
          '🥣',
          'Oats or vegetable upma',
          'A filling breakfast that releases energy slowly.',
        ),
      ],
      precautions: [
        '"Wheat flour" or "refined wheat flour" on a label means maida.',
        '"Brown bread" is often coloured maida. Look for "100% whole wheat".',
        'Bakery items, naan and pizza bases are mostly maida, and often high in fat and sugar too.',
        'Pair any bread with protein or vegetables to slow the sugar rise.',
        'Cut down on biscuits and rusks with tea.',
      ],
    ),
  ),
];

const List<HealthTip> healthTips = [
  HealthTip(
    emoji: '🚶',
    title: 'Walk 30 minutes a day',
    body:
        'Brisk walking 5 days a week reduces liver fat, even without weight loss.',
  ),
  HealthTip(
    emoji: '⚖️',
    title: 'Aim for 7–10% weight loss',
    body:
        'If you are overweight, losing 7–10% of body weight can reverse fatty liver.',
  ),
  HealthTip(
    emoji: '😴',
    title: 'Sleep 7–8 hours',
    body: 'Poor sleep is linked to weight gain and insulin resistance.',
  ),
  HealthTip(
    emoji: '🩸',
    title: 'Check your sugar',
    body: 'Get HbA1c tested once a year — diabetes speeds up liver damage.',
  ),
  HealthTip(
    emoji: '💊',
    title: 'Avoid self-medication',
    body:
        'Some painkillers and herbal supplements can harm the liver. Ask your doctor first.',
  ),
];

const List<Faq> faqs = [
  Faq(
    question: 'What is fatty liver?',
    answer:
        'Fatty liver means extra fat has built up in liver cells. The most '
        'common type, NAFLD (now also called MASLD), is linked to diet, weight '
        'and diabetes — not alcohol.',
  ),
  Faq(
    question: 'Can fatty liver be reversed?',
    answer:
        'Yes. In its early stages, fatty liver can often be reversed with '
        'weight loss, a healthier diet and regular exercise.',
  ),
  Faq(
    question: 'I am not overweight. Can I still have fatty liver?',
    answer:
        'Yes. "Lean" fatty liver is common in South Asians, who can store '
        'fat around the organs even at a normal weight.',
  ),
  Faq(
    question: 'What does my FIB-4 score mean?',
    answer:
        'FIB-4 estimates the chance of liver scarring (fibrosis) from four '
        'blood test values. It is a screening tool, not a diagnosis.',
  ),
  Faq(
    question: 'Which doctor should I see?',
    answer:
        'Start with your family doctor. For an intermediate or high score, '
        'they may refer you to a gastroenterologist or hepatologist.',
  ),
  Faq(
    question: 'Which tests confirm fatty liver?',
    answer:
        'An ultrasound can show liver fat. A FibroScan measures liver '
        'stiffness to check for scarring.',
  ),
];
