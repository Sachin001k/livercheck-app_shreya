/// Home page content: food recommendations, health suggestions and FAQs.
///
/// DUMMY DATA — placeholder text to shape the UI. Replace it with content
/// reviewed by a doctor or dietitian before release. Later this can move
/// into a Supabase table so it can be updated without a new app release
/// (see README → Roadmap).
///
/// Every text field holds a TRANSLATION KEY (prefix `hm_`), not the text
/// itself. Show it with `context.t(key)`; the English text lives in
/// `lib/translations/en.dart`. Numbers with units (e.g. '3 g') are plain
/// data and shown as they are.
library;

class FoodTip {
  final String emoji;

  /// Translation key of the food's name.
  final String nameKey;

  /// Translation key of the one-line reason.
  final String whyKey;

  /// True for "eat more", false for "limit".
  final bool recommended;

  /// Full information shown when the card is tapped. Null until written.
  final FoodDetail? detail;

  const FoodTip({
    required this.emoji,
    required this.nameKey,
    required this.whyKey,
    required this.recommended,
    this.detail,
  });
}

/// Everything shown in a food's pop-up. All `...Key` fields are
/// translation keys.
class FoodDetail {
  /// Key of the portion the calories and nutrients refer to,
  /// e.g. "1 katori (100 g)".
  final String servingKey;
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

  /// Keys of the precautions.
  final List<String> precautionKeys;

  const FoodDetail({
    required this.servingKey,
    required this.kcal,
    required this.nutrients,
    required this.intake,
    this.benefits = const [],
    required this.overconsumption,
    this.swaps = const [],
    required this.precautionKeys,
  });
}

class Nutrient {
  /// Translation key of the nutrient's name.
  final String nameKey;

  /// Amount shown as-is (numbers and units, e.g. '3 g'). Null when the
  /// amount is words, see [amountKey].
  final String? amount;

  /// Translation key for an amount in words (e.g. "High").
  final String? amountKey;

  const Nutrient(this.nameKey, String this.amount) : amountKey = null;

  const Nutrient.words(this.nameKey, String this.amountKey) : amount = null;
}

enum AgeGroup { children, adults, elders }

class IntakeGuide {
  final AgeGroup group;

  /// Keys: who this row covers (e.g. "1–9 years"), the amount, and an
  /// optional note.
  final String agesKey;
  final String amountKey;
  final String? noteKey;

  const IntakeGuide({
    required this.group,
    required this.agesKey,
    required this.amountKey,
    this.noteKey,
  });
}

/// One benefit or risk: an emoji, what it affects, and why (both keys).
class HealthPoint {
  final String emoji;
  final String titleKey;
  final String bodyKey;

  const HealthPoint(this.emoji, this.titleKey, this.bodyKey);
}

class HealthTip {
  final String emoji;
  final String titleKey;
  final String bodyKey;

  const HealthTip({
    required this.emoji,
    required this.titleKey,
    required this.bodyKey,
  });
}

class Faq {
  final String questionKey;
  final String answerKey;

  const Faq({required this.questionKey, required this.answerKey});
}

