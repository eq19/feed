FROM jekyll/jekyll:latest
LABEL version=v0.0.1

RUN apk update && apk upgrade
RUN apk add -U curl github-cli jq yq

ADD . /maps

ENV VENDOR_BUNDLE=/vendor/bundle
ENV BUNDLE_GEMFILE=/maps/_plugins/gemspec/Gemfile

RUN bundle install

RUN chmod +x /maps/entrypoint.sh
ENTRYPOINT ["/maps/entrypoint.sh"]
