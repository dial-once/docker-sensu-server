FROM dialonce/sensu

MAINTAINER Julien Kernec'h <docker@dial-once.com>

# Install sensu plugins
RUN gem install \
  sensu-plugins-slack \
  sensu-plugins-mailer \
  # Install sensu plugins from sources
  && mkdir -p /etc/sensu/extensions \
  && apk add --no-cache tar ca-certificates wget \
  && wget -O - https://github.com/opower/sensu-metrics-relay/archive/master.tar.gz | tar xzf - --strip 4 -C /etc/sensu/extensions \
  && apk del tar ca-certificates wget

COPY conf.d /etc/sensu/conf.d

CMD dockerize \
  -template /etc/sensu/conf.d/config.tmpl:/etc/sensu/conf.d/config.json \
  -template /etc/sensu/conf.d/handlers/slack.tmpl:/etc/sensu/conf.d/handlers/slack_handler.json \
  -template /etc/sensu/conf.d/handlers/mailer.tmpl:/etc/sensu/conf.d/handlers/mailer_handler.json \
  -template /etc/sensu/conf.d/relays/carbon.tmpl:/etc/sensu/conf.d/config_relay.json \
  sensu-server -d /etc/sensu/conf.d
