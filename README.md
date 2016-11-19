# Under the rules of Sociometry

> Track, find, mining, parsing & analyzing data from social networks.

Software provides nimble web-data operations.
Current state: minimum viable product (MVP). Demo version.


## Stack
  * [kue](https://www.npmjs.com/package/kue) - Kue is a priority job queue backed by redis, built for node.js.
  * [request](https://www.npmjs.com/package/request) - Simplified HTTP request client.
  * [telegram-node-bot](https://www.npmjs.com/package/telegram-node-bot) - Module for creating Telegram bots.

## Install
  ```
  npm install --save undertherules
  ```
  Developers version only.

## Deployment
Prerequisites For Debian 8. Tested:
  * [DigitalOcean: Cloud computing designed for developers](https://m.do.co/c/e4bc7eb8bf03) -  is a simple and robust cloud computing platform.
  * [Flops (VPS, VDS, SSD) free trial cloud-hosting.](https://flops.ru/?refid=18288) - simple, robust hosting.

  ```
  sudo apt-get install \
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
## Software
  * [Redis](http://redis.io/topics/quickstart) - Redis is an open source, in-memory data structure store, used as database, cache and message broker.
  * [Node.js](https://nodejs.org/en/download/package-manager/) - JavaScript runtime built on [Chrome's V8 JavaScript engine](https://developers.google.com/v8/).
  * [Node Foreman](https://www.npmjs.com/package/foreman) - Node Implementation of Foreman
  * [Telegram messenger CLI](https://github.com/vysheng/tg) - Command-line interface for Telegram. Uses readline interface. (for tests).

## Create new user
  ```
  sudo useradd --home-dir /home/utrbot --create-home --shell /bin/bash utrbot
  ```
## Configure NGINX. Add symbolic Links
  ```
  cd /etc/nginx/sites-enabled && sudo ln \
  -s <APP_PATH like '/home/utrbot/node_modules/undertherules'>/etc/nginx/default
  ```
## Add pass for web dashboard
  ```
  sudo htpasswd -c /etc/nginx/.htpasswd undertherules
  ```
## Install global packages
  ```
  sudo npm install -g   \
        coffee-script   \
        coffee-graph    \
        clog-analysis   \
        foreman         \
  ```
## Data-Sources
* [Instagram](https://www.instagram.com/developer/), Examples: [video](https://www.instagram.com/p/BLEkdVVjbUQ/)
* [Facebook](https://developers.facebook.com/docs/), Examples: [video](https://facebook.com/bono.appetito/videos/1016876628404543/)
* [YouTube](https://developers.google.com/youtube/v3/), Examples: [video](https://www.youtube.com/watch?v=ql2GIq1qHvo), [video](https://youtu.be/ql2GIq1qHvo)
* [Coub](https://coub.com/dev/docs/Coub+API/Overview)
* [VKontakte](https://vk.com/dev/), Examples: [video](https://vk.com/video-32194285_456239404)
* [MyMail](http://api.mail.ru), Examples: [video](http://my.mail.ru/community/bon.appetit/video/_groupvideo/820.html)        
* [Odnoklassniki](http://new.apiok.ru), Examples: [video](https://ok.ru/video/81684204187)
* [Foursquare](https://developer.foursquare.com)
* [Twitter](https://dev.twitter.com/rest/public)
* [Vimeo](https://developer.vimeo.com)

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
  * [BOTAN.IO](http://botan.io) - The most advanced analytics for your Telegram bot.
  * Tests using telegtam-cli

## Hardware
  * [DigitalOcean](https://m.do.co/c/e4bc7eb8bf03) -  is a simple and robust cloud computing platform.
  * [Flops](https://flops.ru/?refid=18288) - Technologies used in [FLOPS](https://flops.ru/?refid=18288), are at the forefront of the web hosting industry.
  * [Twilio](https://www.twilio.com) - Build apps that communicate with everyone in the world. Voice & Video, Messaging, and Authentication APIs for every application.
  * class CreateJob
  * Add Russian & Hebrew comments in the code.
  * Create bot for flops.ru
  * Add new links from: vk.com/big.data

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
