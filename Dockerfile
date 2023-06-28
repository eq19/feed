FROM jekyll/jekyll:latest
LABEL version=v0.0.1
ARG OWNER

ADD . /maps

ENV PATH="${PATH}:/maps/_plugins"
ENV OWNER="${GITHUB_REPOSITORY_OWNER}"
ENV BUNDLE_GEMFILE=/maps/_plugins/Gemfile

RUN apk update && apk upgrade
RUN apk add -U bash curl github-cli jq yq
RUN bundle install

ENTRYPOINT ["entrypoint.sh"]
