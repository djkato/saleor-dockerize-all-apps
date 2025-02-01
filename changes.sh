#!/bin/bash

CURR_PWD="$(pwd)"
REDIS_APL_PATH="$CURR_PWD/changes/snippets/redis_apl.ts"
OLD_REDIS_APL_PATH="$CURR_PWD/changes/snippets/redis_apl_old_sdk.ts"
APPS_DOCKERFILE_PATH="$CURR_PWD/apps.Dockerfile"
OTHER_DOCKERFILE_PATH="$CURR_PWD/other.Dockerfile"
DOCKERIGNORE_PATH="$CURR_PWD/.dockerignore"

app_paths=(
	"abandoned-checkouts"
	"anonymization"
	"apps/apps/avatax"
	"apps/apps/cms-v2"
	"apps/apps/klaviyo"
	"apps/apps/products-feed"
	"apps/apps/search"
	"apps/apps/segment"
	"apps/apps/smtp"
	"authorize.net"
	"checkout-complete"
	"checkout-prices"
	"crm"
	"customer-insights"
	"data-importer/apps/data-importer"
	"emails-and-messages"
	"invoices"
	"klarna"
	"sendgrid"
	"shipstation"
	"slack"
	"stripe"
	"taxjar"
)

app_paths_no_redis_apl=(
	"abandoned-checkouts"
	"anonymization"
	"authorize.net"
	"checkout-complete"
	"checkout-prices"
	"crm"
	"customer-insights"
	"data-importer/apps/data-importer"
	"emails-and-messages"
	"invoices"
	"klarna"
	"sendgrid"
	"shipstation"
	"slack"
	"stripe"
	"taxjar"
)
echo "copying Dockerfiles..."
cp -f ./apps.Dockerfile ./all_apps/apps/Dockerfile
cp -f ./other.Dockerfile ./all_apps/saleor-app-payment-stripe/Dockerfile
cp -f ./other.Dockerfile ./all_apps/saleor-app-payment-klarna/Dockerfile
cp -f ./other.Dockerfile ./all_apps/saleor-app-payment-authorize.net/Dockerfile
cp -f ./other.Dockerfile ./all_apps/saleor-app-abandoned-checkouts/Dockerfile

echo "copying dockerignores..."
cp -f ./.dockerignore ./all_apps/apps/
cp -f ./.dockerignore ./all_apps/saleor-app-payment-stripe/
cp -f ./.dockerignore ./all_apps/saleor-app-payment-klarna/
cp -f ./.dockerignore ./all_apps/saleor-app-payment-authorize.net/
cp -f ./.dockerignore ./all_apps/saleor-app-abandoned-checkouts/

echo "copying redis_apls..."
for i in ${redis_apl_target_paths[*]}; do
	echo "copying redis_apl.ts to ./all_apps/$i"
	cp -f "$REDIS_APL_PATH" "./all_apps/$i"
done

# abandoned-checkouts Uses old sdk
cp -f "$OLD_REDIS_APL_PATH" "./all_apps/saleor-app-abandoned-checkouts/redis_apl.ts"

# mass patch apps to use redis_apl and build in standalone
find ./all_apps/apps -name "saleor-app.ts" -exec cargo run --package modify-saleor-app -- {} \; >/dev/null 2>&1
echo "pached all_apps/apps/**/saleor-app.ts"

find ./all_apps/apps -name "next.config.js" -exec cargo run --package modify-next-config -- {} \; >/dev/null 2>&1
echo "pached all_apps/apps/**/next.config.js"

find ./all_apps/saleor-app-abandoned-checkouts -name "saleor-app.ts" -exec cargo run --package modify-saleor-app -- {} \; >/dev/null 2>&1
echo "pached all_apps/saleor-app-abandoned-checkouts/**/saleor-app.ts"

find ./all_apps/apps/apps -name "turbo.json" -exec cargo run --package modify-turbo-json -- {} \; >/dev/null 2>&1
echo "pached all_apps/**/turbo.json"

cd ./all_apps/
for i in "saleor-app-payment-klarna" "saleor-app-payment-stripe" "saleor-app-payment-authorize.net"; do
	cd "$i"
	git apply "$CURR_PWD/patches/$i/env.mjs.patch"
	git apply "$CURR_PWD/patches/$i/saleor-app.ts.patch"
	git apply "$CURR_PWD/patches/$i/next.config.mjs.patch"
	echo "patched $i"
	cd ..
done
cd "saleor-app-abandoned-checkouts"
git apply "$CURR_PWD/patches/saleor-app-abandoned-checkouts/next.config.js.patch"
cd "$CURR_PWD"

for i in ${app_paths[*]}; do
	cd "./all_apps/$i"
	# pnpm i
	pnpm i ioredis >/dev/null
	echo "installed ioredis for $i"
	cd "$CURR_PWD"
done

# Individual patches
cd ./all_apps/apps
git apply "$CURR_PWD/patches/apps/slack/env.d.ts.patch"
echo "patched apps/slacks env.d.ts"
cd "$CURR_PWD"
