# Rust 中文社区交流平台

[Rust 中文社区交流平台](https://chat.rust-china.org) 是使用 [Rocket.Chat](https://github.com/RocketChat/Rocket.Chat) 搭建的即时聊天平台，旨在为国内 Rust 语言爱好者提供一个集中的交流平台。[Rocket.Chat](https://github.com/RocketChat/Rocket.Chat) 是一个类似 [Slack](https://slack.com) 的在线聊天应用。

本项目是通过 docker 部署的，搭建过程简单，也方便迁移。本地运行只需要 clone 本项目，然后在项目目录下执行 `docker-compose up -d`，修改 /etc/hosts 添加

```
127.0.0.1 chat.rust-china.local
```

如果是已有备份数据 rocketchat-xxxx.tar.gz，解压后将其放到 ./data/dump 目录下，使目录结构为 ./data/dump/rocketchat

```
docker-compose up -d mongo
docker exec chatrustchinaorg_mongo_1 mongorestore /dump/rocketchat
docker-compose up -d rocket
docker-compose up -d hubot
```

配置 nginx
```
server {
    listen 80;
    server_name chat.rust-china.local;
    location / {
        proxy_pass http://127.0.0.1:5002;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_redirect off;
    }
}
```

然后访问 http://chat.rust-china.local
