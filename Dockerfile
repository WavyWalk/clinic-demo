FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install nokogiri -v '1.10.0'
RUN gem install bcrypt -v '3.1.12'
RUN gem install byebug -v '10.0.2'
RUN gem install puma -v '3.12.0'
RUN gem install unf_ext -v '0.0.7.5'
RUN gem install ffi -v '1.10.0'
RUN gem install http_parser.rb -v '0.6.0'
RUN gem install pg -v '0.15.0'
RUN gem install rainbow -v '2.2.2'
RUN bundle install
COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3001

# Start the main process.
CMD rake db:create
CMD rake db:migrate
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3001"]