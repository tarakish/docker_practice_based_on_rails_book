# Node.jsダウンロード用ビルドステージ
FROM ruby:2.6.6 AS nodejs

WORKDIR /tmp

# Node.jsのダウンロード
RUN curl -LO https://nodejs.org/dist/v12.14.1/node-v12.14.1-linux-x64.tar.xz
RUN tar xvf node-v12.14.1-linux-x64.tar.xz
RUN mv node-v12.14.1-linux-x64 node

# Railsプロジェクトインストール
FROM ruby:2.6.6

# nodejsをインストールしたイメージからnode.jsをコピーする
COPY --from=nodejs /tmp/node /opt/node
ENV PATH /opt/node/bin:$PATH

# アプリケーション起動用のユーザーを追加
RUN useradd -m -u 1000 rails
RUN mkdir /app && chown rails /app
USER rails

# yarnのインストール
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH /home/rails/.yarn/bin:/home/rails/.config/yarn/global/node_modules/.bin:$PATH

# ruby-2.7.0でnewした場合を考慮
RUN gem install bundler

WORKDIR /app

# Dockerのビルドステップキャッシュを利用するため
# 先にGemfileを転送し、bundle installする
COPY --chown=rails Gemfile Gemfile.lock package.json yarn.lock /app/

RUN bundle install
RUN yarn install

COPY --chown=rails . /app

RUN bin/rails assets:precompile

VOLUME /app/public

#実行時にコマンド指定が無い場合に実行されるコマンド
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
