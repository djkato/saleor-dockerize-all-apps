FROM node:18-alpine AS base

FROM base AS builder
RUN apk add --no-cache libc6-compat
RUN apk update
# Set working directory
WORKDIR /app
RUN npm i -g turbo pnpm
COPY . .

ARG APP_DIR
ARG APP_NAME
# Generate a partial monorepo with a pruned lockfile for a target workspace.
RUN turbo prune "$APP_NAME" --docker 
# Assuming "TARGET_APP" is the name entered in the project's package.json: { name: "TARGET_APP" }

# Add lockfile and package.json's of isolated subworkspace
FROM base AS installer

ARG APP_DIR
ARG APP_NAME

RUN apk add --no-cache libc6-compat
RUN apk update
WORKDIR /app

# First install the dependencies (as they change less often)
COPY .gitignore .gitignore
COPY --from=builder /app/out/json/ .
RUN npm i -g turbo pnpm
RUN pnpm i

# Build the project
COPY --from=builder /app/out/full/ .
RUN HOSTNAME="0.0.0.0" turbo run build --filter="$APP_NAME"...


FROM base AS runner

ARG APP_DIR
ARG APP_NAME
WORKDIR /app

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

COPY --from=installer /app/apps/$APP_DIR/next.config.js .
COPY --from=installer /app/apps/$APP_DIR/package.json .

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /app/apps/$APP_DIR/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /app/apps/$APP_DIR/.next/static ./apps/$APP_DIR/.next/static
COPY --from=installer --chown=nextjs:nodejs /app/apps/$APP_DIR/public ./apps/$APP_DIR/public
COPY --from=installer --chown=nextjs:nodejs /app/node_modules ./node_modules
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/next/dist/server/future/route-modules ./node_modules/next/dist/server/future/route-modules
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/next/dist/compiled/next-server ./node_modules/next/dist/compiled/next-server
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/next/dist/compiled/next-server ./node_modules/next/dist/compiled/next-server
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/react/jsx-runtime ./node_modules/react/jsx-runtime

WORKDIR /app/apps/$APP_DIR
CMD HOSTNAME="0.0.0.0" node server.js
ARG SERVICE
ARG TITLE
ARG DESC
ARG URL
ARG SOURCE
ARG AUTHORS
ARG LICENSES
LABEL service="$SERVICE"\
  src="saleor-dockerize-all-apps"\
  org.opencontainers.image.title="$TITLE"\
  org.opencontainers.image.description="$DESC" \
  org.opencontainers.image.url="$URL"\
  org.opencontainers.image.source="$SOURCE"\
  org.opencontainers.image.authors="$AUTHORS"\
  org.opencontainers.image.licenses="$LICENSES"
