# cluster.coffee

# Modules - Модули
_             = require('lodash') # Библиотека Полезных Функций и Операций
fs            = require('fs-extra') # Работа с Файловой Системой
os            = require('os') # Взаимодействие с Операционной Системой
kue           = require('kue') # Автоматизированная Очередь
pug           = require('pug') # Перевод из *.pug в *.html
url           = require('url') # Форматирование и Парсинг URL ссылок
http          = require('http') # HTTP/HTTPS Сервер
shoe          = require('shoe') # Прокси
dnode         = require('dnode') # Клиент-Сервер для связи с браузером Клиента
level         = require('levelup') # База Данных
crypto        = require('crypto') # Криптографические функции (хеш-функции)
stylus        = require('stylus') # Перевд из  *.styl в *.css
natural       = require('natural') # Библиотека для обработки текста
cluster       = require('cluster') # Управление процессами
request       = require('request') # HTTP/HTTPS запросы
coffeeify     = require('coffeeify') # Перевод из *.coffee в *.js
browserify    = require('browserify') # Загрузчик (транспайлер)
querystring   = require('querystring') # Форматирование и Разбор URL-ссылокок
child_process = require('child_process') # Создание дочерних процессов

# # Functions - Функции
# {exec} = child_process # Функйия для Выполнение команд средствами ОС
# {writeFileSync, readFileSync} = fs # Синхронное чтение и запись в файл
# {removeSync, mkdirsSync, copySync, ensureDirSync} = fs # Удаление, Создание...

# # Environment - Окружение
# numCPUs = require('os').cpus().length # Количество Процессорв
# # Загрузка значений из файла конфигурации окружения .env (Часть 1)
# CORE_DIR   = process.env.CORE_DIR
# LEVEL_DIR  = process.env.LEVEL_DIR
# STATIC_DIR = process.env.STATIC_DIR
# HTDOCS_DIR = process.env.HTDOCS_DIR
# USER_AGENT = process.env.USER_AGENT
# KUE_PORT   = process.env.KUE_PORT
# KUE_HOST   = process.env.KUE_HOST
# PANEL_PORT = process.env.PANEL_PORT
# PANEL_HOST = process.env.PANEL_HOST
# IG_COOKIE  = process.env.IG_COOKIE
# DOMAIN     = process.env.DOMAIN
# # Загрузка значений из файла конфигурации окружения .env (Часть 2)
# KUE_PORT   = process.env.KUE_PORT
# KUE_HOST   = process.env.KUE_HOST
# PANEL_PORT = process.env.PANEL_PORT
# PANEL_HOST = process.env.PANEL_HOST
# IG_COOKIE  = process.env.IG_COOKIE

# # Files - Файлы
# # -- Дирректория для хранения сторонних библиотек для исполнения в браузере -- #
# staticJs          = "#{STATIC_DIR}/js" # Сторонние библиотеки
# staticImg         = "#{STATIC_DIR}/img" # Дирректория с Картинками
# staticFaviconIco  = "#{STATIC_DIR}/favicon.ico" # Иконка для браузера
# indexHtml         = "#{STATIC_DIR}/index.html"  # с помощью pug
# styleCss          = "#{STATIC_DIR}/style.css" #  с помощью stylus
# bundleJs          = "#{STATIC_DIR}/bundle.js" # coffeeify и browserify
# # -------------------------------------------------------------------------- #

# # ------------- Исходные Файлы для Генерации Клиентского Кода --------------- #
# htdocsJs          = "#{HTDOCS_DIR}/js" # Сторонние библиотеки
# htdocsImg         = "#{HTDOCS_DIR}/img" # Дирректория с Картинками
# browserCoffee     = "#{HTDOCS_DIR}/client.coffee" # Клиент (Исходник)
# htdocsFaviconIco  = "#{HTDOCS_DIR}/img/favicon.ico" # Иконка для браузера
# templatePug       = "#{HTDOCS_DIR}/template.pug" # Исходники для  *.html файлов
# styleStyl         = "#{HTDOCS_DIR}/style.styl" # Исходники для  *.css файлов
# clusterCoffee     = "#{CORE_DIR}/cluster.coffee" # Сервер
# # -------------------------------------------------------------------------- #

# # Queue - Очередь
# queue = kue.createQueue() # Экземпляр (*KUE*) для управления очередью

# # Server - Сервер
# class Server
#   # Поиск строки с помощью регулярного выражения и библиотеки natural
#   @tokenizer:new natural.RegexpTokenizer({pattern:/(https?:\/\/[^\s]+)/g})

#   @SingUp:(mail, name, pass, cb) => # Регистрация Нового Аккаунта
#     queue.create('email', {
#       title: 'welcome email for tj',
#       to: 'tj@learnboost.com',
#       template: 'welcome-email'}).save()
#     cb("mail: #{mail}, name: #{name}, pass: #{pass}")

#   @SingIn:(user, pass, cb) => # Вход в аккаунт (имя/почта:пароль)
#     cb("user: #{user}, pass: #{pass}")

#   @inputMessage:(user_id, msg, cb) => # Входящее сообщение
#     cb("#{user_id}, #{msg}")

#   @browserify:(job, done) -> # Клиентский код на coffee преабразуется в js
#     console.log("PID: #{process.pid}\t@browserify")
#     {browserCoffee, bundleJs} = job.data # Путь к исходнику и путь для экспорта
#     bundle = browserify({extensions:['.coffee']}) # Указываем расширение
#     bundle.transform(coffeeify, {
#       bare:false # Не оборачивать в анаимную функцию
#       header:false # Помещаем скрипт в body
#     })
#     bundle.add(browserCoffee) # Добавляем файл в экземпляр
#     bundle.bundle((error, js) -> # Собираем bundle.js
#       throw error if error? # Проверка на ошибку
#       writeFileSync(bundleJs, js)
#       done()
#     )

