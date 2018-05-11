FROM starefossen/ruby-node:2-8

RUN mkdir /matreon
WORKDIR /matreon

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

COPY Gemfile /matreon/
COPY Gemfile.lock /matreon/
RUN bundle config --global frozen 1
RUN bundle install --without development test

ENV NODE_ENV production

COPY package.json /matreon/package.json
COPY yarn.lock /matreon/yarn.lock
RUN yarn install

COPY Procfile Rakefile  config.ru .babelrc .postcssrc.yml /matreon/
COPY config /matreon/config 
COPY db /matreon/db
COPY vendor /matreon/vendor
COPY app /matreon/app
COPY bin /matreon/bin
COPY lib /matreon/lib

COPY public /matreon/public
RUN rm -rf public/assets public/packs

ENV DEVISE_SECRET_KEY ${DEVISE_SECRET_KEY}
RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD bundle exec puma -C config/puma.rb
