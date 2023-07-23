FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ADD . /maps

ENV PATH=${PATH}:/maps/_plugins
ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1

ENV GEM_PATH=${VENDOR}/gem
ENV PIP_CACHE_DIR=${VENDOR}/pip/cache
ENV NPM_CACHE_DIR=${VENDOR}/npm/cache
ENV BUNDLE_CACHE_PATH=${VENDOR}/gem/cache
ENV BUNDLE_GEMFILE=/maps/_plugins/Gemfile

# RUN apk update && apk upgrade
RUN apk add -U bash curl github-cli jq yq

# https://bundler.io/v1.16/man/bundle-config.1.html
RUN bundle install &>/dev/null && bundle add webrick

ENTRYPOINT ["entrypoint.sh"]
