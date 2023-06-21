FROM jekyll/jekyll:latest
LABEL version=v0.0.1

RUN apk update
RUN apk upgrade --no-cache
RUN apk add -U bash curl jq yq

ADD . /maps

ENV VENDOR_BUNDLE=/vendor/bundle
ENV BUNDLE_GEMFILE=/maps/text/Gemfile

RUN bundle install
RUN chmod +x /maps/text/entrypoint.sh
ENTRYPOINT ["/maps/text/entrypoint.sh"]
