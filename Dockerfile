FROM jekyll/jekyll:stable
LABEL version=v0.0.1

ADD . /maps

ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1
ENV PATH=${PATH}:/maps/_plugins/scripts
ENV BUNDLE_GEMFILE=/maps/_plugins/Gemfile

# RUN apk update && apk upgrade
RUN chmod -R +x /maps/_plugins/scripts
RUN apk add -U bash curl github-cli jq yq

RUN bundle install
RUN bundle exec github-pages versions

ENTRYPOINT ["entrypoint.sh"]
