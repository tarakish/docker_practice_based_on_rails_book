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

# yarnのインストール
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH /root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:$PATH

# ruby-2.7.0でnewした場合を考慮
RUN gem install bundler

WORKDIR /app

RUN bundle config set path vendor/bundle

#実行時にコマンド指定が無い場合に実行されるコマンド
CMD ["bash"]
