# syntax=docker/dockerfile:1

# ---- Stage 1: build the React frontend ----
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# ---- Stage 2: Python backend, serving the built frontend ----
FROM python:3.11-slim AS backend

# psycopg2-binary ships its own libpq, so no extra system packages are needed
# for the DB driver. libpq-dev/gcc are only pulled in if that ever changes.
WORKDIR /app

COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r backend/requirements.txt

COPY backend/ backend/
COPY --from=frontend-builder /app/frontend/build frontend/build

# Bundled frontend build should be used as-is, not re-fetched from the
# upstream template repo's GitHub releases on every container start.
ENV SKIP_FRONTEND_FETCH=true
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

WORKDIR /app/backend
EXPOSE 5000

# Run DB migrations + seed (skipped automatically when POSTGRES_URI points at
# RDS, see manage.py / Config.is_rds), then start the app with gunicorn.
CMD ["sh", "-c", "python manage.py && gunicorn -b 0.0.0.0:5000 -w 2 'app:create_app()'"]
