#!/bin/bash

REDIS_APL_PATH="./changes/snippets/redis_apl.ts"
CURR_PWD="$(pwd)"

app_paths=(
	"apps/apps/cms-v2"
	"apps/apps/avatax"
	"apps/apps/crm"
	"apps/apps/data-importer"
	"apps/apps/emails-and-messages"
	"apps/apps/invoices"
	"apps/apps/klaviyo"
	"apps/apps/products-feed"
	"apps/apps/search"
	"apps/apps/segment"
	"apps/apps/slack"
	"apps/apps/taxjar"
	"saleor-app-abandoned-checkouts"
	"saleor-app-payment-authorize.net"
	"saleor-app-payment-klarna"
	"saleor-app-payment-stripe"
)

redis_apl_target_paths=(
	"apps/apps/cms-v2/src"
	"apps/apps/avatax"
	"apps/apps/crm/src"
	"apps/apps/data-importer"
	"apps/apps/emails-and-messages/src"
	"apps/apps/invoices/src"
	"apps/apps/klaviyo"
	"apps/apps/products-feed/src"
	"apps/apps/search"
	"apps/apps/segment/src"
	"apps/apps/slack/src/lib"
	"apps/apps/taxjar"
	"saleor-app-abandoned-checkouts"
	"saleor-app-payment-authorize.net/src"
	"saleor-app-payment-klarna/src"
	"saleor-app-payment-stripe/src"
)

echo "copying redis_apls..."

for i in ${redis_apl_target_paths[*]}; do
	echo "copying redis_apl.ts to ./all_apps/$i"
	cp -f "$REDIS_APL_PATH" "./all_apps/$i"
	# always copies next to saleor-app.ts, so let's add some files to that file too
	rg -l "switch \(process.env.APL\)" -t ts
done

for i in ${app_paths[*]}; do
	cd "./all_apps/$i"
	echo $(pwd)
	pnpm i
	pnpm i ioredis
	cd "$CURR_PWD"
done
