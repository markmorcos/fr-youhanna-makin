# Use official Ruby image with slim variant for smaller size
FROM ruby:3.2-slim

# Install essential packages
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev libyaml-dev nodejs curl git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock to install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy the rest of the application
COPY . .

# Precompile assets and run DB migrations (optional for production images)
# These steps can also be handled in the entrypoint or CI/CD pipeline
RUN RAILS_ENV=production \
    SECRET_KEY_BASE_DUMMY=1 \
    RAILS_RELATIVE_URL_ROOT=/fr-youhanna-makin \
    bundle exec rake assets:precompile

# Set environment variables
ENV RAILS_ENV=production
ENV RACK_ENV=production

# Use a non-root user (optional but recommended)
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Expose the port Puma will run on
EXPOSE 3000

# Start the Rails server using Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
