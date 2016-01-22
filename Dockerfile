FROM ruby:2.0

RUN apt-get update -qq && apt-get install -y build-essential libxml2-dev libxslt1-dev libpq-dev libqt4-webkit libqt4-dev xvfb freetds-common freetds-dev tdsodbc freetds-bin nodejs git-core curl zlib1g-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libsqlite3-dev apt-transport-https ca-certificates

RUN useradd resque-brain
RUN mkdir -p /var/log/www/
RUN ln -s /dev/stdout /var/log/www/resque-brain.application.log
RUN ln -s /dev/stdout /var/log/www/resque-brain.stderr.log
RUN ln -s /dev/stdout /var/log/www/resque-brain.stdout.log


RUN mkdir -p /var/www/resque-brain/current/
WORKDIR /var/www/resque-brain/current/

ADD . /var/www/resque-brain/current/
RUN mkdir /var/www/resque-brain/current/tmp
RUN mkdir /var/www/resque-brain/current/tmp/cache
RUN mkdir /var/www/resque-brain/current/tmp/pids
RUN mkdir /var/www/resque-brain/current/tmp/sessions
RUN mkdir /var/www/resque-brain/current/tmp/sockets
RUN cd /var/www/resque-brain/current/ ; bundle install
RUN chown -R resque-brain /var/www/resque-brain/current

EXPOSE 8080

CMD cd /var/www/resque-brain/current/ ; /usr/local/bundle/bin/bundle exec /usr/local/bundle/bin/unicorn_rails -c $RAILS_ROOT/config/unicorn.rb