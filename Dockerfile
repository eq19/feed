FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ENV PATH="${PATH}:/maps/_plugins"

RUN apk update && apk upgrade
RUN apk add -U bash curl github-cli jq yq

ADD . /maps
RUN bundle install

ENTRYPOINT ["entrypoint.sh"]
