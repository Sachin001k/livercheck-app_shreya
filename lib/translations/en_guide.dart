/// English text of the liver guide (the "Guide" tab), taken from the
/// LivrCheck fatty liver guidebook. Merged into [en] in `en.dart`.
///
/// Keys start with `gd_`. Other languages fall back to this English text
/// until they are translated.
const Map<String, String> enGuide = {
  // ---------------------------------------------------------------- UI
  'gd_navGuide': "Guide",
  'gd_tabTitle': "Liver guide",
  'gd_heroTitle': "Fatty liver disease",
  'gd_heroSub': "Know your liver, protect your health",
  'gd_heroBody': "A guide for children, adults, older adults and families.",
  'gd_showFor': "Show advice for",
  'gd_ageChildren': "Children (under 18)",
  'gd_ageAdults': "Adults (18–64)",
  'gd_ageOlder': "Older adults (65+)",
  'gd_ageChildrenShort': "Children",
  'gd_ageAdultsShort': "Adults",
  'gd_ageOlderShort': "Older adults",
  'gd_forAge': "Advice by age group",
  'gd_chapter': "Chapter {n}",
  'gd_topics': "{n} topics",
  'gd_next': "Next: {title}",
  'gd_backToChapter': "Back to the chapter",
  'gd_keyMessage': "Key message",
  'gd_measures': "What it measures",
  'gd_limits': "Limitations",
  'gd_chooseLess': "Choose less often",
  'gd_tryInstead': "Try instead",
  'gd_myth': "Myth",
  'gd_fact': "Fact",
  'gd_important': "Important information",
  'gd_disclaimer':
      "This guide gives general health information and is not a substitute "
      "for professional medical advice. Pediatric assessment differs from "
      "adult assessment (e.g., test ranges and follow-up plans can be "
      "different).",
  'gd_reviewed':
      "This guidebook has been reviewed by a multidisciplinary team of "
      "healthcare professionals (e.g., hepatology, pediatrics, family "
      "medicine and nutrition).",
  'gd_homeCardTitle': "Liver guide",
  'gd_homeCardBody':
      "Know your liver, your risk, the tests and what you can do — for "
      "every age.",
  'gd_homeCardButton': "Open the guide",
  'gd_homeStepsTitle': "Remember these 5 steps",
  'gd_homeFaqMore': "More questions in the Guide",
  'gd_savedOnPhone': "Saved on this phone",
  'gd_ckNone':
      "Nothing ticked. Keep up your healthy habits and check again if "
      "anything changes.",
  'gd_ckResult':
      "You ticked {n} of {total}. If you have concerns, ask a healthcare "
      "professional whether liver assessment is appropriate.",
  'gd_chWeek': "This week",
  'gd_chDone': "{n} of {total} done",
  'gd_chDayDone': "{n}/{total}",
  'gd_chTapHint': "Pick a day, then tick each habit you did.",
  'gd_plPickDate': "Pick a date",
  'gd_plChangeDate': "Change date",
  'gd_comingSoon': "Coming soon",

  // ------------------------------------------------------------ chapters
  'gd_c1T': "Know your liver",
  'gd_c1B':
      "How the liver works, what it does for your body, and why it matters "
      "for your overall health.",
  'gd_c2T': "Know your risk",
  'gd_c2B':
      "The factors that can increase your risk of fatty liver and related "
      "liver problems.",
  'gd_c3T': "Get checked",
  'gd_c3B':
      "Tests and assessments: what they involve, what the results may mean, "
      "and when to get checked.",
  'gd_c4T': "Take action",
  'gd_c4B':
      "Improve your liver health through food, physical activity, sleep, "
      "weight and medicines (if needed).",
  'gd_c5T': "Your liver health plan",
  'gd_c5B':
      "Set goals, track your progress and keep a healthier liver over time.",
  'gd_c6T': "Where to get help",
  'gd_c6B': "Who to see, and trusted sources for more information.",

  // ------------------------------------------- 1.1 Why your liver matters
  'gd_lmT': "Why your liver matters",
  'gd_lmIntro':
      "Your liver is one of the most important organs in your body, "
      "carrying out many essential functions to keep you healthy.",
  'gd_lm1T': "Processes nutrients from food",
  'gd_lm1B':
      "Converts food into useful substances and stores excess nutrients "
      "(such as glucose and vitamins).",
  'gd_lm2T': "Helps manage energy",
  'gd_lm2B':
      "Keeps your energy levels balanced by storing and releasing glucose "
      "when needed.",
  'gd_lm3T': "Produces bile",
  'gd_lm3B':
      "Makes bile, a fluid that helps to digest and absorb fats and "
      "fat-soluble vitamins (A, D, E and K).",
  'gd_lm4T': "Processes substances",
  'gd_lm4B':
      "Breaks down and helps remove waste products, toxins, alcohol and "
      "medicines from the body.",
  'gd_lm5T': "Stores nutrients",
  'gd_lm5B':
      "Stores important substances, such as vitamins (A, D, E, K and B12) "
      "and minerals (such as iron and copper), for when the body needs them.",
  'gd_lm6T': "Produces proteins",
  'gd_lm6B':
      "Makes proteins that help with blood clotting, maintain fluid balance "
      "and support the immune system.",
  'gd_lmC': "The liver supports growth and development.",
  'gd_lmA': "The liver supports energy and metabolic functions.",
  'gd_lmO':
      "The liver remains important for nutrition, metabolism and medicine "
      "processing.",
  'gd_lmKey': "Your liver works continuously, often without you noticing.",

  // --------------------------------------- 1.2 What is fatty liver disease?
  'gd_flT': "What is fatty liver disease?",
  'gd_flIntro':
      "Fatty liver disease (also called hepatic steatosis) means that excess "
      "fat builds up in the liver, mainly as fat droplets inside liver cells, "
      "which can affect the liver's structure and function.",
  'gd_flNormalT': "How much fat is normal?",
  'gd_flNormalB':
      "A small amount of fat in the liver (usually less than 5% of liver "
      "weight) is normal. When fat exceeds this level, it is considered "
      "fatty liver disease.",
  'gd_flGoodT': "Healthy liver",
  'gd_flGoodB':
      "A healthy liver contains a small amount of fat and has a normal "
      "structure and function.",
  'gd_flGood1': "Only a small amount of fat (usually < 5%)",
  'gd_flGood2': "Normal liver structure and function",
  'gd_flGood3': "Carries out all its important roles",
  'gd_flBadT': "Fatty liver",
  'gd_flBadB':
      "Excess fat builds up inside liver cells, as fat droplets. Over time, "
      "this can make the liver enlarged and yellowish and can affect its "
      "function.",
  'gd_flBad1': "Excess fat accumulated inside liver cells",
  'gd_flBad2': "May make the liver enlarged and yellowish",
  'gd_flBad3': "Can affect liver function over time",
  'gd_flBad4': "Often does not cause noticeable symptoms",
  'gd_flC':
      "Liver fat can occur in children, including those who are not "
      "overweight.",
  'gd_flA':
      "Liver fat can occur in adults, including people who appear to have a "
      "healthy body weight.",
  'gd_flO':
      "Liver fat can also occur in older adults, and it may be more common "
      "with age, even in those who are not overweight.",
  'gd_flKey':
      "Globally, about 1 in 4 adults (around 25%) has fatty liver disease.",
  'gd_flSrc': "Source: Younossi ZM, et al. Hepatology. 2016;64(1):73–84.",

  // ---------------------------------------------------- 1.3 Main types
  'gd_tyT': "Main types of fatty liver disease",
  'gd_tyWhyT': "Why does the type matter?",
  'gd_tyWhyB':
      "Fatty liver disease is not a single condition. The type is important "
      "because the causes, risk of progression, monitoring and treatment "
      "approach can be different.",
  'gd_ty1T': "MASLD (metabolic dysfunction-associated steatotic liver disease)",
  'gd_ty1B':
      "The most common type. It is linked to metabolic risk factors such as "
      "being overweight or having Type 2 diabetes, high blood pressure or "
      "abnormal cholesterol.",
  'gd_ty1N': "Caused by metabolic factors (not related to excess alcohol).",
  'gd_ty2T': "MASH (metabolic dysfunction-associated steatohepatitis)",
  'gd_ty2B':
      "A more serious form of MASLD. It involves fat in the liver along with "
      "inflammation and liver cell damage, which can lead to fibrosis "
      "(scarring) and, in some people, cirrhosis.",
  'gd_ty2N': "A progressive form that can cause liver scarring over time.",
  'gd_ty3T': "Alcohol-related liver disease (ALD)",
  'gd_ty3B':
      "Caused by regular or long-term heavy alcohol use, which can lead to "
      "fat accumulation, inflammation, liver cell damage and scarring.",
  'gd_ty3N': "Related to regular or heavy alcohol use.",
  'gd_ty4T':
      "MetALD (metabolic dysfunction and alcohol-associated liver disease)",
  'gd_ty4B':
      "Occurs in people who have metabolic risk factors (such as obesity, "
      "Type 2 diabetes or high cholesterol) and also consume "
      "moderate-to-heavy amounts of alcohol.",
  'gd_ty4N': "Involves both metabolic risk factors and alcohol use.",
  'gd_tyC': "Pediatric assessment and causes require special consideration.",
  'gd_tyA': "Metabolic risk factors and alcohol history are important.",
  'gd_tyO':
      "Metabolic conditions, alcohol exposure, medicines and other causes "
      "may coexist.",
  'gd_tyKey': "A healthcare professional determines the diagnosis.",

  // --------------------------------------------------------- 1.4 Stages
  'gd_stT': "Stages of fatty liver disease",
  'gd_stIntro':
      "Fatty liver disease can range from a build-up of fat in the liver to "
      "inflammation, scarring (fibrosis) and, in some people, cirrhosis. It "
      "may progress over time, remain stable or even improve with the right "
      "changes and care.",
  'gd_st1T': "1. Steatosis (fatty liver)",
  'gd_st1B':
      "Excess fat builds up in liver cells (fat droplets), usually without "
      "noticeable symptoms.",
  'gd_st2T': "2. Steatohepatitis (MASH)",
  'gd_st2B':
      "Fat build-up with inflammation and liver cell injury. This can lead "
      "to scarring over time.",
  'gd_st3T': "3. Fibrosis",
  'gd_st3B':
      "A build-up of scar tissue (fibrosis) in the liver, often from ongoing "
      "inflammation and liver cell injury.",
  'gd_st4T': "4. Cirrhosis",
  'gd_st4B':
      "Extensive scarring that changes the liver's structure and can reduce "
      "its function.",
  'gd_stDiffT': "MASH and fibrosis are related but different",
  'gd_stDiff1':
      "MASH (steatohepatitis) means fat build-up with inflammation and liver "
      "cell injury.",
  'gd_stDiff2':
      "Fibrosis means the build-up of scar tissue in the liver, which can "
      "occur after ongoing inflammation (such as in MASH).",
  'gd_stSeqT': "The disease does not always progress in a fixed sequence",
  'gd_stSeq1': "Some people may stay at the steatosis stage for many years.",
  'gd_stSeq2': "Some may develop MASH and fibrosis.",
  'gd_stSeq3': "Progression to cirrhosis occurs in a smaller number of people.",
  'gd_stSeq4':
      "With appropriate care, the disease can sometimes be stabilized or "
      "even reversed (especially in the earlier stages).",
  'gd_stAll':
      "Advanced liver disease can occur across age groups, including "
      "children, adults and older adults, although the causes and "
      "evaluation may differ.",
  'gd_stKey': "Early assessment can help identify risk and guide care.",

  // -------------------------------------------------- 2.1 Who is at risk?
  'gd_rkT': "Who is at risk?",
  'gd_rkIntro':
      "Fatty liver can occur in people with excess body weight, but it can "
      "also occur in people with a healthy-looking body weight (lean fatty "
      "liver).",
  'gd_rkC1T': "Family metabolic history",
  'gd_rkC2T': "Metabolic risk factors",
  'gd_rkC2B': "e.g., higher blood sugar, cholesterol or triglycerides",
  'gd_rkC3T': "Low activity",
  'gd_rkC3B': "Physical inactivity",
  'gd_rkC4T': "Sleep problems",
  'gd_rkC4B': "e.g., short or poor quality sleep",
  'gd_rkA1T': "Type 2 diabetes",
  'gd_rkA2T': "Abdominal adiposity",
  'gd_rkA2B': "Excess fat around the waist",
  'gd_rkA3T': "High blood pressure",
  'gd_rkA4T': "PCOS or sleep apnoea",
  'gd_rkA4B': "PCOS: polycystic ovary syndrome",
  'gd_rkO2T': "Metabolic conditions",
  'gd_rkO4T': "Sleep apnoea and other illnesses",
  'gd_rkO4B': "e.g., thyroid disease, chronic kidney disease",
  'gd_rkLeanT': "Lean fatty liver",
  'gd_rkLeanB':
      "Fatty liver can occur even in people who are not overweight. It is "
      "often linked to metabolic risk factors such as diabetes, high blood "
      "pressure or abnormal cholesterol.",
  'gd_rkSaT': "South Asian metabolic risk",
  'gd_rkSaB':
      "People of South Asian ethnicity can develop fatty liver at lower "
      "levels of body weight and waist size. Screening considerations for "
      "Asian adults:",
  'gd_rkSa1': "BMI ≥ 23 kg/m²",
  'gd_rkSa2': "Waist ≥ 90 cm (men) or ≥ 80 cm (women)",
  'gd_rkKey': "Body shape alone cannot tell you whether your liver is healthy.",

  // ------------------------------------------ 2.2 Could you be at risk?
  'gd_ckT': "Could you be at risk?",
  'gd_ckIntro':
      "Use this quick checklist to reflect on factors that can be linked to "
      "fatty liver disease. It is for awareness only and does not replace a "
      "medical assessment or diagnosis.",
  'gd_ckC1':
      "Is there a family history of fatty liver, diabetes or other metabolic "
      "conditions?",
  'gd_ckC2':
      "Has your child been diagnosed with a metabolic condition (e.g., "
      "overweight/obesity, high cholesterol or Type 2 diabetes)?",
  'gd_ckC3':
      "Is your child usually less active (e.g., little physical activity or "
      "lots of screen time)?",
  'gd_ckC4':
      "Does your child often have sleep problems (e.g., snoring or poor "
      "sleep)?",
  'gd_ckC5':
      "Has your child ever had a liver-related concern or abnormal liver "
      "test result?",
  'gd_ckCNote': "A parent or caregiver can help complete this checklist.",
  'gd_ckA1': "Have you been diagnosed with Type 2 diabetes?",
  'gd_ckA2': "Do you have high cholesterol or triglycerides?",
  'gd_ckA3': "Do you have high blood pressure?",
  'gd_ckA4': "Do you have increased abdominal fat (a larger waist size)?",
  'gd_ckA5': "Do you drink alcohol regularly or in moderate to large amounts?",
  'gd_ckA6':
      "Have you ever had abnormal liver test results or been told you have "
      "a fatty liver?",
  'gd_ckO1':
      "Do you have any metabolic conditions (e.g., Type 2 diabetes, high "
      "cholesterol or high blood pressure)?",
  'gd_ckO2':
      "Have you previously been told you have a fatty liver or had abnormal "
      "liver test or imaging results?",
  'gd_ckO3':
      "Do you take medicines that could affect the liver (e.g., long-term or "
      "multiple medicines)?",
  'gd_ckO4': "Do you drink alcohol regularly or in moderate to large amounts?",
  'gd_ckO5':
      "Do you have other long-term illnesses (e.g., kidney disease, heart "
      "disease or thyroid disease)?",
  'gd_ckKey':
      "If you have concerns, ask a healthcare professional whether liver "
      "assessment is appropriate.",

  // ----------------------------------------------------- 2.3 Symptoms
  'gd_syT': "Fatty liver often causes no symptoms",
  'gd_syIntro':
      "Many people only find out they have it during routine blood tests or "
      "an ultrasound done for another reason.",
  'gd_syEarlyT': "Early or mild signs",
  'gd_syEarlyB':
      "If symptoms do appear, they are often vague and can be mistaken for "
      "other conditions.",
  'gd_sy1T': "Persistent fatigue",
  'gd_sy1B':
      "Feeling unusually tired or lacking energy without an obvious cause.",
  'gd_sy2T': "Abdominal discomfort",
  'gd_sy2B':
      "A dull ache, fullness or heaviness in the upper right side of the "
      "belly (where the liver sits).",
  'gd_sy3T': "General malaise",
  'gd_sy3B':
      "Simply feeling unwell or experiencing mild, unexplained weakness.",
  'gd_syLateT': "More advanced signs (fibrosis or cirrhosis)",
  'gd_syLateB':
      "If the liver develops severe inflammation or scarring, the body may "
      "show clearer signs that the liver is struggling to function.",
  'gd_sy4T': "Jaundice",
  'gd_sy4B': "Yellowing of the skin and the whites of the eyes.",
  'gd_sy5T': "Fluid accumulation (oedema and ascites)",
  'gd_sy5B':
      "Swelling in the legs, ankles or feet, and a tightly bloated abdomen "
      "due to fluid build-up.",
  'gd_syC1':
      "Symptoms, if present, are often mild and non-specific (e.g., "
      "tiredness or abdominal discomfort).",
  'gd_syC2':
      "A healthcare professional should evaluate any persistent or "
      "concerning symptoms.",
  'gd_syA1':
      "Symptoms can be vague (e.g., fatigue or upper abdominal discomfort) "
      "or may be absent.",
  'gd_syA2':
      "Persistent symptoms should be assessed by a healthcare professional.",
  'gd_syO1':
      "Symptoms may be subtle (e.g., reduced appetite, fatigue or abdominal "
      "fullness) and can overlap with other conditions.",
  'gd_syO2':
      "Ongoing or new symptoms should be evaluated by a healthcare "
      "professional.",
  'gd_syWeightT': "See a doctor: unexplained weight loss",
  'gd_syWeightB':
      "Dropping weight without trying can be a sign of more advanced liver "
      "disease or another medical problem and should be checked by a "
      "healthcare professional.",

  // ---------------------------------------------- 2.4 When to see a doctor
  'gd_drT': "When to see a doctor",
  'gd_drIntro':
      "Fatty liver disease often has no symptoms, but it is important to get "
      "medical advice if you have risk factors, abnormal test results or any "
      "concerning signs.",
  'gd_drApptT': "Schedule an appointment if you:",
  'gd_dr1T': "Have persistent concerns",
  'gd_dr1B': "e.g., ongoing fatigue, abdominal discomfort or reduced appetite.",
  'gd_dr2T': "Have abnormal test results",
  'gd_dr2B':
      "e.g., elevated liver enzymes, or imaging findings such as fatty liver "
      "on ultrasound.",
  'gd_dr3T': "Have known risk factors",
  'gd_dr3B':
      "e.g., Type 2 diabetes, high blood pressure, high cholesterol, excess "
      "abdominal fat or regular alcohol use.",
  'gd_dr4T': "Have unexplained symptoms",
  'gd_dr4B':
      "e.g., persistent tiredness, unintentional weight loss or feeling "
      "generally unwell.",
  'gd_drUrgentT':
      "Seek urgent care (e.g., at an emergency department) if you have:",
  'gd_dr5T': "Vomiting blood",
  'gd_dr5B': "Bright red or coffee-ground-like material.",
  'gd_dr6T': "Black, tarry stools",
  'gd_dr6B': "Which can be a sign of bleeding in the digestive tract.",
  'gd_dr7T': "Severe confusion",
  'gd_dr7B':
      "e.g., marked drowsiness, difficulty staying awake or not knowing "
      "where you are.",
  'gd_dr8T': "Significant bleeding",
  'gd_dr8B':
      "e.g., from the mouth or nose, or bruising easily with large or "
      "frequent bruises.",
  'gd_dr9T': "A rapidly worsening illness",
  'gd_dr9B':
      "e.g., increasing abdominal swelling, breathing difficulty or severe "
      "weakness.",
  'gd_drC1':
      "Involve a parent or caregiver in noticing concerns and deciding "
      "whether to seek medical advice.",
  'gd_drC2':
      "A healthcare professional can assess symptoms, risk factors and any "
      "relevant test results.",
  'gd_drA1':
      "Seek a medical assessment if you have persistent concerns, abnormal "
      "test results, known risk factors or unexplained symptoms.",
  'gd_drA2':
      "Discuss your lifestyle, medical history and alcohol use with a "
      "healthcare professional.",
  'gd_drO1':
      "Seek medical advice if you have new or persistent concerns, abnormal "
      "test results or a known risk of liver disease.",
  'gd_drO2':
      "Review all your medical conditions and medicines (including "
      "long-term or multiple medicines) with a healthcare professional, as "
      "these may affect your liver.",
  'gd_drKey':
      "Do not wait for symptoms before discussing relevant risk factors.",

  // --------------------------------------- 3.1 How is fatty liver detected?
  'gd_dtT': "How is fatty liver detected?",
  'gd_dtIntro':
      "Fatty liver often does not cause noticeable symptoms, especially in "
      "its early stages. It is usually detected through a combination of "
      "your medical history, examination, blood tests and imaging, which "
      "help confirm the condition and assess its severity.",
  'gd_dtPathT': "Typical assessment pathway",
  'gd_dt1T': "Medical history",
  'gd_dt1B':
      "Review your lifestyle, medical conditions (e.g., diabetes, high "
      "cholesterol) and alcohol use.",
  'gd_dt2T': "Examination",
  'gd_dt2B':
      "Check your weight, calculate your BMI and examine your abdomen to "
      "look for signs of an enlarged liver.",
  'gd_dt3T': "Blood tests",
  'gd_dt3B':
      "Assess liver function (e.g., ALT, AST) and metabolic factors (e.g., "
      "blood sugar, cholesterol, triglycerides).",
  'gd_dt4T': "Imaging or fibrosis assessment (when indicated)",
  'gd_dt4B':
      "An ultrasound (usually first-line) and, when needed, tests of liver "
      "stiffness (e.g., FibroScan/MRE) or other imaging (e.g., CT or MRI).",
  'gd_dtC1T': "Pediatric history",
  'gd_dtC1B':
      "Review family history, growth and lifestyle (e.g., diet, activity and "
      "screen time).",
  'gd_dtC2T': "Growth assessment",
  'gd_dtC2B':
      "Check growth, weight status (e.g., BMI-for-age) and overall "
      "development.",
  'gd_dtC3T': "Appropriate laboratory evaluation",
  'gd_dtC3B':
      "Age-appropriate blood tests (e.g., liver function and metabolic "
      "tests) if fatty liver is suspected.",
  'gd_dtA1T': "Metabolic assessment",
  'gd_dtA1B':
      "Evaluate metabolic risk factors (e.g., Type 2 diabetes, abdominal "
      "adiposity, high blood pressure and high cholesterol).",
  'gd_dtA2T': "Liver tests",
  'gd_dtA2B':
      "Check liver enzymes (e.g., ALT, AST) and other relevant blood tests.",
  'gd_dtA3T': "Fibrosis risk stratification",
  'gd_dtA3B':
      "Estimate the risk of liver scarring (fibrosis) using non-invasive "
      "tools (e.g., blood-based scores and/or elastography).",
  'gd_dtO3T': "Additional considerations",
  'gd_dtO3B':
      "Review other medical conditions and all current medicines, as they "
      "may affect the liver. Consider age-related factors (e.g., changes in "
      "test results or imaging interpretation).",
  'gd_dtKey': "No single test answers every question about liver health.",

  // ---------------------------------------------- 3.2 Understanding FIB-4
  'gd_f4T': "Understanding FIB-4",
  'gd_f4Intro':
      "FIB-4 (Fibrosis-4 Index) is a non-invasive, widely used initial "
      "risk-stratification score that estimates the likelihood of "
      "significant liver scarring (fibrosis) in appropriate adult patients.",
  'gd_f4InT': "What goes into FIB-4?",
  'gd_f4In1T': "Age",
  'gd_f4In1B': "In years",
  'gd_f4In2T': "AST",
  'gd_f4In2B': "Aspartate aminotransferase, U/L (sometimes labelled SGOT)",
  'gd_f4In3T': "ALT",
  'gd_f4In3B': "Alanine aminotransferase, U/L (sometimes labelled SGPT)",
  'gd_f4In4T': "Platelet count",
  'gd_f4In4B': "×10⁹/L",
  'gd_f4ResT': "Interpreting the FIB-4 result",
  'gd_f4LowT': "Low risk · FIB-4 below 1.3",
  'gd_f4LowB':
      "Advanced fibrosis is unlikely. Routine monitoring is usually "
      "appropriate.",
  'gd_f4MidT': "Intermediate risk · FIB-4 1.3 – 2.67",
  'gd_f4MidB':
      "The risk is uncertain. Consider additional fibrosis assessment (e.g., "
      "transient elastography).",
  'gd_f4HighT': "High risk · FIB-4 above 2.67",
  'gd_f4HighB':
      "A higher likelihood of significant fibrosis. Additional assessment "
      "and specialist evaluation are recommended.",
  'gd_f4C':
      "FIB-4 is not recommended as a routine pediatric fibrosis assessment tool.",
  'gd_f4A':
      "FIB-4 can help determine whether additional fibrosis assessment is needed.",
  'gd_f4O':
      "Interpretation requires age-adjusted considerations and clinical judgment.",
  'gd_f4LimT': "Limitations",
  'gd_f4LimB':
      "FIB-4 is less reliable in adults younger than 35 years and older than "
      "65 years, and results should always be interpreted in the context of "
      "the overall clinical picture.",
  'gd_f4Key':
      "You can work out your FIB-4 in the Check tab by adding your blood "
      "report values.",

  // ---------------------------------- 3.3 Understanding your test results
  'gd_tsT': "Understanding your test results",
  'gd_tsIntro':
      "Different tests give different information about your liver. Results "
      "need to be interpreted by a healthcare professional together with "
      "your medical history, examination and overall risk factors.",
  'gd_ts1T': "Liver enzymes (ALT and AST)",
  'gd_ts1B': "Signs of liver cell injury or inflammation.",
  'gd_ts1N':
      "Can be normal even when significant scarring (fibrosis) is present.",
  'gd_ts2T': "Metabolic tests (e.g., blood sugar, cholesterol)",
  'gd_ts2B': "Conditions often linked to fatty liver.",
  'gd_ts2N': "Do not diagnose fatty liver or measure liver damage.",
  'gd_ts3T': "Ultrasound",
  'gd_ts3B': "Detects a fatty liver and looks for other liver problems.",
  'gd_ts3N': "Less sensitive for mild fat and cannot reliably assess scarring.",
  'gd_ts4T': "FibroScan (liver stiffness)",
  'gd_ts4B': "Estimates liver stiffness (related to scarring).",
  'gd_ts4N':
      "Results can be affected by factors such as inflammation or high body "
      "weight.",
  'gd_ts5T': "CAP (fat measurement)",
  'gd_ts5B': "Estimates the amount of fat in the liver.",
  'gd_ts5N': "Estimates fat rather than providing a direct measurement.",
  'gd_ts6T': "MRI-PDFF (liver fat)",
  'gd_ts6B': "Accurately measures the amount of liver fat.",
  'gd_ts6N': "More costly and not usually needed for routine assessment.",
  'gd_ts7T': "Liver biopsy",
  'gd_ts7B': "Examines liver tissue to confirm inflammation, fat and scarring.",
  'gd_ts7N': "Invasive, with a small risk of bleeding or other complications.",
  'gd_tsC':
      "Test selection and interpretation are based on individual risk "
      "factors and growth and development.",
  'gd_tsA':
      "A combination of blood tests and imaging (e.g., ultrasound or "
      "FibroScan) is often used, with results interpreted together with "
      "your risk factors.",
  'gd_tsO':
      "Test selection and interpretation may be adjusted for other health "
      "conditions and medicines.",
  'gd_tsKey':
      "Normal liver enzymes do not always exclude significant liver disease.",

  // ------------------------------------------ 3.4 What happens after testing?
  'gd_afT': "What happens after testing?",
  'gd_afIntro':
      "The next step depends on your overall risk of liver disease, which is "
      "based on your test results, risk factors, other health conditions "
      "and age. This helps ensure you get the right follow-up and care.",
  'gd_afC1T': "Pediatric assessment",
  'gd_afC2T': "Appropriate investigations",
  'gd_afC2B': "e.g., blood tests, ultrasound",
  'gd_afC3T': "Specialist referral if indicated",
  'gd_afC3B': "e.g., concerns about liver scarring or ongoing liver problems",
  'gd_afA1T': "Initial fibrosis assessment",
  'gd_afA1B': "e.g., FIB-4, ultrasound or FibroScan",
  'gd_afA2T': "Additional testing when indicated",
  'gd_afA2B': "e.g., FibroScan, CAP, MRI-PDFF",
  'gd_afA3T': "Monitoring or specialist referral based on results",
  'gd_afA3B':
      "e.g., routine follow-up for low risk, or referral for signs of "
      "significant liver disease",
  'gd_afO1T': "Adult fibrosis pathway with age-adjusted interpretation",
  'gd_afO1B': "e.g., FIB-4 with age-related considerations",
  'gd_afO2T': "Additional assessment",
  'gd_afO2B': "e.g., FibroScan, ultrasound or other tests, as needed",
  'gd_afO3T': "Individualized follow-up",
  'gd_afO3B':
      "e.g., monitoring, lifestyle support and treatment of other health "
      "conditions, with specialist input when needed",
  'gd_afAskT': "Questions to ask your doctor",
  'gd_afAsk1': "What do my test results mean for my liver health?",
  'gd_afAsk2': "Do I need any additional tests?",
  'gd_afAsk3': "How often should I be monitored?",
  'gd_afAsk4': "Do I need to see a liver specialist?",
  'gd_afAsk5': "What can I do now to lower my risk and protect my liver?",
  'gd_afSpecT': "Why might I need specialist evaluation?",
  'gd_afSpecB':
      "A specialist (e.g., a liver doctor or hepatologist) can provide a "
      "more detailed evaluation, confirm the diagnosis, assess the stage of "
      "liver disease and recommend a personalized management plan if your "
      "risk is higher or your test results are concerning.",

  // ------------------------------------------ 3.5 Follow-up and monitoring
  'gd_fuT': "Follow-up and monitoring",
  'gd_fuIntro':
      "Follow-up helps track your liver health over time, check for "
      "changes, and decide if additional tests or treatment are needed. The "
      "plan is personalized based on your age, risk factors and test "
      "results.",
  'gd_fuWhatT': "What may be monitored",
  'gd_fuWhoT': "Who reviews the results",
  'gd_fuWhenT': "When reassessment may be needed",
  'gd_fuCWhat':
      "Liver enzymes (ALT, AST); metabolic factors (e.g., weight, blood "
      "sugar, cholesterol); liver imaging (e.g., ultrasound), if needed.",
  'gd_fuCWho': "Pediatrician or pediatric liver specialist (hepatologist).",
  'gd_fuCWhen':
      "Based on the underlying condition, risk factors and initial results. "
      "The timing is individualized (e.g., during routine follow-up visits "
      "or sooner if concerns arise).",
  'gd_fuAWhat':
      "Liver enzymes (ALT, AST); metabolic factors (e.g., blood sugar, "
      "cholesterol); liver fibrosis risk (e.g., FIB-4); liver imaging (e.g., "
      "ultrasound, FibroScan), if indicated.",
  'gd_fuAWho': "Primary care provider or liver specialist (hepatologist).",
  'gd_fuAWhen':
      "If FIB-4 is used and results are non-high risk, guideline-based "
      "reassessment is typically every 2–3 years (lower risk) or every 1–2 "
      "years (higher risk within the non-high range). Sooner reassessment "
      "may be needed if your health status changes or risk increases.",
  'gd_fuOWhat':
      "Liver enzymes (ALT, AST); metabolic factors (e.g., blood sugar, "
      "cholesterol); liver fibrosis risk (e.g., FIB-4, with age-adjusted "
      "interpretation); liver imaging (e.g., ultrasound, FibroScan), if "
      "indicated.",
  'gd_fuOWho': "Primary care provider or liver specialist (hepatologist).",
  'gd_fuOWhen':
      "Typically every 1–2 years, depending on overall risk, other health "
      "conditions and prior results. Sooner reassessment may be needed if "
      "there are changes in symptoms, test results or clinical status.",
  'gd_fuRecT': "Your personal follow-up record",
  'gd_fuRecB':
      "Soon you'll be able to save each test here — date, test, result and "
      "next appointment — and get a reminder before it's due.",
  'gd_fuKey':
      "Cirrhosis and other advanced conditions need different surveillance plans.",

  // ------------------------------------------------ 4.1 Food and your liver
  'gd_fdT': "Food and your liver",
  'gd_fdKeyTop': "Eating well supports liver and metabolic health.",
  'gd_fd1T': "Vegetables",
  'gd_fd1B':
      "A variety of colourful vegetables (e.g., spinach, cauliflower, carrot, beans).",
  'gd_fd2T': "Whole grains",
  'gd_fd2B':
      "Whole, less-processed grains (e.g., whole wheat roti, brown rice, millets).",
  'gd_fd3T': "Protein foods",
  'gd_fd3B':
      "Healthy protein sources (e.g., dal, beans, lentils, paneer, fish, "
      "chicken, eggs, soy).",
  'gd_fdIndT': "Indian examples for a liver-friendly meal",
  'gd_fdInd1': "Dal (lentils)",
  'gd_fdInd2': "Roti (whole wheat)",
  'gd_fdInd3': "Vegetables (e.g., bhindi, lauki, palak)",
  'gd_fdInd4': "Fruit (e.g., apple, banana, orange, papaya)",
  'gd_fdInd5': "Curd (plain, low-fat)",
  'gd_fdC1': "Choose nutritious meals that support growth and development.",
  'gd_fdC2':
      "Avoid restrictive dieting (e.g., very low-calorie diets) unless "
      "advised by a healthcare professional.",
  'gd_fdA1': "Aim for balanced meals with a variety of nutrient-rich foods.",
  'gd_fdA2':
      "Include fibre (e.g., whole grains, vegetables, fruits) and healthy "
      "fats (e.g., nuts, seeds, vegetable oils).",
  'gd_fdA3':
      "Choose appropriate portion sizes to help maintain a healthy weight.",
  'gd_fdO1':
      "Ensure adequate nutrition and protein (e.g., dal, paneer, eggs, fish, "
      "chicken, legumes).",
  'gd_fdO2':
      "Adjust food choices based on individual medical needs (e.g., "
      "diabetes, heart or kidney conditions), with guidance from a "
      "healthcare professional.",
  'gd_fdKey':
      "Stay well-hydrated throughout the day (e.g., with water, unsweetened "
      "tea or buttermilk).",

  // -------------------------------------------- 4.2 Foods and habits to limit
  'gd_ltT': "Foods and habits to limit",
  'gd_ltIntro':
      "Some foods and drinks add extra sugar, unhealthy fats and calories, "
      "which may increase the risk of fatty liver and other liver and "
      "metabolic problems. Have them less often and choose healthier, "
      "everyday options.",
  'gd_lt1T': "Soda and other sugar-sweetened drinks",
  'gd_lt1B': "e.g., cola, fizzy drinks",
  'gd_lt1sT': "Water",
  'gd_lt1sB': "Plain, unsweetened",
  'gd_lt2T': "Packaged juice",
  'gd_lt2B': "e.g., fruit drinks with added sugar",
  'gd_lt2sT': "Whole fruit",
  'gd_lt2sB': "e.g., apple, banana, mango, orange",
  'gd_lt3T': "Frequent fried snacks",
  'gd_lt3B': "e.g., samosa, pakora, chakli",
  'gd_lt3sT': "Roasted chana (roasted gram)",
  'gd_lt3sB': "A higher-fibre, lower-fat snack",
  'gd_lt4T': "Heavily processed meals",
  'gd_lt4B': "e.g., burgers, instant noodles, ready-to-eat meals",
  'gd_lt4sT': "Balanced home-cooked meals",
  'gd_lt4sB': "e.g., roti, dal, vegetables, salad and curd",
  'gd_ltC1': "Choose water, milk or unsweetened drinks.",
  'gd_ltC2':
      "Keep high-sugar drinks and fried or packaged snacks for occasional "
      "treats.",
  'gd_ltA1':
      "Maintain regular meal times and avoid frequent high-calorie snacks.",
  'gd_ltA2':
      "Limit foods high in added sugar, refined grains and unhealthy fats.",
  'gd_ltO1':
      "Ensure adequate and balanced nutrition, including enough protein.",
  'gd_ltO2':
      "Choose easier-to-digest, nutrient-rich options as needed (e.g., dal, "
      "eggs, curd, soft-cooked vegetables).",
  'gd_ltKey': "Small, realistic changes matter more than perfection.",

  // -------------------------------------------- 4.3 Physical activity
  'gd_acT': "Physical activity and liver health",
  'gd_acIntro':
      "Being active helps reduce excess body fat, improve metabolism, and "
      "lower the risk of fatty liver and other liver problems.",
  'gd_acC1T': "Active play, sports, cycling, dancing",
  'gd_acC2T': "At least 60 minutes of moderate to vigorous activity daily",
  'gd_acA1T': "Walking, cycling, strength exercises",
  'gd_acA2T': "At least 150 minutes per week",
  'gd_acA2B': "e.g., 30 minutes, 5 days a week",
  'gd_acA3T': "Plus muscle-strengthening activities on at least 2 days a week",
  'gd_acO1T': "Walking, balance and strength exercises",
  'gd_acO2T': "At least 150 minutes per week (as tolerated)",
  'gd_acO3T': "Plus balance and strength exercises on at least 2 days a week",
  'gd_acSafeT': "Safety note",
  'gd_acSafeB':
      "Adapt the type, intensity and duration of activity to your own "
      "ability, including if you have a disability, frailty or a medical "
      "condition. Ask your healthcare professional for personalized advice.",
  'gd_acSrc1':
      "World Health Organization. WHO Guidelines on Physical Activity and "
      "Sedentary Behaviour. 2020.",
  'gd_acSrc2':
      "Keating SE, et al. Exercise for non-alcoholic fatty liver disease: a "
      "systematic review and meta-analysis. J Hepatol. 2022;77:667–682.",

  // ------------------------------------- 4.4 Sleep, screens and daily habits
  'gd_slT': "Sleep, screens and daily habits",
  'gd_slIntro':
      "Sleep and daily routines support overall metabolic health, including "
      "healthier weight, blood sugar and liver health.",
  'gd_slC1T': "Sleep",
  'gd_slC1B': "6–12 years: 9–12 hours · 13–18 years: 8–10 hours",
  'gd_slC2T': "Limit prolonged recreational screen time",
  'gd_slC2B': "e.g., for entertainment",
  'gd_slC3T': "Keep regular bedtime habits",
  'gd_slC3B': "e.g., a consistent bedtime and wake-up time",
  'gd_slA1T': "Follow a regular sleep routine",
  'gd_slA1B': "e.g., similar bedtime and wake-up time most days",
  'gd_slA2T': "Take movement breaks during long periods of sitting",
  'gd_slA2B': "e.g., every 30–60 minutes",
  'gd_slA3T': "Be alert to possible sleep apnoea signs",
  'gd_slA3B':
      "e.g., loud snoring, pauses in breathing, daytime tiredness — and "
      "discuss them with a clinician",
  'gd_slO1T': "Maintain a regular sleep pattern",
  'gd_slO1B': "e.g., similar bedtime and wake-up time",
  'gd_slO2T': "Keep active in the daytime",
  'gd_slO2B': "e.g., walking, light exercises or daily activities",
  'gd_slO3T': "Discuss persistent sleep difficulties with a clinician",
  'gd_slO3B':
      "e.g., trouble falling asleep, frequent waking or excessive daytime "
      "sleepiness",
  'gd_slHabT': "Healthy daily habits for better sleep and metabolic health",
  'gd_slHab1': "Put devices away before bed.",
  'gd_slHab2': "Move during the day.",
  'gd_slHab3':
      "Keep a consistent routine (e.g., sleep, meals and activity times).",
  'gd_slChT': "One-week sleep-habit challenge",
  'gd_slChB':
      "For the next 7 days, try to: (1) keep a consistent bedtime and "
      "wake-up time, (2) limit recreational screen time in the evening, and "
      "(3) be active during the day. Notice how you feel at the end of the "
      "week.",

  // ----------------------------------------- 4.5 Healthy weight and growth
  'gd_wtT': "Healthy weight and growth",
  'gd_wtIntro':
      "Healthy body composition and nutrition matter for liver and "
      "metabolic health, but the goals can be different at each stage of "
      "life.",
  'gd_wtC1': "Focus on healthy growth and development.",
  'gd_wtC2': "Encourage balanced, varied meals.",
  'gd_wtC3': "Support regular physical activity and active play.",
  'gd_wtC4':
      "Have growth, nutrition and overall health checked by a pediatrician.",
  'gd_wtA1':
      "Aim for a medically appropriate weight-management goal with guidance "
      "from a healthcare professional.",
  'gd_wtA2':
      "A suitable, sustained reduction in body weight can reduce fat in the "
      "liver, lower inflammation, and slow or improve liver scarring "
      "(fibrosis).",
  'gd_wtO1': "Focus on preserving muscle strength and function.",
  'gd_wtO2':
      "Ensure adequate protein intake (e.g., dal, eggs, curd, milk, legumes).",
  'gd_wtO3': "Help prevent frailty by staying active and well nourished.",
  'gd_wtO4':
      "Use a careful, individualized approach to weight management, "
      "considering overall health, medical conditions and medicines.",
  'gd_wtCrashT': "Avoid crash diets",
  'gd_wtCrashB':
      "Restrictive diets can be unhealthy and may lead to nutrient "
      "deficiencies, loss of muscle and other problems. They can be "
      "especially harmful to growing children and frail older adults.",

  // --------------------------- 4.6 Diabetes, cholesterol and blood pressure
  'gd_mbT': "Diabetes, cholesterol and blood pressure",
  'gd_mbIntro':
      "Metabolic health and liver health are closely linked. Diabetes, "
      "abnormal cholesterol or triglycerides and high blood pressure can "
      "increase fat in the liver and, over time, raise the risk of liver "
      "inflammation, scarring (fibrosis) and other liver problems.",
  'gd_mb1T': "Diabetes",
  'gd_mb1B':
      "Higher blood sugar can be linked to more liver fat and a greater risk "
      "of liver inflammation and scarring. Keep blood sugar under control, "
      "as advised by your healthcare professional.",
  'gd_mb2T': "Cholesterol / triglycerides",
  'gd_mb2B':
      "Higher triglycerides and an unhealthy cholesterol pattern can "
      "increase liver fat and the risk of liver disease. Improve and keep "
      "healthy lipid levels through a balanced lifestyle and, if needed, "
      "medicines as advised by your clinician.",
  'gd_mb3T': "Blood pressure",
  'gd_mb3B':
      "High blood pressure often occurs with other metabolic conditions "
      "(e.g., overweight, diabetes) and can be part of a higher overall risk "
      "for liver and heart health. Keep blood pressure within your target "
      "range, with lifestyle measures and treatment as advised by your "
      "healthcare professional.",
  'gd_mbC':
      "Pediatric diagnosis and targets differ from adult targets. See a "
      "pediatric healthcare professional for age-appropriate assessment and "
      "management.",
  'gd_mbA':
      "Metabolic conditions such as diabetes, high cholesterol/triglycerides "
      "and high blood pressure should be managed with individualized "
      "clinical goals.",
  'gd_mbO':
      "Targets may need adjusting for frailty, other illnesses and treatment "
      "risks (e.g., risk of low blood sugar or side effects).",

  // ------------------------------------------- 4.7 Medicines and treatment
  'gd_mdT': "Medicines and treatment",
  'gd_mdIntro':
      "Treatment depends on the cause, disease stage, age and other health conditions.",
  'gd_mdOverT': "Treatment overview",
  'gd_md1T': "Lifestyle management",
  'gd_md1B':
      "Healthy, balanced diet and portion control · regular physical "
      "activity · weight management (as appropriate) · avoiding alcohol and "
      "limiting processed foods.",
  'gd_md2T': "Treatment of associated metabolic conditions",
  'gd_md2B':
      "Manage diabetes (maintain target control) · control cholesterol and "
      "triglycerides (as per guidelines) · keep blood pressure within target "
      "range.",
  'gd_md3T': "Medicines for selected patients with MASH",
  'gd_md3B':
      "Considered for patients with more advanced disease or higher risk. "
      "The choice of medicine depends on individual factors (e.g., disease "
      "stage, other conditions, potential benefits and risks).",
  'gd_mdC1': "Pediatric specialist-directed treatment.",
  'gd_mdC2': "Do not extrapolate adult drug approvals.",
  'gd_mdA':
      "Some medicines may be appropriate for specific patients, depending on "
      "approved indications and availability.",
  'gd_mdO':
      "Treatment decisions must consider other medicines, organ function and tolerability.",
  'gd_mdSelfT': "Do not self-medicate",
  'gd_mdSelfB': "Avoid self-medication and unverified herbal products.",

  // ---------------------------------------- 5.1 My 7-day liver health challenge
  'gd_chT': "My 7-day liver health challenge",
  'gd_chIntro':
      "Small, consistent changes can make a big difference for your liver. "
      "Tick each habit when you complete it. You can repeat this plan every "
      "week and keep adding new goals.",
  'gd_ch1T': "Drink enough water",
  'gd_ch1B': "Aim for 6–8 glasses (1.5–2 litres) throughout the day.",
  'gd_ch2T': "Eat vegetables",
  'gd_ch2B': "Include vegetables in at least two meals.",
  'gd_ch3T': "Eat whole fruits",
  'gd_ch3B': "Choose fresh fruits instead of fruit juices or sweets.",
  'gd_ch4T': "Avoid junk and processed foods",
  'gd_ch4B':
      "Limit fried foods, sugary drinks, packaged snacks and ultra-processed "
      "foods.",
  'gd_ch5T': "Be physically active",
  'gd_ch5B':
      "Aim for at least 30 minutes of moderate activity (e.g., walking, "
      "cycling, yoga).",
  'gd_ch6T': "Reduce sitting time",
  'gd_ch6B': "Take short movement breaks every 1–2 hours.",
  'gd_ch7T': "Get enough sleep",
  'gd_ch7B': "Aim for 7–8 hours of good quality sleep.",
  'gd_ch8T': "Take prescribed medicines",
  'gd_ch8B':
      "Take your medicines as advised for diabetes, cholesterol, blood "
      "pressure or other conditions.",
  'gd_chSuccessT': "My biggest success this week",
  'gd_chSuccessH':
      "What went well? (e.g., walked daily, ate more vegetables, drank water, slept better)",
  'gd_chImproveT': "One thing I want to improve next week",
  'gd_chImproveH':
      "What will I focus on? (e.g., fewer sugary drinks, more activity, "
      "earlier sleep, taking medicines regularly)",
  'gd_rememberT': "Remember",
  'gd_rememberB':
      "You do not have to be perfect. Even small steps can improve your "
      "liver health over time. If you have any medical conditions, follow "
      "your doctor's advice.",

  // ----------------------------------------- 5.2 My personal action plan
  'gd_plT': "My personal action plan",
  'gd_plIntro':
      "Small, consistent changes can make a big difference for your liver. "
      "Use this plan to set realistic goals, build healthy habits and take "
      "steps towards a healthier liver.",
  'gd_pl1T': "1. My main goal",
  'gd_pl1H':
      "What do I want to achieve for my liver health? (e.g., lose weight, "
      "reduce sugar, stop alcohol, improve fitness)",
  'gd_pl2T': "2. One food change I will make",
  'gd_pl2H':
      "Be specific (e.g., add one extra serving of vegetables daily, replace "
      "sugary drinks with water, include whole grains).",
  'gd_pl3T': "3. One activity change I will start or increase",
  'gd_pl3H':
      "Be specific (e.g., walk for 30 minutes, do yoga, use the stairs instead of the lift).",
  'gd_pl4T': "4. One habit I will reduce or avoid",
  'gd_pl4H':
      "Be specific (e.g., avoid alcohol, limit junk food, reduce sitting time).",
  'gd_pl5T': "5. My next health check",
  'gd_pl5H':
      "When will I check my progress or meet my healthcare provider? (e.g., "
      "date for blood tests, doctor appointment)",
  'gd_pl5Ask': "I will ask my healthcare provider about:",
  'gd_pl6T': "6. The person(s) who can support me",
  'gd_pl6H':
      "Who can encourage or help you? (e.g., family member, friend, "
      "healthcare provider, community group)",
  'gd_plTipsT': "Tips for success",
  'gd_plTip1T': "Set realistic goals",
  'gd_plTip1B': "Choose small and achievable changes.",
  'gd_plTip2T': "Track your progress",
  'gd_plTip2B': "Write down what works and celebrate your achievements.",
  'gd_plTip3T': "Build a routine",
  'gd_plTip3B': "Try to include your new habits in your daily schedule.",
  'gd_plTip4T': "Be flexible",
  'gd_plTip4B': "If you miss a day, start again the next day.",
  'gd_plTip5T': "Seek support",
  'gd_plTip5B':
      "Share your goals with family, friends or your healthcare team.",
  'gd_plExT': "Examples of goals",
  'gd_plEx1': "Food: add one serving of vegetables to lunch and dinner.",
  'gd_plEx2': "Drinks: replace sugary drinks with water or unsweetened drinks.",
  'gd_plEx3': "Activity: walk for 30 minutes, 5 days a week.",
  'gd_plEx4': "Habits: avoid alcohol or limit it to a safe level.",
  'gd_plEx5':
      "Health check: get blood tests for liver function, blood sugar, "
      "cholesterol and blood pressure as advised by your doctor.",

  // ------------------------------------------------- 5.3 Myths vs facts
  'gd_myT': "Myths vs facts",
  'gd_myIntro':
      "There are many misconceptions about liver health. Knowing the facts "
      "can help you make safer choices and take better care of your liver.",
  'gd_my1T': "Fatty liver happens only to people who drink alcohol.",
  'gd_my1B': "Many people think fatty liver is caused only by alcohol.",
  'gd_my1fT': "Fatty liver can occur in people who do not drink alcohol.",
  'gd_my1fB':
      "It is common in people who are overweight, have diabetes, high "
      "cholesterol or high blood pressure, or follow unhealthy diets.",
  'gd_my2T': "If I feel fine, my liver must be healthy.",
  'gd_my2B': "Liver disease does not always cause symptoms early on.",
  'gd_my2fT': "Liver damage can be present even when you feel well.",
  'gd_my2fB':
      "Many liver conditions, including fatty liver, have no symptoms in the "
      "early stages. Regular check-ups can help detect problems early.",
  'gd_my3T': "Everyone with fatty liver will develop cirrhosis.",
  'gd_my3B':
      "People worry that fatty liver always leads to serious liver disease.",
  'gd_my3fT': "Not everyone progresses to cirrhosis.",
  'gd_my3fB':
      "Fatty liver can often be reversed, especially if the underlying "
      "causes (such as excess weight, diabetes or heavy alcohol use) are "
      "addressed early.",
  'gd_my4T': "Only people with obesity develop fatty liver.",
  'gd_my4B': "Some believe fatty liver only affects people who are overweight.",
  'gd_my4fT': "People with normal weight can also develop fatty liver.",
  'gd_my4fB':
      "It can occur in people with normal weight, including those with "
      "diabetes, high cholesterol, a poor diet or a family history.",
  'gd_my5T': "A “detox” or herbal remedy can clean my liver.",
  'gd_my5B': "Many products claim to “detox” or cure liver problems.",
  'gd_my5fT': "There is no proven detox that cleans the liver.",
  'gd_my5fB':
      "The liver already removes harmful substances from the body. Some "
      "unregulated supplements can actually harm the liver.",
  'gd_my6T': "Exercise only helps if I lose a lot of weight.",
  'gd_my6B': "People think exercise is only useful for big weight loss.",
  'gd_my6fT':
      "Physical activity benefits the liver even without major weight loss.",
  'gd_my6fB':
      "Regular activity can reduce liver fat, improve insulin sensitivity, "
      "lower cholesterol and support overall liver health, even with small "
      "changes in weight.",
  'gd_myKey':
      "Make informed choices based on facts, not myths. If you are "
      "concerned about your liver health, talk to your doctor for "
      "personalised advice.",

  // ------------------------------------------------------------ 5.4 FAQ
  'gd_fqT': "Frequently asked questions",
  'gd_fqIntro':
      "Answers to some common questions about fatty liver and liver health. "
      "If you have any other questions, please talk to your doctor or "
      "healthcare provider.",
  'gd_fqC1T': "Can children get fatty liver?",
  'gd_fqC1B':
      "Yes. Fatty liver can also occur in children, especially those who are "
      "overweight, have unhealthy eating habits, or have conditions like "
      "diabetes. Early detection and healthy habits can help.",
  'gd_fqC2T': "Should a child follow a weight-loss diet?",
  'gd_fqC2B':
      "No. Children should not follow restrictive weight-loss diets. The "
      "focus should be on healthy growth, balanced eating and regular "
      "physical activity, with guidance from a healthcare provider.",
  'gd_fqC3T': "When is a pediatric specialist needed?",
  'gd_fqC3B':
      "A pediatric (child) specialist is needed if a child has persistent "
      "liver test abnormalities, suspected fatty liver, other liver "
      "conditions, or additional concerns such as obesity, diabetes or "
      "abnormal growth.",
  'gd_fqA1T': "Can fatty liver improve?",
  'gd_fqA1B':
      "Yes. In the early stages (fatty liver), it can often improve or even "
      "be reversed with lifestyle changes such as healthy eating, regular "
      "physical activity, weight management and avoiding alcohol.",
  'gd_fqA2T': "Do I need medicines?",
  'gd_fqA2B':
      "Not always. Many people can improve with lifestyle changes alone. "
      "Medicines may be advised for selected patients, such as those with "
      "MASH or certain associated conditions (e.g., diabetes, high "
      "cholesterol).",
  'gd_fqA3T': "How often should I be checked?",
  'gd_fqA3B':
      "This depends on your individual risk factors and existing "
      "conditions. Your doctor may suggest regular liver tests (liver "
      "function tests) and sometimes an ultrasound to monitor your liver "
      "health.",
  'gd_fqO1T': "Can I exercise safely?",
  'gd_fqO1B':
      "Yes. In most cases, regular, safe physical activity (e.g., walking, "
      "cycling or light strength exercises) is beneficial, even in older "
      "adults. Choose activities appropriate for your fitness level and "
      "health conditions.",
  'gd_fqO2T': "Can medicines affect my liver?",
  'gd_fqO2B':
      "Yes. Some medicines can affect the liver, especially when used long "
      "term or in higher doses. Always take medicines as prescribed and "
      "tell your doctor about all your medicines, including "
      "over-the-counter products.",
  'gd_fqO3T': "Does treatment change with age?",
  'gd_fqO3B':
      "Yes. Treatment decisions are individualized. In older adults, choices "
      "take into account other health conditions, current medicines, organ "
      "function (such as kidney and liver function) and overall "
      "tolerability.",
  'gd_fqNoteT':
      "These answers are general; individual medical advice may differ.",
  'gd_fqNoteB':
      "Always talk to your doctor or healthcare provider for advice that is "
      "right for your age, health condition and personal circumstances.",

  // ------------------------------------------- 5.5 Remember these 5 steps
  'gd_5sT': "Remember these 5 steps",
  'gd_5sIntro':
      "Small, consistent actions can make a big difference for your liver at "
      "any age. Keep these five simple steps in mind to protect, check and "
      "improve your liver health.",
  'gd_5s1T': "Know your risk.",
  'gd_5s1B':
      "Be aware of factors that can affect your liver, such as unhealthy "
      "weight, diabetes, high cholesterol, high blood pressure, certain "
      "medicines and a family history of liver disease.",
  'gd_5s2T': "Don't wait for symptoms.",
  'gd_5s2B':
      "Fatty liver often has no symptoms, especially in the early stages. "
      "Taking action early can prevent it from getting worse.",
  'gd_5s3T': "Get checked when needed.",
  'gd_5s3B':
      "Talk to your doctor about liver health checks, especially if you have "
      "risk factors or other health conditions.",
  'gd_5s4T': "Make healthy choices.",
  'gd_5s4B':
      "Follow a balanced eating pattern, be physically active, get enough "
      "sleep, and avoid tobacco. If you drink alcohol, try to avoid it or "
      "keep it low, as advised by your doctor.",
  'gd_5s5T': "Keep going.",
  'gd_5s5B':
      "Liver health is a long-term goal. Small, steady changes — and regular "
      "follow-up with your healthcare provider — can make a lasting "
      "difference.",
  'gd_5sInPractice': "In practice",
  'gd_5sC1': "Choose healthy lunchbox options.",
  'gd_5sC2': "Be active (e.g., play, cycle, sport).",
  'gd_5sC3': "Get enough sleep for growth and well-being.",
  'gd_5sA1':
      "Choose balanced meals (e.g., more vegetables, whole grains, lean protein).",
  'gd_5sA2': "Aim for at least 30 minutes of activity most days.",
  'gd_5sA3':
      "Keep conditions like diabetes, cholesterol and blood pressure under good control.",
  'gd_5sO1':
      "Eat a nutritious, protein-rich diet (e.g., pulses, eggs, soy, dairy).",
  'gd_5sO2': "Stay active safely (e.g., walking, light exercises).",
  'gd_5sO3': "Keep regular follow-up for liver and other health conditions.",
  'gd_5sKey': "A healthier liver supports a healthier you.",

  // --------------------------------------------------- 6.1 Where to get help
  'gd_hpT': "Where to get help",
  'gd_hpIntro':
      "Most people can improve their liver health with daily lifestyle "
      "changes. However, seek professional support if you are at higher "
      "risk, have ongoing concerns, or are advised to do so after a health "
      "check.",
  'gd_hpWhenT':
      "It is a good time to seek professional support if you or your family "
      "member:",
  'gd_hpWhen1':
      "Have risk factors such as overweight/obesity, diabetes, high "
      "cholesterol or high blood pressure.",
  'gd_hpWhen2':
      "Have abnormal liver test results, an ultrasound showing fatty liver, "
      "or other ongoing liver concerns.",
  'gd_hpWhen3':
      "Are unsure about the best plan for food, activity, medicines or "
      "follow-up.",
  'gd_hpC':
      "See a pediatrician or a pediatric gastroenterology/hepatology service "
      "(for liver-related care in children).",
  'gd_hpA':
      "See a primary-care physician, gastroenterologist or hepatologist (for "
      "assessment, advice and ongoing care).",
  'gd_hpO':
      "See a primary-care physician or a relevant specialist (e.g., "
      "gastroenterologist or hepatologist), with a medication review as "
      "needed (to check for possible effects on the liver).",
  'gd_hpKey': "Your liver works for you every day. Take care of it.",

  // ------------------------------------------------------ 6.2 References
  'gd_rfT': "References",
  'gd_rf1':
      "Indian National Association for the Study of the Liver (INASL). "
      "Clinical Practice Guidelines on Non-Alcoholic Fatty Liver Disease "
      "(NAFLD/MASLD). Latest edition. www.inasl.in",
  'gd_rf2':
      "European Association for the Study of the Liver (EASL). EASL Clinical "
      "Practice Guidelines on the management of metabolic dysfunction-"
      "associated steatotic liver disease (MASLD). J Hepatol. "
      "2024;81(3):492–542.",
  'gd_rf3':
      "American Association for the Study of Liver Diseases (AASLD). "
      "Practice Guidance on the clinical assessment and management of "
      "metabolic dysfunction-associated steatotic liver disease (MASLD). "
      "Hepatology. 2023;77(5):1797–1835.",
  'gd_rf4':
      "World Health Organization (WHO). Healthy diet. www.who.int/health-topics/healthy-diet",
  'gd_rf5':
      "World Health Organization (WHO). Physical activity. "
      "www.who.int/health-topics/physical-activity",
  'gd_rf6':
      "Selected peer-reviewed articles on fatty liver, lifestyle "
      "interventions and liver health in children, adults and older adults.",
};
