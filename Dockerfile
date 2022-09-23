# base image
# ex. FROM base_image: tag
FROM ruby:2.7.2-alpine

# ARG = Dorkerfile内の変数定義
# app
ARG WORKDIR
ARG RUNTIME_PACKAGES="nodejs tzdata postgresql-dev postgresql git"
ARG DEV_PACKAGES="build-base curl-dev"

# ENV 環境変数を定義(Dockerfile, コンテナ)
# Rails ENV["TZ"] => Asia/Tokyo
ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# base image に対してコマンド実行
# in this file case, FROM ruby:2.7.1-alpine
# ${home} or $HOME => /app
# RUN echo ${HOME}

# Dockerfile内で指定した命令を実行　RUN, COPY, ADD, ENTRYPOINT, CMD
# 作業ディレクトリを定義
# コンテナ/app/Rails App
WORKDIR ${HOME}

# ホスト側{PC}のファイルをコンテナにコピー
# COPY copy元(host) copy先(コンテナ)
COPY Gemfile* ./

    # apk => Alpine Linuxのコマンド
    # apk update => パッケージの最新リストを取得
RUN apk update && \
    # apk upgrade => インストールパッケージを最新のものに
    apk upgrade && \
    
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    # --virtual 名前(任意) = 仮想パッケージ
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    # -j4(jobs=4) = Gemインストールの高速化
    bundle install -j4 && \
    # パッケージを削除(why? => 使わないから軽量化)
    apk del build-dependencies

# apiディレクトリ以下をコンテナのカレントディレクトリに
COPY . ./

# コンテナ内で実行したいコマンド
# -b => bind プロセスを指定したip(0.0.0.0)アドレスに紐付けする
CMD ["rails", "server", "-b", "0.0.0.0"]

# ホスト(PC)     : コンテナ
# ブラウザ(外部) : Rails
# bind why? => コンテナのRailsを外部のブラウザから参照するため