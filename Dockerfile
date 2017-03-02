FROM ruby:2.2.4

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
RUN apt-get update && apt-get install -qq -y build-essential

# Use Foreman to manage jobs and server processes
RUN gem install foreman

# Install Phantomjs for headless UI testing
ENV PHANTOMJS_FILE phantomjs-2.1.1-linux-x86_64
ENV PHANTOMJS_URL https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOMJS_FILE.tar.bz2
ENV PHANTOMJS_DIR /usr/local/share
RUN curl -sSL $PHANTOMJS_URL | tar -xj -C $PHANTOMJS_DIR
RUN ln -s $PHANTOMJS_DIR/$PHANTOMJS_FILE/bin/phantomjs /usr/local/bin/phantomjs

# Initialize application working directory
ENV APP_DIR /app
RUN mkdir $APP_DIR
WORKDIR $APP_DIR

# Install the or-tools MiniZinc distribution into vendor app directory
ENV MINIZINC_URL https://github.com/inz/minizinc-dist/releases/download/minizinc-2.0.13_or-tools-v2016-06/minizinc-2.0.13_or-tools-v2016-06-linux64-vendor.tar.gz
RUN curl -sSL $MINIZINC_URL | tar -xz
ENV PATH $APP_DIR/vendor/minizinc/bin:$PATH

# Ensure gems are cached and only get updated when they change.
# This drastically reduces build times when your gems do not change.
COPY .ruby-version $APP_DIR/
COPY Gemfile $APP_DIR/
COPY Gemfile.lock $APP_DIR/
RUN gem install bundler --conservative
RUN bundle install

# Copy the entire application code
COPY . $APP_DIR

RUN bin/rake db:setup

ENV DISABLE_CORS true
ENV PORT 3000
EXPOSE 3000

CMD ["foreman", "start"]
