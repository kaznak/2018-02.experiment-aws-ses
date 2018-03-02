
# aplit-attach

Python 3.6 で実装された AWS lambda 関数

## 動作

1. AWS S3 からの putobject notification で起動される
2. 受け取った notification からバケットとキーを取得して読み込み
3. 画像の添付ファイルを取得して AWS S3 に書き込み

## S3 オブジェクト命名規則
<%Y-%m-%dT%H%M%S%Z>.<mutipart_count>.<sha512hash>.<size>.<extension>

例 : 2018-03-02T151630JST.2.55dc50ba91beb4e6125ed646b8dcec0585c84163382f1f7b0c80040f8bebdec3.761382.png
