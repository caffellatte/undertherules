# Under The Rules

Flexible environment for social network analysis (SNA). Software provides
full-cycle of retrieving and subsequent processing data from the social networks.

> parsing & analyzing social networks data.

The aim of the project is creating automated system to replace the existing
solutions. We develop a new, more flexible tool, adapted to the needs of the
researcher. Develops products will be endowed into **full-stack** solution
written using Coffee-script both on server & client sides. Current state: `development`.

## Architecture (main modules)

| Section | Technology | Functions |
| ------------- | ---------- | -------- |
| Runtime environment | Node.js | JavaScript interpreter (engine) | [link]((https://nodejs.org/) |
| In-memory data storage | Redis | Key-value data structure server | [link]((https://redis.io/) |
| Main language | CoffeeScript | Syntax sugar that compiles into JavaScript | [link]((https://coffeescript.org/) |
| Queue server | Kue |  Priority job queue backed by Redis | [link]((https://github.com/Automattic/kue) |
| Database storage | LevelUP | Node.js-style LevelDB wrapper | [link](https://github.com/Level/levelup) |
| RPC system  | Dnode | Asynchronous socket service via sockjs | [link](https://www.npmjs.com/package/dnode) |
| Clustering tool | Node Foreman | Manager for Procfile-based applications | [link](https://www.npmjs.com/package/foreman) |
| Graph Drawing | Sigma | Visual JavaScript library | [link](http://sigmajs.org)|

## Installation

### Node Foreman environment configuration **.env**

    #  KUE Task Processing Server Address (HOST/PORT)
    KUE_HOST="127.0.0.1"
    KUE_PORT="8816"

    # DNODE Server Address (HOST/PORT)
    PANEL_HOST="127.0.0.1"
    PANEL_PORT="8294"

    # VK.COM application configuration
    VK_CLIENT_ID="5787387"
    VK_CLIENT_SECRET="dpX9fyBrPWyVcOZAE6Hv"
    VK_DISPLAY="mobile"
    VK_VERSION="5.62"
    VK_SCOPE="friends,pages,wall,ads,offline,groups,stats,email,market"

    # Directories Paths
    LEVEL_DIR="/home/bot/undertherules/.db"
    STATIC_DIR="/home/bot/undertherules/static"
    HTDOCS_DIr="/home/bot/undertherules/src/htdocs"
    CORE_DIR="/home/bot/node_modules/undertherules/src"

    # Instagram Cookie File
    IG_COOKIE="/home/bot/undertherules/cookie.txt"

    # Telegram Token
    TELEGRAM_TOKEN="270400291:AAGUzmd55Pu8sRHL4mkyat7K2ezlh4NNebo"

### Node Foreman process list configuration **Procfile**

    cluster: coffee ./src/cluster.coffee

### Prepare OS (Debian)

    useradd --home-dir /home/bot --create-home --shell /bin/bash bot
    passwd bot


    usermod -g staff bot **optional**
    apt-get update
    apt-get install -y curl build-essential python htop mc tree whois wget
    apt-get upgrade -y

### Install Node.js global install

    npm install -g coffee-script coffee-jshint foreman

### Clone package from github

    git clone https://github.com/caffellatte/undertherules.git
    cd undertherules
    npm install

## Usage

Run application with Node Foreman:

    nf start

## Links

- [Telegram messenger CLI](https://github.com/vysheng/tg) - Command-line interface for Telegram. Uses readline interface
- [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
- [Classes](https://arcturo.github.io/library/coffeescript/03_classes.html) from The Little Book on CoffeeScript
- Why Invoke [apply](http://stackoverflow.com/questions/5936604/) instead of calling function directly?
- How to install [node and npm](https://gist.github.com/isaacs/579814) without sudo
- [Redis](https://redis.io/topics/quickstart) on Debian (quick start)
- [Redis](https://vk.cc/60LXaa) on Mac OS X via Homebrew
- [opendkim](https://wiki.debian.org/opendkim) Postfix and opendkim on Debian

## Thanks

Romanovsky P. (Socialist Group); Ashomko A. (TigerMilk); Pivkin P. (BuzzLike);
Korotun V. (BuzzLike); Grigoriev E. (Esprite Games); Bogomolov A. (NMO);
Akhmetov A. (RTA Moscow) ; Maas E. (TASS News Agency).

## License

MIT License

Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
