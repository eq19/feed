FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ADD . /maps

ENV PATH="${PATH}:/maps/_plugins"
ENV BUNDLE_GEMFILE=/maps/_plugins/Gemfile

RRUN apk update && apk upgrade
RUN apk add -U bash curl github-cli jq yq
RUN bundle install &>/dev/null && bundle add webrick

ENTRYPOINT ["entrypoint.sh"]