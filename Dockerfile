FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ENV VENDOR_BUNDLE=/vendor/bundle
ENV BUNDLE_GEMFILE=/maps/text/Gemfile

RUN apk update && apk upgrade
RUN apk add -U bash curl github-cli jq yq

ADD . /maps
RUN bundle install

RUN chmod +x /maps/entrypoint.sh
ENTRYPOINT ["/maps/entrypoint.sh"]
