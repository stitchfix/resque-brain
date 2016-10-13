FROM ruby:2.3.1-alpine

RUN apk add --update build-base nodejs tzdata postgresql-dev linux-headers git

COPY . /app
WORKDIR /app

VOLUME /app/log

EXPOSE 3000

RUN gem install bundler && \
    bundle install --without development:test --system && \
    RAILS_ENV=production bundle exec rake assets:precompile

CMD ["sh", "-c", "exec bundle exec puma -C config/puma.rb"]
