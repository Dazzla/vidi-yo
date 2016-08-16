FROM alpine
MAINTAINER 'jspc<james.condron@ft.com>'

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update
RUN apk add --update openssh py-pip build-base python-dev py-boto git libffi-dev openssl-dev && \
    pip install awscli  paramiko PyYAML Jinja2 httplib2 && \
    apk add ruby ruby-dev ruby-io-console ruby-bundler zlib-dev xz-dev libxml2-dev libxslt-dev

RUN pip install ansible

# Clean
RUN rm -rf /var/cache/apk/*

# Building gems can take ages and we don't always have need to
RUN mkdir /tool
COPY src/Gemfile /tool
COPY src/Gemfile.lock /tool

WORKDIR /tool
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

COPY src/ /tool

CMD /tool/entry_point.sh
