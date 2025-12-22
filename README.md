# cloudnative-observability-proto

gRPC サービス定義（.protoファイル）とコード生成を提供するリポジトリです。
cloudnative-observability-app / cloudnative-observability-operatorから共通のAPI契約として参照されることを想定しています。

## 成果物
- proto/ ディレクトリに gRPC サービス定義(.proto)
- Go コード生成(生成物はコミットして同期を維持)
- Go module として公開可能

## 生成物の出力先
- gen/go/observability/grpcburner/v1
  - burner.pb.go
  - burner_grpc.pb.go

## 契約
- .protoを唯一の正(Source of Truth)とします(生成物を手編集しない)
- buf を用いて生成・検証します
- go_package を適切に設定
- 破壊的変更はbuf breakingで検知します
- 生成物(gen/)はコミットし、CIで同期ズレ(生成漏れ)を検知します

## 前提
- Go(このリポジトリはgo.modを保持します)
- buf(CIでもセットアップします)

## Quickstart
```bash
make generate
go get github.com/YOUR_ORG/cloudnative-observability-proto@vX.Y.Z
```
## 利用例(Go/app ・ operatorから参照)

```bash
import (
  grpcburnerv1 "github.com/shtsukada/cloudnative-observability-proto/gen/go/observability/grpcburner/v1"
)
```
### Client (Unary:Ping)
// conn はgrpc.Dial(...)で作ったものを想定
```go
client := grpcburnerv1.NewBurnerClient(conn)

resp, err := client.Ping(ctx, &grpcburnerv1.PingRequest{})
if err != nil {
  // handle error
}
_ = resp
```

### Server(実装の雛形)
```go
type BurnerServer struct{
  grpcburnerv1.UnimplementedBurnerServer
}

func (s *BurnerServer) Ping(ctx context.Context, req *grpcburnerv1.PingRequest) (*grpcburnerv1.PingReply, error) {
  return &grpcburnerv1.PingReply{}, nil
}
```

### Streaming（Server Streaming: DoWorkServerStreaming）

代表フィールド (.proto)
- DoWorkServerStreamingRequest
  - request_id (string)
  - config (WorkConfig)
  - repeat (int32,1以上)

- DoWorkResponse
  - request_id (string)
  - ok (bool)
  - error_message (string,あれば)

- WorkConfig (代表フィールド)
  - mode (LoadMode: CPU/MEM/CPU+MEM/IO など)
  - duration_ms (int64, ジョブ継続時間[ms])
  - alloc_mb (int32, 確保メモリ量[MB])

#### Client 側（受信ループ）

```go
client := grpcburnerv1.NewBurnerClient(conn)

stream, err := client.DoWorkServerStreaming(ctx, &grpcburnerv1.DoWorkServerStreamingRequest{
  RequestId: "req-001",
  Config: &grpcburnerv1.WorkConfig{
    Mode: grpcburnerv1.LoadMode_LOAD_MODE_CPU,
    DurationMs: 3_000,
    AllocMb: 256,
  },
    Repeat: 3, // 1以上
  })
  if err != nil {
    // handle error
  }

  for {
    resp, err := stream.Recv()
    if err == io.EOF {
        break
      } if err != nil {
        // handle error
      }

    // DoWorkResponse の代表フィールド
    if !resp.Ok {
      // resp.ErrorMessage があれば参照
    }
    _ = resp.RequestId
  }
```

#### Server 側（逐次 Send）

```go
type BurnerServer struct {
  grpcburnerv1.UnimplementedBurnerServer
}

func (s *BurnerServer) DoWorkServerStreaming(
  req *grpcburnerv1.DoWorkServerStreamingRequest,
  stream grpcburnerv1.Burner_DoWorkServerStreamingServer,
) error {
  // req の内容に応じて複数回結果を返す
  for i := 0; i < 3; i++ {
    if err := stream.Send(&grpcburnerv1.DoWorkResponse{
      // 必要なフィールドがあれば埋める
    }); err != nil {
      return err
    }
  }
  return nil
}
```

- NewBurnerClient / BurnerServer は service Burner から生成されます。
- grpcburnerv1 は option go_package の ;grpcburnerv1 に対応するGoパッケージ名です。


## Make　Target
- make lint
  - buf lintを実行します
- make format
  - buf format -wで整形します(ファイルを書き換えます)
- make format-check
  - buf format --exit-codeで整形差分を検知します
- make breaking
  - mainブランチ(proto/)と比較して breaking changeを検知します
- make generate
  - Go生成を実行します
- make generate-check
  - 生成後に差分があれば失敗します(生成物のコミット漏れを検知)
- make tidy
  - go mod tidyを実行します
- make tidy-check
  - tidy後にgo.mod/go.sumの差分があれば失敗します

## MVP
- proto ファイル定義
- Go コード生成
- モジュールタグ公開

## Plus
- buf lint / format / breaking check
- 他言語用コード生成 (Python/TS)
- protoc-gen-doc による API ドキュメント

## バージョニング
- SemVer タグ（例：v0.1.0）で配布します
- 破壊的変更はメジャー更新とし、buf breaking で検知します

## 受け入れ基準チェックリスト
- [ ] make generate が成功
- [ ] app/operator 双方で go get に成功
- [ ] buf lint / breaking check パス

## スコープ外
- アプリやOperator実装

## ライセンス
MIT License
