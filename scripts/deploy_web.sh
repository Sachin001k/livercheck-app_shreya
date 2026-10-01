#!/bin/bash
# Builds the web app and deploys it to Vercel.
#
#   ./scripts/deploy_web.sh            → production (your public link)
#   ./scripts/deploy_web.sh --preview  → a separate preview link for testing
#
# First run: Vercel asks a few setup questions (scope, project name —
# use "livrcheck"). After that the project link is remembered in
# .vercel-web/ (git-ignored), because `flutter build web` wipes build/web.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f env.json ]; then
  echo "env.json is missing (Supabase keys). See env.example.json." >&2
  exit 1
fi

flutter build web --release --dart-define-from-file=env.json

if [ -d .vercel-web ]; then
  cp -R .vercel-web build/web/.vercel
fi

cd build/web
# Never upload secrets or build metadata with the static site.
rm -f .env .env.local .env.*.local
printf '.env*\n.vercel\n.gitignore\n.last_build_id\n' > .vercelignore
if [ "${1:-}" = "--preview" ]; then
  vercel deploy
else
  vercel deploy --prod
fi

rm -rf ../../.vercel-web
cp -R .vercel ../../.vercel-web
