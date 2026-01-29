# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.8
FROM ruby:${RUBY_VERSION}

# Gerekli sistem paketleri
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  curl \
  libvips \
  libjemalloc2 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /rails

# Gem'leri yükle
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Uygulama kodunu kopyala
COPY . .

# Entrypoint (Rails'in standart docker-entrypoint'i varsa kalsın)
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000

# ÖNEMLİ: Server başlamadan önce stale PID temizle
CMD ["bash", "-lc", "rm -f /rails/tmp/pids/server.pid && exec bin/rails server -b 0.0.0.0 -p 3000"]
