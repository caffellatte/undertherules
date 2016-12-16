# Under the rules of Sociometry

> Track, find, mining, parsing & analyzing data from social networks.

Software provides nimble web-data operations.
Current state: Development version.

## Stack

  * Tested on Debian 8.5 x64 powered by [flops](https://flops.ru/?refid=18288) cloud-hosting.
  * [CoffeeScript](http://coffeescript.org) is a little language that compiles into JavaScript.

## Environment

### Install system packages
```
  apt-get install curl build-essential htop mc git-core tree
```

### Create new user
```
  useradd --home-dir /home/bot --create-home --shell /bin/bash bot
  usermod -g staff bot
```

### Install npm global packages
```
  npm install -g coffee-script foreman
```

### Clone package from github
```
  git clone https://github.com/caffellatte/undertherules.git
```

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
