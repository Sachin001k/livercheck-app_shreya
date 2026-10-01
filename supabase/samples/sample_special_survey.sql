-- Sample special survey — NOT a migration. Run it in the SQL Editor when
-- you want a test survey to appear on the Home page and the Rewards tab.
-- It stays open for 30 days and pays 50 coins once per user.
--
-- Question format (the `questions` JSON array), one object per question:
--   id       unique key for the answer, e.g. "water"
--   type     "choice" (pick one) · "multi" (pick several) · "scale" (1–5) · "text"
--   title    the question shown to the user
--   options  for choice/multi: [{ "v": "value", "label": "Shown text", "emoji": "💧" }]
--
-- To remove it later:  delete from public.special_surveys where title = 'Water habits check';

insert into public.special_surveys (title, description, reward_coins, ends_at, questions)
values (
  'Water habits check',
  'Tell us how you drink water during the day. Takes 1 minute.',
  50,
  now() + interval '30 days',
  '[
    {"id": "glasses", "type": "choice", "title": "How many glasses of water do you drink on a normal day?",
     "options": [
       {"v": "lt4",  "label": "Fewer than 4", "emoji": "🥤"},
       {"v": "4to7", "label": "4 to 7",       "emoji": "💧"},
       {"v": "8plus","label": "8 or more",    "emoji": "🌊"}
     ]},
    {"id": "when", "type": "multi", "title": "When do you usually drink water?",
     "options": [
       {"v": "morning", "label": "After waking up", "emoji": "🌅"},
       {"v": "meals",   "label": "With meals",      "emoji": "🍽️"},
       {"v": "thirsty", "label": "Only when thirsty", "emoji": "😮‍💨"},
       {"v": "bottle",  "label": "I carry a bottle", "emoji": "🧴"}
     ]},
    {"id": "energy", "type": "scale", "title": "How energetic do you feel most afternoons? (1 = very tired, 5 = full of energy)"},
    {"id": "notes", "type": "text", "title": "Anything that stops you drinking more water?"}
  ]'::jsonb
);
