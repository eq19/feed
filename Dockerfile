FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ADD . /maps

ENV PATH="${PATH}:/maps/_plugins"
ENV BUNDLE_GEMFILE=/maps/_plugins/Gemfile
ENV OWNER=${GITHUB_REPOSITORY_OWNER}

RUN apk update && apk upgrade
RUN apk add -U bash curl github-cli jq yq
RUN bundle install

ENTRYPOINT ["entrypoint.sh"]