const List<FoodTip> foodTips = [
  FoodTip(
    emoji: '🥬',
    nameKey: 'hm_greensName',
    whyKey: 'hm_greensWhy',
    recommended: true,
    detail: FoodDetail(
      servingKey: 'hm_greensServing',
      kcal: 23,
      nutrients: [
        // Boiled spinach, per 100 g (USDA FoodData Central).
        Nutrient('hm_nutProtein', '3 g'),
        Nutrient('hm_nutFibre', '2.4 g'),
        Nutrient('hm_nutIron', '3.6 mg'),
        Nutrient('hm_nutFolate', '146 µg'),
        Nutrient('hm_nutVitaminK', '494 µg'),
        Nutrient('hm_nutVitaminC', '10 mg'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_greensKidsAmt',
          noteKey: 'hm_greensKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_greensAdultAmt',
          noteKey: 'hm_greensAdultNote',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_greensAdultAmt',
          noteKey: 'hm_greensElderNote',
        ),
      ],
      benefits: [
        HealthPoint('🍃', 'hm_ptLiver', 'hm_greensBen1'),
        HealthPoint('❤️', 'hm_ptHeartDisease', 'hm_greensBen2'),
        HealthPoint('🩸', 'hm_ptAnaemia', 'hm_greensBen3'),
        HealthPoint('🦴', 'hm_ptWeakBones', 'hm_greensBen4'),
        HealthPoint('👁️', 'hm_ptEyeProblems', 'hm_greensBen5'),
        HealthPoint('🍬', 'hm_ptDiabetes2', 'hm_greensBen6'),
      ],
      overconsumption: [
        HealthPoint('🫘', 'hm_ptKidneys', 'hm_greensRisk1'),
        HealthPoint('🩸', 'hm_ptBloodClotting', 'hm_greensRisk2'),
        HealthPoint('🤢', 'hm_ptDigestion', 'hm_greensRisk3'),
      ],
      precautionKeys: [
        'hm_greensPrec1',
        'hm_greensPrec2',
        'hm_greensPrec3',
        'hm_greensPrec4',
        'hm_greensPrec5',
        'hm_greensPrec6',
      ],
    ),
  ),
  FoodTip(
    emoji: '🌾',
    nameKey: 'hm_milletName',
    whyKey: 'hm_milletWhy',
    recommended: true,
    detail: FoodDetail(
      servingKey: 'hm_milletServing',
      kcal: 96,
      nutrients: [
        // Ragi flour, scaled from per-100 g values (IFCT 2017).
        Nutrient('hm_nutCarbs', '20 g'),
        Nutrient('hm_nutFibre', '3.4 g'),
        Nutrient('hm_nutProtein', '2.2 g'),
        Nutrient('hm_nutCalcium', '109 mg'),
        Nutrient('hm_nutIron', '1.4 mg'),
        Nutrient('hm_nutMagnesium', '44 mg'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_milletKidsAmt',
          noteKey: 'hm_milletKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_milletAdultAmt',
          noteKey: 'hm_milletAdultNote',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_milletElderAmt',
          noteKey: 'hm_milletElderNote',
        ),
      ],
      benefits: [
        HealthPoint('🍃', 'hm_ptLiver', 'hm_milletBen1'),
        HealthPoint('🍬', 'hm_ptDiabetes2', 'hm_milletBen2'),
        HealthPoint('❤️', 'hm_ptHeartDisease', 'hm_milletBen3'),
        HealthPoint('🦴', 'hm_ptWeakBones', 'hm_milletBen4'),
        HealthPoint('🩸', 'hm_ptAnaemia', 'hm_milletBen5'),
        HealthPoint('🚽', 'hm_ptConstipation', 'hm_milletBen6'),
      ],
      overconsumption: [
        HealthPoint('🍬', 'hm_ptBloodSugar', 'hm_milletRisk1'),
        HealthPoint('🤢', 'hm_ptDigestion', 'hm_milletRisk2'),
        HealthPoint('🦋', 'hm_ptThyroid', 'hm_milletRisk3'),
        HealthPoint('🫘', 'hm_ptKidneys', 'hm_milletRisk4'),
      ],
      precautionKeys: [
        'hm_milletPrec1',
        'hm_milletPrec2',
        'hm_milletPrec3',
        'hm_milletPrec4',
        'hm_milletPrec5',
        'hm_milletPrec6',
      ],
    ),
  ),
  FoodTip(
    emoji: '🫘',
    nameKey: 'hm_dalName',
    whyKey: 'hm_dalWhy',
    recommended: true,
    detail: FoodDetail(
      servingKey: 'hm_dalServing',
      kcal: 106,
      nutrients: [
        // Masoor dal, scaled from per-100 g raw values (IFCT 2017).
        Nutrient('hm_nutProtein', '7 g'),
        Nutrient('hm_nutFibre', '3.2 g'),
        Nutrient('hm_nutIron', '2 mg'),
        Nutrient('hm_nutFolate', '144 µg'),
        Nutrient('hm_nutPotassium', '203 mg'),
        Nutrient('hm_nutZinc', '1.4 mg'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_dalKidsAmt',
          noteKey: 'hm_dalKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_dalAdultAmt',
          noteKey: 'hm_dalAdultNote',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_dalElderAmt',
          noteKey: 'hm_dalElderNote',
        ),
      ],
      benefits: [
        HealthPoint('🍃', 'hm_ptLiver', 'hm_dalBen1'),
        HealthPoint('❤️', 'hm_ptHeartDisease', 'hm_dalBen2'),
        HealthPoint('🍬', 'hm_ptDiabetes2', 'hm_dalBen3'),
        HealthPoint('💪', 'hm_ptMuscleLoss', 'hm_dalBen4'),
        HealthPoint('🩸', 'hm_ptAnaemia', 'hm_dalBen5'),
      ],
      overconsumption: [
        HealthPoint('🤢', 'hm_ptDigestion', 'hm_dalRisk1'),
        HealthPoint('🫘', 'hm_ptKidneys', 'hm_dalRisk2'),
        HealthPoint('⚖️', 'hm_ptWeight', 'hm_dalRisk3'),
      ],
      precautionKeys: [
        'hm_dalPrec1',
        'hm_dalPrec2',
        'hm_dalPrec3',
        'hm_dalPrec4',
        'hm_dalPrec5',
        'hm_dalPrec6',
      ],
    ),
  ),
  FoodTip(
    emoji: '🥜',
    nameKey: 'hm_nutsName',
    whyKey: 'hm_nutsWhy',
    recommended: true,
    detail: FoodDetail(
      servingKey: 'hm_nutsServing',
      kcal: 181,
      nutrients: [
        // 20 g almonds + 10 g walnuts (USDA FoodData Central).
        Nutrient('hm_nutHealthyFats', '16 g'),
        Nutrient('hm_nutProtein', '5.7 g'),
        Nutrient('hm_nutFibre', '3.2 g'),
        Nutrient('hm_nutVitaminE', '5 mg'),
        Nutrient('hm_nutMagnesium', '70 mg'),
        Nutrient('hm_nutOmega3', '0.9 g'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_nutsKidsAmt',
          noteKey: 'hm_nutsKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_nutsAdultAmt',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_nutsElderAmt',
          noteKey: 'hm_nutsElderNote',
        ),
      ],
      benefits: [
        HealthPoint('🍃', 'hm_ptLiver', 'hm_nutsBen1'),
        HealthPoint('❤️', 'hm_ptHeartDisease', 'hm_nutsBen2'),
        HealthPoint('🧠', 'hm_ptMemoryLoss', 'hm_nutsBen3'),
        HealthPoint('🍬', 'hm_ptDiabetes2', 'hm_nutsBen4'),
      ],
      overconsumption: [
        HealthPoint('⚖️', 'hm_ptWeight', 'hm_nutsRisk1'),
        HealthPoint('🤢', 'hm_ptDigestion', 'hm_nutsRisk2'),
        HealthPoint('🫘', 'hm_ptKidneys', 'hm_nutsRisk3'),
        HealthPoint('🤧', 'hm_ptAllergy', 'hm_nutsRisk4'),
      ],
      precautionKeys: [
        'hm_nutsPrec1',
        'hm_nutsPrec2',
        'hm_nutsPrec3',
        'hm_nutsPrec4',
        'hm_nutsPrec5',
        'hm_nutsPrec6',
      ],
    ),
  ),
  FoodTip(
    emoji: '☕',
    nameKey: 'hm_coffeeName',
    whyKey: 'hm_coffeeWhy',
    recommended: true,
    detail: FoodDetail(
      servingKey: 'hm_coffeeServing',
      kcal: 2,
      nutrients: [
        Nutrient('hm_nutCaffeine', '≈95 mg'),
        Nutrient('hm_nutPotassium', '116 mg'),
        Nutrient('hm_nutMagnesium', '7 mg'),
        Nutrient('hm_nutSugar', '0 g'),
        Nutrient('hm_nutFat', '0 g'),
        Nutrient.words('hm_nutPolyphenols', 'hm_nutAmtHigh'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_amtAvoid',
          noteKey: 'hm_coffeeKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_coffeeAdultAmt',
          noteKey: 'hm_coffeeAdultNote',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_coffeeElderAmt',
          noteKey: 'hm_coffeeElderNote',
        ),
      ],
      benefits: [
        HealthPoint('🍃', 'hm_ptLiverFibrosis', 'hm_coffeeBen1'),
        HealthPoint('🎗️', 'hm_ptLiverCancer', 'hm_coffeeBen2'),
        HealthPoint('🍬', 'hm_ptDiabetes2', 'hm_coffeeBen3'),
        HealthPoint('🧠', 'hm_ptParkinsons', 'hm_coffeeBen4'),
      ],
      overconsumption: [
        HealthPoint('😴', 'hm_ptSleepNerves', 'hm_coffeeRisk1'),
        HealthPoint('❤️', 'hm_ptHeart', 'hm_coffeeRisk2'),
        HealthPoint('🔥', 'hm_ptStomach', 'hm_coffeeRisk3'),
        HealthPoint('🦴', 'hm_ptBones', 'hm_coffeeRisk4'),
      ],
      precautionKeys: [
        'hm_coffeePrec1',
        'hm_coffeePrec2',
        'hm_coffeePrec3',
        'hm_coffeePrec4',
        'hm_coffeePrec5',
        'hm_coffeePrec6',
      ],
    ),
  ),
  FoodTip(
    emoji: '🥤',
    nameKey: 'hm_drinksName',
    whyKey: 'hm_drinksWhy',
    recommended: false,
    detail: FoodDetail(
      servingKey: 'hm_drinksServing',
      kcal: 139,
      nutrients: [
        Nutrient.words('hm_nutSugar', 'hm_nutAmtColaSugar'),
        Nutrient('hm_nutCarbs', '35 g'),
        Nutrient('hm_nutCaffeine', '≈34 mg'),
        Nutrient('hm_nutFibre', '0 g'),
        Nutrient('hm_nutProtein', '0 g'),
        Nutrient.words('hm_nutVitamins', 'hm_nutAmtNone'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_amtAvoid',
          noteKey: 'hm_drinksKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_drinksAdultAmt',
          noteKey: 'hm_drinksAdultNote',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_amtAvoid',
          noteKey: 'hm_drinksElderNote',
        ),
      ],
      benefits: [
        HealthPoint('🆘', 'hm_ptHypo', 'hm_drinksBen1'),
      ],
      overconsumption: [
        HealthPoint('🍃', 'hm_ptLiver', 'hm_drinksRisk1'),
        HealthPoint('🍬', 'hm_ptPancreasSugar', 'hm_drinksRisk2'),
        HealthPoint('❤️', 'hm_ptHeart', 'hm_drinksRisk3'),
        HealthPoint('🦷', 'hm_ptTeeth', 'hm_drinksRisk4'),
        HealthPoint('⚖️', 'hm_ptWeight', 'hm_drinksRisk5'),
      ],
      swaps: [
        HealthPoint('🍋', 'hm_drinksSwap1Title', 'hm_drinksSwap1Body'),
        HealthPoint('🥛', 'hm_drinksSwap2Title', 'hm_drinksSwap2Body'),
        HealthPoint('🥥', 'hm_drinksSwap3Title', 'hm_drinksSwap3Body'),
        HealthPoint('🍊', 'hm_drinksSwap4Title', 'hm_drinksSwap4Body'),
      ],
      precautionKeys: [
        'hm_drinksPrec1',
        'hm_drinksPrec2',
        'hm_drinksPrec3',
        'hm_drinksPrec4',
        'hm_drinksPrec5',
      ],
    ),
  ),
  FoodTip(
    emoji: '🍟',
    nameKey: 'hm_friedName',
    whyKey: 'hm_friedWhy',
    recommended: false,
    detail: FoodDetail(
      servingKey: 'hm_friedServing',
      kcal: 240,
      nutrients: [
        // Approximate: varies a lot with size, filling and oil.
        Nutrient('hm_nutFat', '≈14 g'),
        Nutrient('hm_nutCarbs', '≈25 g'),
        Nutrient('hm_nutProtein', '≈4 g'),
        Nutrient('hm_nutFibre', '≈2 g'),
        Nutrient('hm_nutSodium', '≈350 mg'),
        Nutrient.words('hm_nutTransFat', 'hm_nutAmtHighIfReused'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_friedKidsAmt',
          noteKey: 'hm_friedKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_friedAdultAmt',
          noteKey: 'hm_friedAdultNote',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_friedElderAmt',
          noteKey: 'hm_friedElderNote',
        ),
      ],
      overconsumption: [
        HealthPoint('🍃', 'hm_ptLiver', 'hm_friedRisk1'),
        HealthPoint('❤️', 'hm_ptHeart', 'hm_friedRisk2'),
        HealthPoint('🩺', 'hm_ptBloodPressure', 'hm_friedRisk3'),
        HealthPoint('🔥', 'hm_ptStomach', 'hm_friedRisk4'),
        HealthPoint('⚖️', 'hm_ptWeight', 'hm_friedRisk5'),
      ],
      swaps: [
        HealthPoint('🫘', 'hm_friedSwap1Title', 'hm_friedSwap1Body'),
        HealthPoint('🍿', 'hm_friedSwap2Title', 'hm_friedSwap2Body'),
        HealthPoint('🥗', 'hm_friedSwap3Title', 'hm_friedSwap3Body'),
        HealthPoint('🍥', 'hm_friedSwap4Title', 'hm_friedSwap4Body'),
      ],
      precautionKeys: [
        'hm_friedPrec1',
        'hm_friedPrec2',
        'hm_friedPrec3',
        'hm_friedPrec4',
        'hm_friedPrec5',
      ],
    ),
  ),
  FoodTip(
    emoji: '🍞',
    nameKey: 'hm_maidaName',
    whyKey: 'hm_maidaWhy',
    recommended: false,
    detail: FoodDetail(
      servingKey: 'hm_maidaServing',
      kcal: 133,
      nutrients: [
        // White bread, per 50 g (USDA FoodData Central).
        Nutrient('hm_nutCarbs', '25 g'),
        Nutrient('hm_nutFibre', '1.4 g'),
        Nutrient('hm_nutProtein', '4.4 g'),
        Nutrient('hm_nutSugar', '2.5 g'),
        Nutrient('hm_nutSodium', '245 mg'),
        Nutrient.words('hm_nutGlycaemicIndex', 'hm_nutAmtHighGi'),
      ],
      intake: [
        IntakeGuide(
          group: AgeGroup.children,
          agesKey: 'hm_ages1to9',
          amountKey: 'hm_amtOccasionally',
          noteKey: 'hm_maidaKidsNote',
        ),
        IntakeGuide(
          group: AgeGroup.adults,
          agesKey: 'hm_ages18to59',
          amountKey: 'hm_maidaAdultAmt',
          noteKey: 'hm_maidaAdultNote',
        ),
        IntakeGuide(
          group: AgeGroup.elders,
          agesKey: 'hm_ages60plus',
          amountKey: 'hm_amtOccasionally',
          noteKey: 'hm_maidaElderNote',
        ),
      ],
      benefits: [
        HealthPoint('🤒', 'hm_ptUpsetStomach', 'hm_maidaBen1'),
      ],
      overconsumption: [
        HealthPoint('🍃', 'hm_ptLiver', 'hm_maidaRisk1'),
        HealthPoint('🍬', 'hm_ptBloodSugar', 'hm_maidaRisk2'),
        HealthPoint('🚽', 'hm_ptGut', 'hm_maidaRisk3'),
        HealthPoint('❤️', 'hm_ptHeart', 'hm_maidaRisk4'),
        HealthPoint('⚖️', 'hm_ptWeight', 'hm_maidaRisk5'),
      ],
      swaps: [
        HealthPoint('🫓', 'hm_maidaSwap1Title', 'hm_maidaSwap1Body'),
        HealthPoint('🍞', 'hm_maidaSwap2Title', 'hm_maidaSwap2Body'),
        HealthPoint('🌾', 'hm_maidaSwap3Title', 'hm_maidaSwap3Body'),
        HealthPoint('🥣', 'hm_maidaSwap4Title', 'hm_maidaSwap4Body'),
      ],
      precautionKeys: [
        'hm_maidaPrec1',
        'hm_maidaPrec2',
        'hm_maidaPrec3',
        'hm_maidaPrec4',
        'hm_maidaPrec5',
      ],
    ),
  ),
];

