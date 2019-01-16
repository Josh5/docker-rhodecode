## Usage

```
PROJECT_NAME=rhodecode
DOCKER_ENV_DIR=/home/${USER}/appdata/${PROJECT_NAME}
REPOS_DIR=/repos

docker stop ${PROJECT_NAME}
docker rm ${PROJECT_NAME}
docker pull josh5/rhodecode:latest
 
docker create --name=${PROJECT_NAME} \
-p 10021:10021 \
-p 10020:10020 \
-e PGID=1000 -e PUID=1000  \
-v "${DOCKER_ENV_DIR}":"/config":rw \
-v "${REPOS_DIR}":"/repos":rw \
-v "${DOCKER_ENV_DIR}/tmp":"/tmp":rw \
--restart unless-stopped \
josh5/rhodecode:latest
 
docker restart ${PROJECT_NAME}
```


## Upgrading from a previous version
If this is an upgrade, you will need to manually execute the database migration script.

I've made this simple. 

First make sure the updated container is created and running.

Next check your `.rccontrol/community-1/rhodecode.ini` config for changes and manually migrate in any relevant settings.
You will find a copy of this versions default config in `.rccontrol/community-1/rhodecode_default.ini`

Finally, run this command:

```
# Ensure the project name matches the name of your created container
PROJECT_NAME=rhodecode
docker exec -ti ${PROJECT_NAME} /upgrade-db
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