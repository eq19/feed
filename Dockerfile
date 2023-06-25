FROM jekyll/jekyll:latest
LABEL version=v0.0.1

ENV VENDOR_BUNDLE=/vendor/bundle
ENV BUNDLE_GEMFILE=/maps/text/Gemfile

RUN apk update && apk upgrade
RUN apk add -U curl github-cli jq yq

ADD . /maps
RUN bundle install

ENV OWNER=${GITHUB_REPOSITORY_OWNER}
ENV REPOSITORY=${OWNER}/${OWNER}.github.io
ENV JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml
  
RUN chmod +x /maps/entrypoint.sh
ENTRYPOINT ["/maps/entrypoint.sh"]