const List<HealthTip> healthTips = [
  HealthTip(emoji: '🚶', titleKey: 'hm_tip1Title', bodyKey: 'hm_tip1Body'),
  HealthTip(emoji: '⚖️', titleKey: 'hm_tip2Title', bodyKey: 'hm_tip2Body'),
  HealthTip(emoji: '😴', titleKey: 'hm_tip3Title', bodyKey: 'hm_tip3Body'),
  HealthTip(emoji: '🩸', titleKey: 'hm_tip4Title', bodyKey: 'hm_tip4Body'),
  HealthTip(emoji: '💊', titleKey: 'hm_tip5Title', bodyKey: 'hm_tip5Body'),
];

const List<Faq> faqs = [
  Faq(questionKey: 'hm_faq1Q', answerKey: 'hm_faq1A'),
  Faq(questionKey: 'hm_faq2Q', answerKey: 'hm_faq2A'),
  Faq(questionKey: 'hm_faq3Q', answerKey: 'hm_faq3A'),
  Faq(questionKey: 'hm_faq4Q', answerKey: 'hm_faq4A'),
  Faq(questionKey: 'hm_faq5Q', answerKey: 'hm_faq5A'),
  Faq(questionKey: 'hm_faq6Q', answerKey: 'hm_faq6A'),
];
