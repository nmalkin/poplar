express = require 'express'
fs = require 'fs'
hogan = (require 'consolidate').hogan
redis = (require 'redis-url').connect(process.env.REDISTOGO_URL)
uuid = (require 'node-uuid').v4

config = JSON.parse fs.readFileSync 'config.json', 'utf8'

DEFAULT_ICON = 'http://' + config.host + '/poplar.svg'
manifestURL = (id) ->
    'http://' + id + '.' + config.host + '/app.manifest'

app = express()
app.engine 'html', hogan
app.use express.logger()
app.use express.bodyParser()

isRootHost = (host) ->
    (host == config.host) or (host == ('www.' + config.host))


app.all '*', (req, res, next) ->
    if isRootHost req.host
        next()
    else # request for a specific application
        console.log req.host
        idExpr = new RegExp("^([\-\\w]+).#{ config.host }$")
        id = idExpr.exec req.host
        console.log id
        if id?
            id = id[1]
            redis.hgetall id, (err, mozapp) ->
                if err?
                    res.send 500
                else
                    if mozapp?
                        if req.path == '/'
                            res.render 'app.html',
                                url: mozapp.url
                                name: mozapp.name
                                description: mozapp.description
                                icon: mozapp.icon
                        else if req.path == '/app.manifest'
                            res.type 'application/x-web-app-manifest+json'
                            res.json
                                name: mozapp.name
                                description: mozapp.description
                                icons:
                                    "128": mozapp.icon
                        else
                            res.send 404
        else
            res.send 400


# Anything at this point is being served from the root host 

app.get '*', express.static __dirname + '/public'

app.post '/create', (req, res) ->
    url = req.body.url
    name = req.body.name
    icon = req.body.icon

    if not (url? and url != '' and name? and name != '')
        res.json
            status: 'failure'
            message: 'Missing app URL and/or name'
        return

    if not (icon? and icon != '')
        icon = DEFAULT_ICON

    id = uuid()
    redis.hmset id,
        url: url
        name: name
        icon: icon
    , (err) ->
        if err?
            res.json
                status: 'failure'
                message: err
        else
            res.json
                status: 'success'
                manifest: manifestURL id


app.all '*', (req, res) ->
    res.send 404

app.listen process.env.PORT || 8111
