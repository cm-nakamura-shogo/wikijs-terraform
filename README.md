
# wikijs-terraform

今回は以下のような構成としています。少しStyle Guideからは外れるかもしれませんがご了承ください。

```
├─environments
│   └─dev/
│          dev.tfvars
│          main.tf
└─modules
    ├─ec2/
    │      config.yml
    │      main.tf
    ├─rds/
    │      main.tf
    └─vpc/
           main.tf
```

この中で`dev.tfvars`だけは自身で設定が必要ですので、以下のような内容を入力してファイルを作成ください。

```
project_prefix="wikijs"
rds_database="wiki"                # RDSのデータベース名
rds_user="wikijs"                  # RDSのユーザ名
rds_password=""                    # RDSのパスワードを入力
wikijs_allow_ingress_cidr_block="" # Wiki.jsへのアクセスを許可するPCのIPアドレス範囲を入力
```

## terraform

`environments/dev`でコマンドを実行していきます。

initをまず実行します。

```
terraform init
```

次のapplyを実行すればOKです。

```
terraform apply -var-file dev.tfvars
```

## psqlでの検証

```shell
export DB_TYPE=
export DB_HOST=
export DB_PORT=
export DB_NAME=
export DB_USER=
export DB_PASS=
```

```
psql --host=$DB_HOST --port=$DB_PORT --dbname=$DB_NAME --username=$DB_USER
```