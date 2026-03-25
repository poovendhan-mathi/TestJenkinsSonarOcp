# ============================================================
# Dockerfile — Multi-stage build for Expense Tracker
# ============================================================
# Stage 1: Build the Next.js app
# Stage 2: Run it with minimal image
# ============================================================

# --- STAGE 1: Builder ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files first (for Docker layer caching)
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci

# Copy everything else
COPY . .

# Build the Next.js app (output: "standalone")
RUN npm run build

# --- STAGE 2: Runner ---
FROM node:20-alpine AS runner

WORKDIR /app

# Don't run as root in production
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 appuser

# Copy standalone output from builder
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Set environment
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Switch to non-root user
USER appuser

EXPOSE 3000

# Start the server
CMD ["node", "server.js"]
