<a href='https://ko-fi.com/A0A8Q3SVZ' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi4.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
# Automatic Dockerization of official Saleor app

In this repo I created bash scripts and modifications to Saleor that allow for building docker images with a few commands, while staying uptodate with upstream saleor repos.

Current apps in repo:
- saleor/apps
  - avatax
  - cms-v2
  - crm
  - data-importer
  - emails-and-messages
  - invoices
  - klaviyo
  - products-feed
  - search
  - segment
  - slack
  - smtp
  - taxjar
- saelor/abandoned-checkouts
- saelor/payment-stripe
- saelor/payment-klarna
- saelor/payment-authorize.net

## How to use
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
