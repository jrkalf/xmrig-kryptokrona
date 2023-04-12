[![Docker Image CI](https://github.com/jrkalf/xmrig-kryptokrona/actions/workflows/docker-image.yml/badge.svg)](https://github.com/jrkalf/xmrig-kryptokrona/actions/workflows/docker-image.yml)
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield]
![Maintenance][maintenance-shield]
![GitHub commit activity][activity-shield]

# XMRig miner image for Kryptokrona
Kryptokrona (XKR) CPU miner packaged in a lightweight Docker image that you can easily deploy to a Kubernetes cluster or your docker environment using docker compose.

## What is XMRig?
[XMRig](https://xmrig.com/miner) is a high performance, open source, cross platform RandomX, KawPow, CryptoNight and AstroBWT unified CPU/GPU miner and RandomX benchmark. It supports [Kryptokrona](https://kryptokrona.org), [Monero](https://www.getmonero.org/), among other cryptocurrencies. 

This Docker image was built with the latest XMRig version from source on Ubuntu Linux and it is only 29 MB in size. It's immutable and supports your own donate level and timezone. You can easily deploy it as a standalone Docker container, or to a Kubernetes cluster in minutes.


## Quick reference
- **Maintained by**: [Jelle Kalf](https://github.com/jrkalf)
- **Supported architectures**: `amd64`,`arm64v8`,`arm32v7`
- **Supported tags**: `latest`, `v6.19.2`


## How to use this image

**Step 1:** Clone the GitHub repo:
```
$ git clone https://github.com/jrkalf/xmrig-kryptokrona.git
```

**Step 2:** Edit the `config.json` file after cloning it. 
- Provide your pool configuration:
  - url: techy.ddns.net:3333 (or any pool from https://miningpoolstats.stream/kryptokrona)
  - user: [wallet address](https://www.kryptokrona.org/en/wallet)
  - pass: the identifier for your miner

If you are feeling generous, set the `donate-level` greater than 0:
```
"pools": [
    {
        "url": "techy.ddns.net:3333",
        "user": "SEKReXJnqiwiV3Bv6mvfR2ESmLbZjZG2QKDKiywrjwNtU1a1zcJT4Lni72rUS6rUoMU9uP8Eczhg966T9n1jELmVc6Ln8SdYQNp",
        "pass": "external-users",
        "keepalive": true,
        "nicehash": false,
        "variant": "trtl",
        "algo": "cryptonight-pico/trtl"
    }
],
"donate-level": 0,
"donate-over-proxy": 0,
```
For all the available options, visit [XMRig Config File](https://xmrig.com/docs/miner/config) documentation. 

**Step 3:** Deploy the image as a standalone Docker container or to a Kubernetes cluster.

### Docker
```
$ docker run -dit --rm \
    --volume "$(pwd)"/config.json:/xmrig/etc/config.json:ro \
    --volume "$(pwd)"/log:/xmrig/log \
    --name xmrig jrkalf/xmrig-kryptokrona:latest \
    /xmrig/xmrig --config=/xmrig/etc/config.json
```
If you prefer **Docker Compose**, edit the [`docker-compose.yml`](https://github.com/jrkalf/xmrig-kryptokrona/blob/main/docker-compose.yml) manifest as needed and run:
```
$ docker-compose up -d
```

### Kubernetes

**Step 1:** Create a *namespace* for our XMRig application (optional but recommended):
```
$ kubectl create ns kryptokrona
``` 
**Step 2:** Create a *configmap* in the new namespace `kryptokrona` from the [`config.json`](https://github.com/jrkalf/xmrig-kryptokrona/blob/main/config.json) file:
```
$ kubectl create configmap kryptokrona-config --from-file config.json -n kryptokrona
```
*remember to edit this file with your own pool configuration and wallet address or it will mine against my anonimised docker wallet*

**Step 3:** Edit the [`deployment.yaml`](https://github.com/jrkalf/xmrig-kryptokrona/blob/main/deployment.yaml) file. Things you may want to modify include:
- `replicas`: number of desired pods to be running. As I run a 3 worker node Turing Pi cluster, I run 3 replica's
- `image:tag`: to view all available versions, go to the [Tags](https://hub.docker.com/repository/docker/jrkalf/xmrig-kryptokrona/tags) tab of the Docker Hub repo.
- `resources`: set appropriate values for `cpu` and `memory` requests/limits.
- `affinity`: the manifest will schedule only one pod per node, if that's not the desired behavior, remove the `affinity` block.

**Step 4:** Once you are satisfied with the above manifest, create a *deployment*:
```
$ kubectl -f apply deployment.yaml
```

## Logging
This Docker image sends the container logs to the `stdout`. To view the logs, run:

```
$ docker logs kryptokrona
```

For Kubernetes run:
```
$ kubectl logs --follow -n kryptokrona <pod-name> 
```
### Persistent logging
Containers are stateless by nature, so their logs will be lost when they shut down. If you want the logs to persist, enable XMRig syslog output in the [`config.json`](https://github.com/jrkalf/xmrig-kryptokrona/blob/main/config.json) file: 
```
"syslog": true,
"log-file": "/xmrig/log/xmrig.log",
```
And give full permissions to the directory on the host machine:
```
$ chmod 777 "$(pwd)"/log
```

Then use either **Docker** [bind mounts](https://docs.docker.com/storage/bind-mounts/) or **Kubernetes** [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) to keep the log file on the host machine. The `docker run` command above and the [`docker-compose.yml`](https://github.com/jrkalf/xmrig-kryptokrona/blob/main/docker-compose.yml) file already includes this mapping. 


## Disclaimer
Use at your own discression. This repository is by no means financial advise to mine cryptocurrency. 
This is a project to learn how to build containerised applications.

## License
The Docker image is licensed under the terms of the [MIT License](https://github.com/jrkalf/xmrig-kryptokrona/blob/main/LICENSE). XMRig is licensed under the GNU General Public License v3.0. See its [`LICENSE`](https://github.com/xmrig/xmrig/blob/master/LICENSE) file for details.

## Used works from other repositories
This repo is a based on works of:
- [Roberto Meléndez](https://github.com/rcmelendez/xmrig-docker) for XMRIG for Monero
- [Bufanda](https://github.com/bufanda/docker-xmrig)

## Contact 
- Find me on Kryptokrona's [Hugin Messenger](https://hugin.chat) at addres `SEKReT7odTKSJjXs9BqKAwAEZhW8XuiowdFd4MjTUidc11fur3TpGjPeKKqaCzZdbF3YBf1RfqFowD8WrWAei5grQXb8fXujX7K`.
- Find me on [GitHub](https://github.com/jrkalf/), [Mastodon](https://mastodon.nl/@jelle77) or [Twitter](https://twitter.com/jkalf).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[activity-shield]: https://img.shields.io/github/commit-activity/y/jrkalf/xmrig-kryptokrona
[maintenance-shield]: https://img.shields.io/maintenance/yes/2023
