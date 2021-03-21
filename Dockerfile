FROM ruby:2.7.1

WORKDIR /home/app

ENV PORT 3000

EXPOSE $PORT

COPY ./entrypoint.sh /usr/local/bin/dev-entrypoint.sh
RUN chmod +x /usr/local/bin/dev-entrypoint.sh

RUN gem install rake
RUN gem install rails bundler
RUN gem install rails

ENTRYPOINT [ "dev-entrypoint.sh" ]
