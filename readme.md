# deploy
Amazon EKSとKubernetesを使用したデプロイメントリソース。  
起動用bashスクリプトによりデプロイを自動化している。

主に下記のawsリソースの展開を行っている。

- APIサーバーインスタンス
- WEBサーバーインスタンス
- WebSocketサーバーインスタンス
- MongoDBサーバーインスタンス
- Redisサーバーインスタンス
- CloudWatch Container Insights
- Application Load Balancer

下記にaws構成図を示す ※一部抜粋

<img width="718" alt="aws構成図" src="https://github.com/altair-development/altair-development/assets/140937480/da63c974-0297-4d47-a206-9d753d41b0be">

## How to use
まず最初に下記のコマンドを実行しdeployレポジトリをクローンします。
```
git clone https://github.com/altair-development/deploy.git
```

`deploy/kubernetes/dev`直下に`secret`フォルダを作成し下記のファイルを追加します。

| フィアル名  | 説明 |
| ------------- | ------------- |
| env/api/.env  | APIサーバーで使用する環境変数ファイル。altair/apiモジュールのルートフォルダに配置される。 |
| env/spa/.env.local  | Webサーバーで使用する環境変数ファイル。altair/spaモジュールのルートフォルダに配置される。 |
| env/websock/.env  | WebSocketサーバーで使用する環境変数ファイル。altair/websockモジュールのルートフォルダに配置される。 |
| env/websock-monitor/.env  | WebSocketサーバーで使用する環境変数ファイル。altair/websock-monitorモジュールのルートフォルダに配置される。 |
| git/api/clone_url.txt  |  altair/apiリポジトリのクローンURLを記載する。  |
| git/api/clone_blanch.txt  |  altair/apiリポジトリのクローンブランチを記載する。  |
| git/spa/clone_url.txt  |  altair/spaリポジトリのクローンURLを記載する。  |
| git/spa/clone_blanch.txt  |  altair/spaリポジトリのクローンブランチを記載する。  |
| git/websock/clone_url.txt  |  altair/websockリポジトリのクローンURLを記載する。  |
| git/websock/clone_blanch.txt  |  altair/websockリポジトリのクローンブランチを記載する。  |
| git/websock-monitor/clone_url.txt  |  altair/websock-monitorリポジトリのクローンURLを記載する。  |
| git/websock-monitor/clone_blanch.txt  |  altair/websock-monitorリポジトリのクローンブランチを記載する。  |
| mongo-access-creds/db_pass_admin.txt  |  mongoDBのadminユーザーIDを記載する。  |
| mongo-access-creds/db_user_admin.txt  |  mongoDBのadminユーザーpassを記載する。  |
| mongo-key/mongodb-keyfile  |  mongoDBのレプリカセットが相互にSSH接続するための公開鍵ファイル  |
| mongo-script/createDbAdmin.js  |  adminテーブルにユーザーを作成するスクリプトファイル。  |
| mongo-script/createDbAltair.js  |  aitairテーブルにユーザーを作成、各種マスタデータを追加するスクリプトファイル。  |
| redis-access-creds/requirepass.txt  |  redisサーバーのレプリカセットのパスワードを記載する。  |

下記コマンドを実行しscriptフォルダに移動します。
```
cd .\deploy\kubernetes\dev\script\deploy
```
下記コマンドを実行し`setting.sh.tmp`ファイルを`setting.sh`のファイル名でコピーします。
```
COPY setting.sh.tmp setting.sh
```
`setting.sh`ファイルを開き各種環境変数の値を設定します。

Git BashあるいはWSLを起動し下記コマンドを実行する。
```
[localリポジトリパス]\kubernetes\dev\script\deploy\deploy.sh
```
`setting.sh`の`LOGDIRNAME`に設定したパスからログファイルを開き正常に実行されたことを確認する。
