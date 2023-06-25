FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ENV VENDOR_BUNDLE=/vendor/bundle
ENV BUNDLE_GEMFILE=/maps/text/Gemfile

RUN apk update && apk upgrade
RUN apk add --update  -U curl github-cli jq nodejs npm yq

ADD . /maps
RUN bundle install
RUN npm install --save gh-pinned-repos

RUN chmod +x /maps/entrypoint.sh
ENTRYPOINT ["/maps/entrypoint.sh"]
