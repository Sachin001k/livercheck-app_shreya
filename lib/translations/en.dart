/// English text — the source for every other language.
///
/// The key on the left is used by the code; only edit the text on the right.
/// Adding a new key here? Add it to the other language files too (any
/// missing key falls back to this English text).
const Map<String, String> en = {
  'appTitle': 'LivrCheck',
  'appSubtitle': 'Know your liver fibrosis risk from a routine blood test',
  'introHeading': 'What is this app?',
  'introBody':
      'LivrCheck calculates your FIB-4 score, a clinically validated '
      'estimate of liver fibrosis (scarring) risk, using four numbers '
      'from a standard blood test: your age, AST, ALT, and platelet '
      'count. These are part of a routine Liver Function Test (LFT) and '
      'Complete Blood Count (CBC).',
  'notAlcoholHeading': 'This is not about alcohol',
  'notAlcoholBody':
      'Non-Alcoholic Fatty Liver Disease (NAFLD) is caused by diet, '
      'obesity, diabetes, and sedentary lifestyle — not alcohol. Many '
      'Indian families assume a fatty liver diagnosis means an alcohol '
      'problem, which can delay proper diagnosis and care by years.',
  'formHeading': 'Enter your blood test values',
  'ageLabel': 'Age (years)',
  'astLabel': 'AST (U/L)',
  'astHelp': 'Sometimes labeled SGOT on your report',
  'altLabel': 'ALT (U/L)',
  'altHelp': 'Sometimes labeled SGPT on your report',
  'plateletsLabel': 'Platelet count (×10⁹/L)',
  'plateletsHelp':
      'If your report shows lakhs/cmm (e.g. 2.5 lakh/cmm), multiply by '
      '100 to get ×10⁹/L (e.g. 2.5 → 250).',
  'contextHeading': 'A few more questions (optional)',
  'heightLabel': 'Height (cm)',
  'weightLabel': 'Weight (kg)',
  'diabetesLabel': 'Do you have diabetes or pre-diabetes?',
  'familyHistoryLabel':
      'Family history of fatty liver, cirrhosis, or metabolic syndrome?',
  'yes': 'Yes',
  'no': 'No',
  'notSure': 'Not sure',
  'calculateButton': 'Calculate my FIB-4 score',
  'resultsHeading': 'Your Results',
  'scoreLabel': 'FIB-4 Score',
  'tierLow': 'Low Risk',
  'tierIntermediate': 'Intermediate Risk',
  'tierHigh': 'High Risk',
  'tierLowExplanation':
      'Your score suggests a low likelihood of advanced liver fibrosis '
      '(negative predictive value ~90.7%).',
  'tierIntermediateExplanation':
      'Your score is in an intermediate zone. This does not confirm '
      'fibrosis, but it cannot be ruled out either. Further evaluation '
      'is recommended.',
  'tierHighExplanation':
      'Your score is above the high-risk threshold (97% specificity for '
      'advanced fibrosis). This result should be taken seriously.',
  'actionHeading': 'What to do next',
  'actionLow':
      'Lifestyle counselling (diet, exercise, weight management). Repeat '
      'this test in 1–2 years.',
  'actionIntermediate':
      'Share this result with your GP or family doctor. A FibroScan may '
      'be recommended.',
  'actionHigh':
      'Please see a hepatologist or gastroenterologist soon. Bring this '
      'result and your original blood report.',
  'bmiHeading': 'Your BMI context',
  'bmiUnderweight': 'Underweight',
  'bmiNormal': 'Normal range',
  'bmiOverweight': 'Overweight',
  'bmiObese': 'Obese',
  'bmiNote':
      'Obesity and a high BMI are among the strongest known risk factors '
      'for NAFLD, independent of your FIB-4 score.',
  'diabetesNote':
      'Diabetes and pre-diabetes significantly increase both the risk of '
      'NAFLD and its progression. Regular monitoring matters.',
  'familyHistoryNote':
      'A family history of fatty liver or metabolic syndrome increases '
      'your own risk — worth mentioning to your doctor.',
  'ageWarning':
      '⚠️ FIB-4 is validated primarily for adults aged 35–65. '
      'Outside this range the score is less reliable. Please discuss '
      'this result with a doctor.',
  'disclaimerHeading': 'Important — please read',
  'disclaimerBody':
      'This is a screening tool, not a diagnosis. FIB-4 is a statistical '
      'estimate based on published research. It does not measure liver '
      'fat (steatosis) — only fibrosis risk. Intermediate or High risk '
      'results require confirmation by a qualified medical professional. '
      'When in doubt, consult a doctor.',
  'shareHeading': 'Share this with your family',
  'shareBody':
      'NAFLD often runs in families — share LivrCheck with a relative.',
  'shareButton': 'Share on WhatsApp',
  'shareMessage':
      'I just checked my liver fibrosis risk using LivrCheck, a free app '
      'built from clinically validated research. Check yours too:',
  'footerNote':
      'LivrCheck is a free, open-source, non-commercial screening tool.',
  'validationError': 'Please enter valid, positive numbers for all fields.',
  'languageLabel': 'Language',
  'loginTitle': 'Login',
  'usernameLabel': 'Username',
  'usernameHint': 'Enter User ID or Email',
  'passwordLabel': 'Password',
  'passwordHint': 'Enter Password',
  'forgotPassword': 'Forgot Password',
  'rememberMe': 'Remember Me',
  'signIn': 'Sign In',
  'or': 'or',
  'loginRequiredError': 'Please enter your username and password.',
  'comingSoon': 'Coming soon',

  // ── Login & sign-up ──
  'loginSubtitle': 'Sign in to track your liver health',
  'createAccountTitle': 'Create account',
  'tabEmail': 'Email',
  'tabPhone': 'Phone',
  'fullNameLabel': 'Full name',
  'fullNameHint': 'Enter your name',
  'emailLabel': 'Email',
  'emailHint': 'you@gmail.com',
  'createAccountButton': 'Create account',
  'noAccountPrompt': 'New to LivrCheck?',
  'createAccountLink': 'Create an account',
  'haveAccountPrompt': 'Already have an account?',
  'signInLink': 'Sign in',
  'phoneLabel': 'Mobile number',
  'phoneHint': '98765 43210',
  'sendOtp': 'Send OTP',
  'otpLabel': 'OTP code',
  'otpHint': '6-digit code',
  'verifyOtp': 'Verify & continue',
  'otpSentTo': 'We sent a code to',
  'changeNumber': 'Change number',
  'resendOtp': 'Resend code',
  'continueWithGoogle': 'Continue with Google',
  'emailRequiredError': 'Please enter a valid email address.',
  'passwordLengthError': 'Password must be at least 6 characters.',
  'nameRequiredError': 'Please enter your name.',
  'phoneRequiredError': 'Please enter a valid 10-digit mobile number.',
  'otpRequiredError': 'Please enter the 6-digit code.',
  'checkEmailConfirm':
      'Account created! Check your email and tap the confirmation link, '
      'then sign in.',
  'resetEmailSent': 'Password reset link sent. Check your email.',
  'forgotPasswordNeedsEmail':
      'Enter your email above first, then tap Forgot Password.',
  'genericError': 'Something went wrong. Please try again.',
  'setNewPasswordTitle': 'Set a new password',
  'passwordUpdated': 'Password updated.',
  'save': 'Save',
  'cancel': 'Cancel',

  // ── Profile setup ──
  'setupTitle': 'Tell us about yourself',
  'setupSubtitle':
      'This helps personalise your results. You can change it any time.',
  'genderLabel': 'Gender',
  'genderMale': 'Male',
  'genderFemale': 'Female',
  'genderOther': 'Other',
  'genderPreferNot': 'Prefer not to say',
  'ageRequiredError': 'Please enter a valid age (1–120).',
  'continueButton': 'Continue',
  'loadProfileError': 'Could not load your profile.',
  'retry': 'Retry',

  // ── Navigation ──
  'navHome': 'Home',
  'navCheck': 'Check',
  'navProfile': 'Profile',

  // ── Home ──
  'greeting': 'Hello',
  'homeCheckCardTitle': 'Check your liver risk',
  'homeCheckCardBody':
      'A 2-minute check of your liver, heart, kidneys and blood sugar.',
  'startCheck': 'Start check',
  'foodSectionTitle': 'Food for a healthy liver',
  'eatMore': 'Eat more',
  'limitFood': 'Limit',
  'tipsSectionTitle': 'Health suggestions',
  'faqSectionTitle': 'Fatty liver FAQ',

  // ── Profile ──
  'dayStreak': 'day streak',
  'longestStreak': 'Longest',
  'daysUnit': 'days',
  'streakHint': 'Open LivrCheck every day to keep your streak going.',
  'latestFib4': 'Latest FIB-4',
  'surveyScore': 'Survey score',
  'checksDone': 'Checks done',
  'bmiLabel': 'BMI',
  'noDataYet': 'No data yet',
  'sampleTag': 'Sample',
  'activityTitle': 'Your activity',
  'badgesTitle': 'Achievements',
  'badgeFirstCheck': 'First check',
  'badgeStreak3': '3-day streak',
  'badgeStreak7': '7-day streak',
  'badgeFiveChecks': '5 checks',
  'badgeProfile': 'Profile complete',
  'badgeSurvey': 'Survey done',
  'recentChecks': 'Recent checks',
  'noChecksYet': 'No checks yet — try the Check tab.',
  'editProfile': 'Edit profile',
  'signOut': 'Sign out',
  'memberSince': 'Member since',

  // ── FIB-4 check ──
  'savedToHistory': 'Result saved to your profile.',
  'saveFailed': 'Could not save this result.',

  // ── Food details pop-up ──
  'nutritionTitle': 'Nutrition',
  'perServing': 'per',
  'kcalUnit': 'kcal',
  'dailyAmountTitle': 'How much is safe per day',
  'ageChildren': 'Children',
  'ageAdults': 'Adults',
  'ageElders': 'Elders',
  'benefitsTitle': 'Helps keep away',
  'overconsumptionTitle': 'Too much can affect',
  'precautionsTitle': 'Precautions',
  'swapsTitle': 'Healthier swaps',
  'detailsComingSoon': 'Full details for this food are coming soon.',
  'sampleContentNote':
      'Sample content for guidance only. Check with your doctor or dietitian, '
      'especially if you have a medical condition.',
  'close': 'Close',
  'viewDetails': 'View details',

  // ── Welcome slides ──
  'welcomeSkip': 'Skip',
  'welcomeNext': 'Next',
  'welcomeStart': 'Get started',
  'welcome1Title': 'Know your liver',
  'welcome1Body':
      'A free 2-minute check of your liver, heart, kidneys, lungs and blood '
      'sugar. No blood report needed.',
  'welcome2Title': 'Build healthy days',
  'welcome2Body':
      'Check in every day and log water, food, exercise and sleep against '
      'goals made just for you.',
  'welcome3Title': 'Earn coins as you go',
  'welcome3Body':
      '+1 for checking in, +10 for your daily log and +20 for a 90+ day. '
      'Keep your streak alive!',
  'welcome4Title': 'Your data stays yours',
  'welcome4Body':
      'Only you can see your health information, and we never sell it. '
      'LivrCheck is a screening tool, not a diagnosis.',

  // ── Consent ──
  'consentTitle': 'Before we start',
  'consentIntro': 'Please read how LivrCheck uses your information.',
  'consentCollectTitle': 'What we store',
  'consentCollectBody':
      'Your profile (name, age, height, weight), health check answers and '
      'results, and your daily logs.',
  'consentWhyTitle': 'Why',
  'consentWhyBody':
      'Only to show your results, track your progress and personalise your '
      'goals.',
  'consentWhoTitle': 'Who can see it',
  'consentWhoBody':
      'Only you. It is stored securely and is never sold or shared with '
      'advertisers.',
  'consentRightsTitle': 'Your choices',
  'consentRightsBody':
      'You can edit your profile any time and ask us to delete your account '
      'and all your data.',
  'consentNotDiagnosis':
      'I understand LivrCheck is a screening tool and does not replace a '
      'doctor',
  'consentStore':
      'I agree to LivrCheck storing my health information as described',
  'consentReadPolicy': 'Read the full privacy policy',
  'consentAgree': 'I agree, continue',
  'consentSaveError': 'Could not save your consent.',
  'privacyTitle': 'Privacy policy',
};
