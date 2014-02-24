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
    'lang': 'javascript'
    'src':  'console.log(3*6)'
, (err, req, res, body) ->
    throw err if err

    console.log body
```

###API Design

1. Use plural nouns, not verbs.
1. Provide a `message` when handling errors.
1. Only 3 levels of depth when showing associations, e.g.: `/owners/123/dogs`.
1. All responses contain a `responseCode`.
1. Be able to override status codes and always return `200` in the header but not in the body; use `?suppress_response_codes=true`.
1. Codes:
    - 200 OK
    - 201 Created: when submitting new items
    - 400 Bad Request: it is the client's fault, like params not provided
    - 401 Not Authorized: you can access this page, but your token is no good
    - 404 Not Found
    - 500 Internal Server Error: client is fine, we are at fault
1. Do versioning, but do not change versions often.
1. Never respond with a JSON Array, always an Object.
1. Allow people to specify format in a suffix `.json`, but default to JSON.
1. Specify which fields to return using query param `?fields=name,color`.
1. When returning a listing of many things, return only a partial and assume that `?limit=10&offset=0`. Metadata related to total count, limit & offset should be returned under `metadata` key in response.
1. Search is done by appending `?q=wulfie` to the resource or `/search?q=wulfie` for a global one.
1. When returning timestamps use `toJSON()` so we can nicely debug in the browser.
1. Key names in responses (JSON) need to follow the same pattern as those in URLs so `created_at`.
1. When creating objects, it should return them.
1. When returning an object or an array, return it under `data` key.
1. Support trailing slashes in urls.