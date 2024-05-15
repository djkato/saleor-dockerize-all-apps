<a href='https://ko-fi.com/A0A8Q3SVZ' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi4.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
# Automatic Dockerization of official Saleor app

In this repo I created bash scripts and modifications to Saleor that allow for building docker images with a few commands, while staying uptodate with upstream saleor repos.

Current apps in repo:
- saleor/apps
  - avatax
  - cms-v2¹
  - crm¹
  - data-importer
  - emails-and-messages
  - invoices
  - klaviyo
  - products-feed
  - search
  - segment¹
  - slack¹
  - smtp¹
  - taxjar
- saelor/abandoned-checkouts
- saelor/payment-stripe
- saelor/payment-klarna
- saelor/payment-authorize.net¹

¹ - doesn't build yet :(, Some I am able to fix later, some prolly not

## Caveats

All apps from saleor/apps are upwards of 1.5gb in size, because of [this pnpm workspace error](https://github.com/vercel/next.js/issues/65636)

# How to use

These images include RedisAPL, and that's what I recommend to use it with. Besides that, use it like any other docker image. 
For example:

```yml
services:
  app-payment-stripe:
    image: ghcr.io/djkato/saleor-app-payment-stripe:0.4.0
    env_file:
      - stripe.env
    networks:
      - saleor-app-tier
    depends_on:
      - redis-apl
    ports:
      - 3001:3001

  redis-apl:
    image: bitnami/redis:latest
    environment:
      - ALLOW_EMPTY_PASSWORD=yes
      - DISABLE_COMMANDS=FLUSHDB,FLUSHALL,CONFIG
    ports:
      - 6380:6379
    networks:
      - saleor-app-tier
    volumes:
      - redis-apl:/bitnami/redis/data

volumes:
  redis-apl:
    driver: local
    driver_opts:
      type: none
      device: ./temp/volumes/redis/
      o: bind

networks:
  saleor-app-tier:
    driver: bridge
```

## How to build 
- `./changes.sh` - applies git patches and batch edits via rust to add RedisAPL to all apps, and allow them to build via other tweaks.
- `cargo make build-all` or `cargo make build-<Chosen app>`

if you want to push built images to a repo, change the top env `CONTAINER_PUSH_URL` to your repo, for example "ghcr.io/djkato".
Then you can do
- `cargo make push-all` or `APP=<Chosen app> cargo make push`

## Prerequisites
- cargo
- cargo-make
- linux shell (bash)
- rust stuff
- git

Thanks Saleor for providing all these apps. Shame Saleor refuses to containerize them officially. Hope this repo helps you. If it does, consider buying me a langosz (donation button on top)! 
