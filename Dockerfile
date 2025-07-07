FROM ruby:3.1-slim

WORKDIR /app

# Install dependencies in single layer
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libsqlite3-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy and install gems first for better caching
COPY Gemfile ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets
RUN RAILS_ENV=production bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]