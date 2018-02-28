
# AWS SES と S3 と lambda の連携

1. AWS SES でメールを受信して S3 に格納する
2. lambda で受信したメールの添付ファイルを取得して S3 に格納する

## 使い方

1. lambda package の作成
   - sh/make-aws_lambda_package を実行
2. terraform ディレクトリで terraform apply

## 参考文献
Amazon Simple Email Service 開発者ガイド
https://docs.aws.amazon.com/ja_jp/ses/latest/DeveloperGuide/Welcome.html
