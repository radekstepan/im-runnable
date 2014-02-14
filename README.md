#im-runnable

Learn you some InterMine Web Services for good.

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

To run commands against this image:

```bash
$ coffee exec.coffee <script>
```

Where script is the name of the script in the `/scripts` directory. So to run a simple test:

```bash
$ coffee exec.coffee test.js
```

You should see the result and the time it took to run this command.