# WebForms on Mono (Docker)

ASP.NET Web Forms (.NET Framework 4.x) を Mono + Apache(mod_mono) 上で動かす最小構成のサンプルです。MySQL への接続確認と、`App_Data/data.txt` の読み書きデモが含まれます。

- Web: Debian + Apache + mod_mono + mono-apache-server4
- App: Web Forms (CodeBehind) `Default.aspx` / `Default.aspx.cs`
- DB: MySQL 8.0（`docker-compose` で同時起動）

## 必要要件
- Docker (24+) と Docker Compose
- インターネット接続（初回ビルド時に APT と NuGet パッケージの取得を行います）

## 使い方
1) ビルド & 起動

```bash
# 初回は --build を付けてビルド
docker compose up --build
# バックグラウンドで動かす場合
# docker compose up --build -d
```

2) ブラウザでアクセス
- http://localhost:8080
- ページ内の「DB PostBack」ボタンで MySQL に接続し、`version()` と `now()` を取得します。
- 下部フォームで `App_Data/data.txt` に追記できます（UTF-8 BOM なし）。

3) 停止
```bash
docker compose down
# DB ボリュームも削除したい場合
# docker compose down -v
```

## 構成
- `Dockerfile`: Debian ベースで Apache + mod_mono を設定。`/app` に WebForms を配置し、ポート `8080` を公開。
  - ビルド時に NuGet から `Dapper.dll` と `MySql.Data.dll` を取得して `/app/bin/` に配置します。
- `docker-compose.yml`: 
  - `web` サービス（このアプリ）: `8080:8080` を公開、`db` の起動待ち（ヘルスチェック）を設定。
  - `db` サービス（MySQL 8.0）: `3306:3306` を公開。ユーザー/DB は下記。
    - `MYSQL_DATABASE=appdb`
    - `MYSQL_USER=app`
    - `MYSQL_PASSWORD=apppass`
    - `MYSQL_ROOT_PASSWORD=secretroot`
  - DB データは `dbdata` ボリュームに永続化。
- `app/web.config`: 接続文字列は `Server=db;Database=appdb;Uid=app;Pwd=apppass;...`（Compose のサービス名 `db` に接続）。
- `app/Default.aspx`: 画面（Label/Buttons/TextBox 等）。
- `app/Default.aspx.cs`: CodeBehind（MySQL への疎通、`App_Data/data.txt` 読み書き）。

## 開発 Tips
- コードを変更したら再ビルドが必要です。
```bash
docker compose up --build -d
```
- ログ確認:
```bash
# Web コンテナ
docker logs -f webforms-app
# DB コンテナ
docker logs -f webforms-mysql
```

## トラブルシューティング
- Web が 404/500 の場合:
  - `docker logs webforms-app` を確認。
  - `app/bin/` に `Dapper.dll` と `MySql.Data.dll` が存在するか（ビルド時に自動配置）。
- DB 接続エラーになる場合:
  - MySQL の起動に時間がかかることがあります。`db` のヘルスチェックが `healthy` になるまで待機します。
  - ポート競合がないか確認（ローカルで 3306 を他プロセスが使用中など）。
- ポート 8080 が既に使用中:
  - `docker-compose.yml` の `ports` を `8081:8080` などに変更して再起動してください。

## ライセンス
このリポジトリ内のコードは学習用途のサンプルです。ライセンスの明示が必要な場合はお知らせください。

