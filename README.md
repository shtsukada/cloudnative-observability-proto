# cloudnative-observability-proto

gRPC サービス定義（.protoファイル）とコード生成を提供するリポジトリです。

## 成果物
- proto/ ディレクトリに gRPC サービス定義
- Go コード生成
- Go module として公開可能

## 契約
- buf / protoc で生成
- go_package を適切に設定
- breaking change 検出 (buf breaking)

## Quickstart
```bash
make generate
go get github.com/YOUR_ORG/cloudnative-observability-proto@vX.Y.Z
```

## MVP
- proto ファイル定義
- Go コード生成
- モジュールタグ公開

## Plus
- buf lint / format / breaking check
- 他言語用コード生成 (Python/TS)
- protoc-gen-doc による API ドキュメント

## 受け入れ基準チェックリスト
- [ ] make generate が成功
- [ ] app/operator 双方で go get に成功
- [ ] buf lint / breaking check パス

## スコープ外
- アプリやOperator実装

## ライセンス
MIT License