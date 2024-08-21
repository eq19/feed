FROM jekyll/jekyll:stable
LABEL version=v0.0.1

ADD . /maps

RUN chmod -R +x /maps/_plugins/scripts
ENV PATH=${PATH}:/maps/_plugins/scripts

#RUN apk update && apk upgrade
RUN apk add -U bash curl github-cli jq yq

ENV BUNDLE_GEMFILE=/maps/_plugins/Gemfile
RUN bundle install

ENTRYPOINT ["entrypoint.sh"]
