#!/bin/bash

REDIS_APL_PATH="./changes/snippets/redis_apl.ts"
CURR_PWD="$(pwd)"

app_paths=(
	"apps"
	"saleor-app-abandoned-checkouts"
	"saleor-app-payment-authorize.net"
	"saleor-app-payment-klarna"
	"saleor-app-payment-stripe"
)

echo "creating patches for all repos"

# for i in ${redis_apl_target_paths[*]}; do
# 	echo "copying redis_apl.ts to ./all_apps/$i"
# 	cp -f "$REDIS_APL_PATH" "./all_apps/$i"
# 	# always copies next to saleor-app.ts, so let's add some files to that file too
# 	# find . -name "saleor-app.ts" -exec sed "/switch/ r $CURR_PWD/changes/case_redisapl.ts" {} \;
# done
#
for i in ${app_paths[*]}; do
	cd "./all_apps/$i"
	echo "creating patch for $(pwd)"
	git diff >"$CURR_PWD/patches/$i.patch"
	# pnpm i
	# pnpm i ioredis
	cd "$CURR_PWD"
done
