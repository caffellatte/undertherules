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
dnode         = require('dnode') # Сокет для связи с Клиент-Сервер
level         = require('levelup') # База Данных
crypto        = require('crypto') # Криптографические функции (и хеш-функции)
stylus        = require('stylus') # Перевд из  *.styl в *.css
natural       = require('natural') # Библиотека для обработки текста
cluster       = require('cluster') # Управление процессами
request       = require('request') # HTTP/HTTPS запросы
coffeeify     = require('coffeeify') # Перевод из *.coffee в *.js
browserify    = require('browserify') # Загрузчик библиотек в браузер
querystring   = require('querystring')  # Обработка URL-ссылок
child_process = require('child_process') # Создание дочерних процессов
#
# # Functions
# # Функйия для Выполнение команд средствами ОС в отдельном процессе
# {exec} = child_process
# # Синхронное чтение и запись в файл
# {writeFileSync, readFileSync} = fs
# # Удаление, Создание, Коприрование и Проверка на существование Директорий.
# {removeSync, mkdirsSync, copySync, ensureDirSync} = fs
#
# # Environment
# # Количество Процессорв
# numCPUs = require('os').cpus().length
# # Загрузка значений из файла конфигурации окружения .env (Часть 1)
# {CORE_DIR, LEVEL_DIR, STATIC_DIR, HTDOCS_DIR, USER_AGENT} = process.env
# # Загрузка значений из файла конфигурации окружения .env (Часть 2)
# {KUE_PORT, KUE_HOST, PANEL_PORT, PANEL_HOST, IG_COOKIE} = process.env
#
# # Files
#
# # Файл выполняемый на стороне сервера с помощь JavaScript движка NodeJs
# clusterCoffee     = "#{CORE_DIR}/cluster.coffee"
#
# # -- Дирректория для хранения сторонних библиотек для исполнения в браузере -- #
# # Генерируемые файлы и директории для загрузки на сторону клиент брауер #
# staticJs          = "#{STATIC_DIR}/js"
# # Дирректория с Картинками
# staticImg         = "#{STATIC_DIR}/img"
# # Иконка для браузера
# staticFaviconIco  = "#{STATIC_DIR}/favicon.ico"
# # Динамически генирируемый файл с базовым  DOM дерево с помощью pug
# indexHtml         = "#{STATIC_DIR}/index.html"
# # Динамически генирируемый файл с Каскадные Таблицы Стилей с помощью stylus
# styleCss          = "#{STATIC_DIR}/style.css"
# # Динамически генирируемый файл с помощью coffeeify и browserify
# bundleJs          = "#{STATIC_DIR}/bundle.js"
# # -------------------------------------------------------------------------- #
#
# # ------------- Исходные Файлы для Генерации Клиентского Кода --------------- #
# # Директория содержит сторонние библиотеки для выполнения на стороне браузера
# htdocsJs          = "#{HTDOCS_DIR}/js"
# # Дирректория с Картинками
# htdocsImg         = "#{HTDOCS_DIR}/img"
# # Файл для исполнения браузером клиента (Исходный код)
# browserCoffee     = "#{HTDOCS_DIR}/browser.coffee"
# # Иконка для браузера
# htdocsFaviconIco  = "#{HTDOCS_DIR}/img/favicon.ico"
# # Исходники для генерации  *.html файлов
# templatePug       = "#{HTDOCS_DIR}/template.pug"
# # Исходники для генерации  *.css файлов
# styleStyl         = "#{HTDOCS_DIR}/style.styl"
#
# # Queue
# # Создание Экземпляра (Объект) для Управления Автоматизированной Очередью *KUE*
# queue = kue.createQueue()
#
# # Cluster
# class Cluster
#   # Поиск строки с помощью регулярного выражения и библиотеки natural
#   @tokenizer:new natural.RegexpTokenizer({pattern:/(https?:\/\/[^\s]+)/g})
#   # Функция Начала Регистрации Нового Пользователя (Dnode API)
#   @dnodeSingUp:(guid, cb) ->
#     console.log("PID: #{process.pid}\t{#{guid}}\t@dnodeSingUp")
#     # Проверка аргумента cb с помощью  -typeof - является ли он функцией
#     if typeof cb isnt 'function'
#       # если не функция завершит выполнеие задачи
#       return
#     # Проверка guid на существование если нет, то возвращаем в cb ощибку
#     if not guid? then cb('Error!')
#     # Генерируем хэш с помощью библиотеки crypto (md5) берем хеш от guid
#     graphId = crypto.createHash('md5').update("#{guid}}").digest('hex')
#     # создаем переменную value
#     value = {
#       #
#       graphId:graphId
#       #
#       guid:guid
#       #
#       timestamp:"#{new Date()}"
#       #
#       ready:0
#     }
#     graph.put(graphId, JSON.stringify(value), (err) ->
#       if not err then  cb(null, value) else cb(new Error(err))
#     )
#     cb(graphId)
#
#   @dnodeSingIn:(graphId, passwd, cb) ->
#     if typeof cb isnt 'function'
#       return
#     console.log("PID: #{process.pid}\t[#{graphId}]\t@dnodeSingIn")
#     graph.get(graphId, (err, list) ->
#       if err
#         cb('ACCESS DENIED')
#       else
#         if list
#           cb(null, JSON.parse(list))
#         else
#           cb('ACCESS DENIED')
#     )
#
#   @dnodeUpdate:(graphId, cb) ->
#     console.log("PID: #{process.pid}\t[#{graphId}]\t@dnodeUpdate")
#     if graphId
#       count = 0
#       Log = level(LEVEL_DIR + "/#{graphId}-log") #, {type:'json'})
#       Log.createReadStream()
#         .on('data', (data) ->
#           if data.key and data.value
#             count += 1
#             cb(data)
#         )
#         .on('error', (err) ->
#           cb({key:"#{new Date()}", value:"Oh my! #{err}"})
#         )
#         .on('close', ->
#           cb({key:'count', value:count})
#         )
#         .on('end', ->
#           Log.close()
#         )
#
#   @inputMessage:(graphId, msg, cb) =>
#     if graphId and msg
#       console.log("PID: #{process.pid}\t[#{graphId}]\t@inputMessage")
#       Log = level(LEVEL_DIR + "/#{graphId}-log")
#       logKey = crypto.createHash('md5').update(msg).digest('hex')
#       Log.put(logKey, msg, (err) ->
#         if err then console.log('Ooops!', err)
#         Log.close()
#       )
#       rawArray = @tokenizer.tokenize(msg)
#       rawlinks = (url.parse(link) for link in rawArray)
#       links    = (link.href for link in rawlinks when link.hostname?)
#       for item in links
#         queue.create('mediaAnalyzer', {
#           title:"Media Analyzer. GraphID: #{graphId}."
#           graphId:graphId
#           itemUrl:item
#         }).save()
#         cb(item)
#
#   @mediaAnalyzer:(job, done) ->
#     {graphId, itemUrl} = job.data
#     command = "curl -X GET '#{itemUrl}/?__a=1' --verbose "
#     command += "--user-agent #{USER_AGENT} --cookie #{IG_COOKIE} "
#     command += "--cookie-jar #{IG_COOKIE}"
#     exec(command, (error, stdout, stderr) ->
#       if stdout
#         console.log("Received #{stdout.length} bytes.")
#         data = JSON.parse(stdout)
#         {id, follows_viewer, is_private, username} = data.user
#         Users = level(LEVEL_DIR + "/#{graphId}-ig-users", {
#           type:'json'
#         })
#         Users.put(id, data.user, {valueEncoding:'json'}, (err) ->
#           if err then console.log('Ooops!', err)
#           Users.close()
#         )
#         Nodes = level(LEVEL_DIR + "/#{graphId}-ig-nodes", {type:'json'})
#         data.user.color = '#000000'
#         Nodes.put("#{id}", data.user, {valueEncoding:'json'}, (err) ->
#           if err then console.log('Ooops!', err)
#           Nodes.close()
#         )
#         console.log("#{is_private}#{follows_viewer}")
#         switch "#{is_private}#{follows_viewer}"
#           when 'truefalse'
#             return
#           else
#             if not (is_private is true and follows_viewer is false)
#               queue.create('igConnections', {       # Followers
#                 title:'Get Instagram Followers',
#                 query_id:'17851374694183129',
#                 after:null,
#                 first:20,
#                 id:id,
#                 graphId:graphId,
#                 userName:username
#               }).delay(5).save()
#       else
#         console.log(error)
#       if stderr
#         console.error(stderr)
#       done()
#     )
#
#   @igConnections:(job, done) ->
#     {graphId, id, query_id, first, after, userName} = job.data
#     console.log("PID: #{process.pid}\t[#{graphId}]\t@igConnections")
#     params = {query_id:query_id, after:after, first:first, id:id}
#     igUrl = 'https://www.instagram.com/graphql/query/'
#     igUrl += "?#{querystring.stringify(params)}"
#     command = "curl -X GET '#{igUrl}' --verbose "
#     command += "--user-agent #{USER_AGENT} --cookie #{IG_COOKIE} "
#     command += "--cookie-jar #{IG_COOKIE}"
#     console.log('command:', command)
#     exec(command, (error, stdout, stderr) ->
#       if stdout
#         console.log("Received #{stdout.length} bytes.")
#         queue.create('igSave', {
#           title:"Save Instagram: #{query_id}.",
#           jsonData:stdout,
#           query_id:query_id,
#           id:id,
#           graphId:graphId,
#           userName:userName
#         }).delay(5).save()
#       else
#         console.log(error)
#       done()
#     )
#
#   @igSave:(job, done) ->
#     {graphId, id, jsonData, query_id, userName} = job.data
#     console.log("PID: #{process.pid}\t[#{graphId}]\t@igSave")
#     {edge_follow, edge_followed_by} = JSON.parse(jsonData).data.user
#     {page_info, edges} = edge_follow or edge_followed_by
#     {has_next_page, end_cursor} = page_info
#     flag = edge_followed_by?
#     if flag
#       query_id = '17851374694183129'
#     else
#       query_id = '17874545323001329'
#     queue.create('igSaveArray', {
#       title:"Save Array Instagram: GraphID: #{id}.",
#       flag:flag,
#       edges:edges,
#       query_id:query_id,
#       after:end_cursor,
#       first:20,
#       id:id,
#       graphId:graphId,
#       userName:userName,
#       has_next_page:has_next_page,
#       end_cursor:end_cursor
#     }).delay(5).save()
#     done()
#
#   @igSaveArray:(job, done) ->
#     {graphId, flag, edges, id, userName, has_next_page, end_cursor} = job.data
#     {query_id} = job.data
#     console.log("PID: #{process.pid}\t[#{graphId}]\t@igSaveArray")
#     if flag then target = id else source = id
#     nodesArray = ({
#       type:'put',
#       key:"#{e.node.id}",
#       value:e.node,
#       valueEncoding:'json'
#     } for e in edges)
#     edgesArray = ({
#       type:'put',
#       key:"#{source or e.node.id}-#{target or e.node.id}",
#       value:{
#         id:"#{source or e.node.id}-#{target or e.node.id}",
#         source:"#{source or e.node.id}",
#         target:"#{target or e.node.id}"
#       },
#       valueEncoding:'json'
#     } for e in edges)
#     console.log("PID: #{process.pid}\t[#{graphId}]\t@igSaveArray\tEdges")
#     Edges = level(LEVEL_DIR + "/#{graphId}-ig-edges", {type:'json'})
#     Edges.batch(edgesArray, (err) ->
#       if err then console.log('Ooops!', err)
#       console.log("PID: #{process.pid}\t[#{graphId}]\tEdges\t[OK]")
#       Edges.close()
#       console.log("PID: #{process.pid}\t[#{graphId}]\t@igSaveArray\tNodes")
#       Nodes = level(LEVEL_DIR + "/#{graphId}-ig-nodes", {type:'json'})
#       Nodes.batch(nodesArray, (err) ->
#         if err then console.log('Ooops!', err)
#         console.log("PID: #{process.pid}\t[#{graphId}]\tNodes\t[OK]")
#         Nodes.close()
#         if has_next_page
#           queue.create('igConnections', {
#             title:"Get Instagram: #{query_id}.",
#             query_id:query_id,
#             after:end_cursor,
#             first:20,
#             id:id,
#             graphId:graphId
#             userName:userName
#           }).delay(5).save()
#         else
#           queue.create('igSaveJson', {
#             title:"Get Instagram: #{query_id}.",
#             graphId:graphId,
#             query_id:query_id,
#             id:id,
#             userName:userName
#           }).delay(5).save()
#         done()
#       )
#     )
#
#   @igSaveJson:(job, done) ->
#     {graphId, query_id, id, userName} = job.data
#     ig = id
#     console.log("PID: #{process.pid}\t[#{graphId}]\t@igSaveJson\t[#{query_id}]")
#     if query_id isnt '17874545323001329'
#       queue.create('igConnections', {       # Following
#         title:'Get Instagram Followers',
#         query_id:'17874545323001329',
#         after:null,
#         first:20,
#         id:id,
#         graphId:graphId,
#         userName:userName
#       }).delay(5).save()
#       done()
#     if query_id is '17874545323001329'
#       # console.log('\nsock:', sock, '\n')
#       graphDone = 0
#       graphJson = {
#         nodes:[]
#         edges:[]
#       }
#       Nodes = level(LEVEL_DIR + "/#{graphId}-ig-nodes", {type:'json'})
#       nodeCount = -1
#       edgeCount = -1
#       nodeHash = {}
#       Nodes.createReadStream()
#         .on('data', (data) ->
#           {id, username, color} = JSON.parse(data.value)
#           if not color? then coor = '#ec5148s'
#           nodeCount += 1
#           nodeHash["#{id}"] = "n#{nodeCount}"
#           graphJson.nodes.push({
#             id:nodeHash["#{id}"],
#             ig:id,
#             label:username,
#             x:Math.floor(Math.random() * (2000 - 1) + 1),
#             y:Math.floor(Math.random() * (2000 - 1) + 1),
#             size:Math.floor(Math.random() * (10 - 1) + 1),
#             color:color
#           })
#           console.log('[Nodes]', 'nodeHash:', nodeHash["#{id}"], 'id:', id)
#         )
#         .on('error', (err) ->
#           console.log('[Nodes] Oh my!', err)
#         )
#         .on('close', ->
#           console.log('[Nodes] Stream closed')
#           Edges = level(LEVEL_DIR + "/#{graphId}-ig-edges", {type:'json'})
#           Edges.createReadStream()
#             .on('data', (data) ->
#               {source, target} = JSON.parse(data.value)
#               edgeCount += 1
#               console.log('[Edges] source', source, nodeHash[source])
#               console.log('[Edges] target', target, nodeHash[target])
#               graphJson.edges.push({
#                 id:"e#{edgeCount}",
#                 source:nodeHash["#{source}"],
#                 target:nodeHash["#{target}"]
#               })
#             )
#             .on('error', (err) ->
#               console.log('[Edges] Oh my!', err)
#             )
#             .on('close', ->
#               console.log('[Edges] Stream closed')
#               _json = JSON.stringify(graphJson, null, 2)
#               _jsonName = "#{STATIC_DIR}/files/#{graphId}.json"
#               fs.writeFile(_jsonName, _json, 'utf8', (err) ->
#                 if err then console.log(err) else console.log(_jsonName)
#               )
#             )
#             .on('end', ->
#               console.log('[Edges] Stream ended')
#               Edges.close()
#               done()
#             )
#           )
#         .on('end', ->
#           console.log('[Nodes] Stream ended')
#           Nodes.close()
#         )
#
#   @browserify:(job, done) ->
#     console.log("PID: #{process.pid}\t@browserify")
#     {browserCoffee, bundleJs} = job.data
#     bundle = browserify({extensions:['.coffee.md']})
#     bundle.transform(coffeeify, {
#       bare:false
#       header:false
#     })
#     bundle.add(browserCoffee)
#     bundle.bundle((error, js) ->
#       throw error if error?
#       writeFileSync(bundleJs, js)
#       done()
#     )
#
#   @coffeelint:(job, done) ->
#     console.log("PID: #{process.pid}\t@coffeelint")
#     {files} = job.data
#     command = 'coffeelint ' + "#{files.join(' ')}"
#     exec(command, (err, stdout, stderr) ->
#       console.log(stdout, stderr)
#       done()
#     )
#
#   @pugRender:(job, done) ->
#     console.log("PID: #{process.pid}\t@pugRender")
#     {templatePug, indexHtml} = job.data
#     writeFileSync(indexHtml, pug.renderFile(templatePug, {pretty:true}))
#     done()
#
#   @static:(job, done) ->
#     console.log("PID: #{process.pid}\t@static")
#     {htdocsFaviconIco, staticFaviconIco, htdocsImg, staticImg} = job.data
#     mkdirsSync(job.data.STATIC_DIR)
#     mkdirsSync("#{job.data.STATIC_DIR}/files")
#     copySync(htdocsJs, staticJs)
#     copySync(htdocsImg, staticImg)
#     copySync(htdocsFaviconIco, staticFaviconIco)
#     done()
#
#   @stylusRender:(job, done) ->
#     console.log("PID: #{process.pid}\t@stylusRender")
#     {styleStyl, styleCss} = job.data
#     handler = (err, css) ->
#       if err then throw err
#       writeFileSync(styleCss, css)
#     content = readFileSync(styleStyl, {encoding:'utf8'})
#     stylus.render(content, handler)
#     done()
#
#
#
# # Master
# if cluster.isMaster
#
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
#
# ## Ecstatic is a simple static file server middleware.
#   ecstatic = require('ecstatic')(STATIC_DIR)
#   server   = http.createServer(ecstatic) # Create a HTTP server.
#
# ## Starting Dnode. Using dnode via shoe & Install endpoint
#   server.listen(PANEL_PORT, PANEL_HOST, ->
#     console.log("Dnode: http://#{PANEL_HOST}:#{PANEL_PORT}")
#   )
#   graph = level(LEVEL_DIR + '/graph', {type:'json'})
#   sock = shoe((stream) -> # Define API object providing integration vith dnode
#     d = dnode({
#       dnodeUpdate:Cluster.dnodeUpdate
#       dnodeSingUp:Cluster.dnodeSingUp
#       dnodeSingIn:Cluster.dnodeSingIn
#       inputMessage:Cluster.inputMessage
#     })
#     d.pipe(stream).pipe(d)
#   )
#   sock.install(server, '/dnode')
#   ensureDirSync(LEVEL_DIR)
#
#
# ## Create Jobs
#   staticJob = queue.create('static', {
#     title:'Copy images from HTDOCS_DIR to STATIC_DIR',
#     STATIC_DIR:STATIC_DIR,
#     htdocsFaviconIco:htdocsFaviconIco,
#     staticFaviconIco:staticFaviconIco,
#     htdocsImg:htdocsImg
#     staticImg:staticImg
#   }).save()
#
#   staticJob.on('complete', ->
#     queue.create('pugRender', {
#       title:'Render (transform) pug template to html',
#       templatePug:templatePug,
#       indexHtml:indexHtml
#     }).delay(1).save()
#
#     queue.create('stylusRender', {
#       title:'Render (transform) stylus template to css',
#       styleStyl:styleStyl,
#       styleCss:styleCss
#     }).delay(1).save()
#
#     queue.create('browserify', {
#       title:'Render (transform) coffee template to js',
#       browserCoffee:browserCoffee,
#       bundleJs:bundleJs
#     }).delay(1).save()
#
#     queue.create('coffeelint', {
#       title:'Link coffee files',
#       files:[clusterCoffee, browserCoffee]
#     }).delay(1).save() # browserCoffee
#
#   )
#
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
#
# ## Do something when app is closing or ctrl+c event or uncaught exceptions
#   process.on('exit', exitHandler.bind(null, {cleanup:true}))
#   process.on('SIGINT', exitHandler.bind(null, {exit:true}))
#   process.on('uncaughtException', exitHandler.bind(null, {exit:true}))
#
#   i = 1
#   while i < numCPUs
#     cluster.fork()
#     i += 1
# # Worker
# else
#
#   queue.process('static', Cluster.static)
#   queue.process('pugRender', Cluster.pugRender)
#   queue.process('stylusRender', Cluster.stylusRender)
#   queue.process('browserify', Cluster.browserify)
#   queue.process('mediaAnalyzer', Cluster.mediaAnalyzer)
#   queue.process('igSave', Cluster.igSave)
#   queue.process('igSaveJson', Cluster.igSaveJson)
#   queue.process('igSaveArray', Cluster.igSaveArray)
#   queue.process('igConnections', Cluster.igConnections)
#   queue.process('coffeelint', Cluster.coffeelint)
