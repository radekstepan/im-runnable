#InterMine Runnable [![Built with Grunt](https://cdn.gruntjs.com/builtwith.png)](http://gruntjs.com/)

Learn you some InterMine Web Services for good.

![image](https://raw.github.com/radekstepan/im-runnable/master/example.png)

##Quickstart

[Install Docker](https://www.docker.io/gettingstarted/) and test all is well:

```bash
$ docker run ubuntu /bin/echo hello world
```

Create an image that you want to run against:

```bash
$ docker run -i -t ubuntu /bin/bash
```

Once inside, install [Node.js](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager) etc.

While your container is still running, get its id and save it as an image:

```bash
$ docker commit <id> imjs
$ docker images
```

Now we have an image saved under `imjs`. You can now exit from the container.

Start the service:

```bash
$ sudo PORT=5000 node index.js
```

You need to be in priviledged mode to run `docker` commands. Port is being specified by passing it as an env variable.

Now you can post some code and get results back:

```coffeescript
#!/usr/bin/env coffee
restify = require 'restify'

client = restify.createJsonClient
    'url': 'http://0.0.0.0:5000'

client.post '/api/run',
    'cmd': 'node'
    'src': 'console.log(3*6)'
, (err, req, res, body) ->
    throw err if err

    console.log body
```