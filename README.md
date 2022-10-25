# aws-minecraft-infra

AWS上にマインクラフト環境作るTerraform

## 構築予定図

![構成図](doc/infra.drawio.png)

## deploy

* tfstate保存用のバケットを作成する
* `backend.tf.sample` をコピーし、作成したtfstate用のバケット名を指定する
* `tfvars.sample` を適当な名前でコピーし、値を設定する
* 下記コマンドでデプロイ

```sh
terraform init
terraform plan -var-file xxx.tfvars
terraform apply -var-file xxx.tfvars
```
