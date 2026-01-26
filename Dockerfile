# syntax=docker/dockerfile:1

# Ruby sürümü (.ruby-version ile uyumlu olmalı)
ARG RUBY_VERSION=3.4.8
FROM ruby:${RUBY_VERSION}

# Gerekli sistem paketleri
# Dokümandan aldık: libvips + libjemalloc2 (opsiyonel ama faydalı)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  curl \
  libvips \
  libjemalloc2 \
  && rm -rf /var/lib/apt/lists/*

# Uygulama dizini
WORKDIR /rails

# Gem'leri yükle
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Uygulama kodunu kopyala
COPY . .

# Entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Rails portu
EXPOSE 3000

# Varsayılan komut
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
