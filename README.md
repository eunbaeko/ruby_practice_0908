# README

二つの実行ファイルがあります。rails上で動くコマンドプログラムです。

`bundle install`

のあと、

`bundle exec rails r etc/create_index.rb`

を実行するとIndexファイルを生成します。

ファイルのパス、エンコードを指定する場合は、

`bundle exec rails r etc/create_index.rb --path etc/resource/KEN_ALL.CSV --encoding Shift_JIS`

のようにArgumentを設定してください。

指定しなかった場合、上の例に書いているパラメータがDefaultとして適用されます。

実行前に、元になるファイルをパスに配置してください。

`bundle exec rails r etc/search.rb`

を実行すると検索コンソールへ進みます。

日本語を入力すると検索結果が出力されます。

`\q` を入力すると終了されます。
