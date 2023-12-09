FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ADD . /maps

ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1
ENV BUNDLE_GEMFILE=/maps/_plugins/Gemfile
ENV PATH=${PATH}:/maps/_plugins:/maps/_plugins/scripts

# RUN apk update && apk upgrade
RUN chmod +x /maps/_plugins/scripts/*
RUN apk add -U bash curl github-cli jq yq
RUN bundle install &>/dev/null && bundle add webrick

ENTRYPOINT ["entrypoint.sh"]
