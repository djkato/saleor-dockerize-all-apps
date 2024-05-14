FROM node:18-alpine AS base

FROM base AS builder
RUN apk add --no-cache libc6-compat
RUN apk update
# Set working directory
WORKDIR /app
RUN npm i -g turbo pnpm
COPY . .

ARG TARGET_APP
# Generate a partial monorepo with a pruned lockfile for a target workspace.
RUN turbo prune "app-$TARGET_APP" --docker 
# Assuming "TARGET_APP" is the name entered in the project's package.json: { name: "TARGET_APP" }

# Add lockfile and package.json's of isolated subworkspace
FROM base AS installer

ARG TARGET_APP
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
RUN turbo run build --filter="app-$TARGET_APP"...


FROM base AS runner

ARG TARGET_APP
WORKDIR /app

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

COPY --from=installer /app/apps/$TARGET_APP/next.config.js .
COPY --from=installer /app/apps/$TARGET_APP/package.json .

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /app/apps/$TARGET_APP/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /app/apps/$TARGET_APP/.next/static ./apps/$TARGET_APP/.next/static
COPY --from=installer --chown=nextjs:nodejs /app/apps/$TARGET_APP/public ./apps/$TARGET_APP/public
COPY --from=installer --chown=nextjs:nodejs /app/node_modules ./node_modules
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/next/dist/server/future/route-modules ./node_modules/next/dist/server/future/route-modules
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/next/dist/compiled/next-server ./node_modules/next/dist/compiled/next-server
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/next/dist/compiled/next-server ./node_modules/next/dist/compiled/next-server
# COPY --from=installer --chown=nextjs:nodejs /app/node_modules/react/jsx-runtime ./node_modules/react/jsx-runtime

WORKDIR /app/apps/$TARGET_APP
CMD node server.js