#   @coffeelint:(job, done) -> # Проверка кода (статистический анализ)
#     console.log("PID: #{process.pid}\t@coffeelint")
#     {files} = job.data # Список Файлов для Анализа
#     command = 'coffeelint ' + "#{files.join(' ')}" # Формирем команду
#     exec(command, (err, stdout, stderr) -> # Выполняем комманду сркдствами ОС
#       console.log(stdout, stderr) # Выводим результат
#       done()
#     )

#   @pugRender:(job, done) -> # Рендерим HTML шаблон
#     console.log("PID: #{process.pid}\t@pugRender")
#     {templatePug, indexHtml} = job.data # Путь к исходнику и путь для экспорта
#     writeFileSync(indexHtml, pug.renderFile(templatePug, {pretty:true}))
#     # Записываем результат в файл, выбираем читабельный формат
#     done()

#   @static:(job, done) -> # Cоздаем файловую структуру
#     console.log("PID: #{process.pid}\t@static")
#     {htdocsFaviconIco, staticFaviconIco, htdocsImg, staticImg} = job.data
#     mkdirsSync(job.data.STATIC_DIR)
#     mkdirsSync("#{job.data.STATIC_DIR}/files")
#     copySync(htdocsJs, staticJs)
#     copySync(htdocsImg, staticImg)
#     copySync(htdocsFaviconIco, staticFaviconIco)
#     done()

#   @stylusRender:(job, done) ->
#     console.log("PID: #{process.pid}\t@stylusRender")
#     {styleStyl, styleCss} = job.data
#     handler = (err, css) ->
#       if err then throw err
#       writeFileSync(styleCss, css)
#     content = readFileSync(styleStyl, {encoding:'utf8'})
#     stylus.render(content, handler)
#     done()

#   @email:(job, done ) -> """echo "test" | mail -aFrom:root@#{DOMAIN} #{mail}"""
#     console.log("PID: #{process.pid}\t@email")
#     {files} = job.data # Список Файлов для Анализа
#     command = 'coffeelint ' + "#{files.join(' ')}" # Формирем команду
#     exec(command, (err, stdout, stderr) -> # Выполняем комманду сркдствами ОС
#       console.log(stdout, stderr) # Выводим результат
#       done()
#     )

# # Master
# if cluster.isMaster

# ## Kue
#   kue.app.set('title', 'Under The Rules')
#   kue.app.listen(KUE_PORT, KUE_HOST, ->
#     console.log("Kue: http://#{KUE_HOST}:#{KUE_PORT}.")
#     kue.Job.rangeByState('complete', 0, 100000, 'asc', (err, jobs) ->
#       jobs.forEach((job) ->
#         job.remove( -> return
#         )
#       )
#     )
#   )

# ## Ecstatic is a simple static file server middleware.
#   ecstatic = require('ecstatic')(STATIC_DIR)
#   server   = http.createServer(ecstatic) # Create a HTTP server.

# ## Starting Dnode. Using dnode via shoe & Install endpoint
#   server.listen(PANEL_PORT, PANEL_HOST, ->
#     console.log("Dnode: http://#{PANEL_HOST}:#{PANEL_PORT}")
#   )
#   graph = level(LEVEL_DIR + '/graph', {type:'json'})
#   sock = shoe((stream) -> # Define API object providing integration vith dnode
#     d = dnode({
#       inputMessage:Server.inputMessage,
#       inputMessage:Server.SingUp
#     })
#     d.pipe(stream).pipe(d)
#   )
#   sock.install(server, '/dnode')
#   ensureDirSync(LEVEL_DIR)


# ## Create Jobs
#   staticJob = queue.create('static', {
#     title:'Copy images from HTDOCS_DIR to STATIC_DIR',
#     STATIC_DIR:STATIC_DIR,
#     htdocsFaviconIco:htdocsFaviconIco,
#     staticFaviconIco:staticFaviconIco,
#     htdocsImg:htdocsImg
#     staticImg:staticImg
#   }).save()

#   staticJob.on('complete', ->
#     queue.create('pugRender', {
#       title:'Render (transform) pug template to html',
#       templatePug:templatePug,
#       indexHtml:indexHtml
#     }).delay(1).save()

#     queue.create('stylusRender', {
#       title:'Render (transform) stylus template to css',
#       styleStyl:styleStyl,
#       styleCss:styleCss
#     }).delay(1).save()

#     queue.create('browserify', {
#       title:'Render (transform) coffee template to js',
#       browserCoffee:browserCoffee,
#       bundleJs:bundleJs
#     }).delay(1).save()

#     queue.create('coffeelint', {
#       title:'Link coffee files',
#       files:[clusterCoffee, browserCoffee]
#     }).delay(1).save() # browserCoffee

#   )

# ## **Clean** job list on exit add to class
#   exitHandler = (options, err) ->
#     if err
#       console.log(err.stack)
#     if options.exit
#       process.exit()
#       return
#     if options.cleanup
#       console.log('Buy!')
#       removeSync(STATIC_DIR)

# ## Do something when app is closing or ctrl+c event or uncaught exceptions
#   process.on('exit', exitHandler.bind(null, {cleanup:true}))
#   process.on('SIGINT', exitHandler.bind(null, {exit:true}))
#   process.on('uncaughtException', exitHandler.bind(null, {exit:true}))

#   i = 1
#   while i < numCPUs
#     cluster.fork()
#     i += 1
# # Worker
# else

#   queue.process('static', Server.static)
#   queue.process('pugRender', Server.pugRender)
#   queue.process('stylusRender', Server.stylusRender)
#   queue.process('browserify', Server.browserify)
#   queue.process('coffeelint', Server.coffeelint)
