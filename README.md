# Under the rules of Sociometry

> Track, find, mining, parsing & analyzing data from social networks.

Software provides nimble web-data operations.
Current state: minimum viable product (MVP). Demo version.

## Stack

  * Tested on Debian 8.5 x64 powered by [flops](https://flops.ru/?refid=18288) cloud-hosting.
  * [Redis](http://redis.io/topics/quickstart) - is an open source, in-memory data structure store, used as database, cache and message broker.
  * [Node.js](https://nodejs.org/en/download/package-manager/) - JavaScript runtime built on [Chrome's V8 JavaScript engine](https://developers.google.com/v8/).
  * [Node Foreman](https://www.npmjs.com/package/foreman) - Node Implementation of Foreman
  * [Telegram messenger CLI](https://github.com/vysheng/tg) - Command-line interface for Telegram. Uses readline interface. (for tests).
  * [kue](https://www.npmjs.com/package/kue) - Kue is a priority job queue backed by redis, built for node.js.
  * [request](https://www.npmjs.com/package/request) - Simplified HTTP request client.
  * [telegram-node-bot](https://www.npmjs.com/package/telegram-node-bot) - Module for creating Telegram bots.

## Environment

### Install system packages
```
  apt-get install    \
    sudo             \
    curl             \
    build-essential  \
    htop             \
    mc               \
    git-core         \
    tcl8.5           \
    nginx            \
    openjdk-8-jre    \
    tree             \
    apache2-utils
```

### Install Node
```
  curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
  sudo apt-get install -y nodejs
```

### Install Redis
```
  wget http://download.redis.io/redis-stable.tar.gz
  tar xvzf redis-stable.tar.gz
  cd redis-stable
  make
  make test
  sudo make install
  sudo mkdir /etc/redis && sudo mkdir /var/redis
  sudo cp utils/redis_init_script /etc/init.d/redis_6379
  sudo nano /etc/init.d/redis_6379
  sudo cp redis.conf /etc/redis/6379.conf
  sudo nano /etc/redis/6379.conf
  sudo mkdir /var/redis/6379
  sudo update-rc.d redis_6379 defaults
  sudo /etc/init.d/redis_6379 start
```

### Create new user
```
  sudo useradd --home-dir /home/bot --create-home --shell /bin/bash bot
```

### Install npm global packages
```
  sudo npm install -g coffee-script foreman
```

### Install package
```
  npm install undertherules
```

### Configure HTTP server. Adding symbolic Links
```
  rm /etc/nginx/sites-enabled/default
  cd /etc/nginx/sites-enabled &&
  sudo ln -s /home/bot/node_modules/undertherules/etc/nginx/default
  sudo service nginx restart
```

## Maintenance

### Launching application without root privileges.
```
  cd ~/node_modules/undertherules
  nf start
```

### Set as a global job using root access.
```
  sudo nf export -o /etc/init
```

## Data-Sources
* [Instagram](https://www.instagram.com/developer/), Examples: [video](https://www.instagram.com/p/BLEkdVVjbUQ/)

## Links
* [Using self-signed certificates](https://core.telegram.org/bots/self-signed) - Upload your certificate using the certificate parameter in the webhook method.
* [Create self-signed SSL certificate for Nginx](https://gist.github.com/jessedearing/2351836) - another solution.
* [Login to Facebook using cURL](https://gist.github.com/hubgit/306638)
* [My first cakefile](https://gist.github.com/joshski/922990)
* [directory-reader.coffee](https://gist.github.com/rodw/6912281) - helper.
* [Writing an Upstart job](https://wiki.debian.org/Upstart) -  starts and stops tasks and daemons according to event rules.
* [OpenJDK packages](https://wiki.debian.org/JavaPackage)
* [Cytoscape.JS](http://js.cytoscape.org/) - is an open-source graph theory (a.k.a. network) library written in JS.  Graph analysis and visualisation.
* [Convert .pem to .crt and .key](http://stackoverflow.com/questions/13732826/convert-pem-to-crt-and-key)
* [How To Install Nginx on Debian 8](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-debian-8)
* [Marvin's Patent Pending Guide to All Things Webhook](https://core.telegram.org/bots/webhooks)
* [Up-to-date Java 6 packages for Debian  ](https://github.com/rraptorr/sun-java6)
* [CoffeeScript syntax](http://rigaux.org/language-study/syntax-across-languages-per-language/CoffeeScript.html) - Syntax across languages per language.
* [Dracula JavaScript Graph Library](https://www.graphdracula.net) - is a set of tools to display and layout interactive connected graphs and networks.
* [Telegram Bot API Webhooks Framework, for Rubyists](https://github.com/solyaris/BOTServer) - develops and deploys bots, running a server for webhooks routing.
* [gobject-introspection-1.0.pc](http://stackoverflow.com/questions/18025730/) - No package 'gobject-introspection-1.0' found error.
* [Typelib file for namespace 'Notify' (any version) not found](https://github.com/vysheng/tg/issues/424) - Test system packages.

## Future todo
  * Analytics for your Telegram bot (e.g. [botan](http://botan.io))
  * Tests using telegtam-cli.
  * class CreateJob [+]
  * Add Russian & Hebrew comments in the code.
  * Create bot for flops.ru
  * Add new links from: vk.com/big.data
  * Authorization
  * class DataBaseHelper (using levelup)
  * JSON templates for extracting data (request, response).
  * Digital mapping

## Thanks
  * Romanovsky P. (Socialist Group)
  * Ashomko A. (Tiger Milk)
  * Pivkin P. (Buzz Like)
  * Korotun V. (Buzz Like)
  * Grigoriev E. (Esprite Games)
  * Bogomolov A. (Uroboros Team)
  * Akhmetov A. (RTA Moscow)
  * Maas E. (TASS News Agency)

## LICENSE
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
