## Usage

```
PROJECT_NAME=rhodecode
DOCKER_ENV_DIR=/home/${USER}/appdata/${PROJECT_NAME}
REPOS_DIR=/repos

docker stop ${PROJECT_NAME}
docker rm ${PROJECT_NAME}
docker pull josh5/rhodecode:latest
 
docker create --name=${PROJECT_NAME} \
-p 10010:10010 \
-p 10020:10020 \
-e PGID=1000 -e PUID=1000  \
-v "${DOCKER_ENV_DIR}":"/config":rw \
-v "${REPOS_DIR}":"/repos":rw \
--restart unless-stopped
josh5/rhodecode:latest
 
docker restart ${PROJECT_NAME}
```

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

Recommended configuration is as follows:

```
{PROJECT_NAME}          - The name of the container
{DOCKER_ENV_DIR}        - The location where RhodeCode's configuration is stored
{REPOS_DIR}             - The location of the Mercurial and GIT repos.

Adding the "--restart unless-stopped" flag on container creation will start the container on system startup
```