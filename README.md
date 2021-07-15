# Docker bitcoin

Dockerfile of the public image [ghcr.io/vulpemventures/bitcoin:latest](https://github.com/orgs/vulpemventures/packages/container/package/bitcoin)


Pull the image:

```bash
$ docker pull ghcr.io/vulpemventures/bitcoin:latest
```

Run the image:

```bash
$ docker run -v path/to/bitcoin.conf:/home/bitcoin/.bitcoin -d ghcr.io/vulpemventures/bitcoin:latest
```
