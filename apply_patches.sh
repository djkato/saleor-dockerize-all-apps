#!/bin/bash

CURR_PWD="$(pwd)"

app_paths=(
	"apps"
	"saleor-app-abandoned-checkouts"
	"saleor-app-payment-authorize.net"
	"saleor-app-payment-klarna"
	"saleor-app-payment-stripe"
)

echo "creating patches for all repos"

for i in ${app_paths[*]}; do
	cd "./all_apps/$i"
	echo $(pwd)
	git apply "$CURR_PWD/patches/$i.patch"
	# pnpm i
	# pnpm i ioredis
	cd "$CURR_PWD"
done
