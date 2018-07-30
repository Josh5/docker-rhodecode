FROM josh5/base-alpine:3.7


ARG RHODECODE_VERSION=NzA2MjdhN2E2ODYxNzY2NzZjNDA2NTc1NjI3MTcyNzA2MjcxNzIyZTcwNjI3YQ==
ARG VCSSERVER_URL=https://dls.rhodecode.com/linux/RhodeCodeVCSServer-4.12.4+x86_64-linux_build20180716_1700.tar.bz2
ARG COMMUNITY_URL=https://dls.rhodecode.com/linux/RhodeCodeCommunity-4.12.4+x86_64-linux_build20180716_1700.tar.bz2


# install RhodeCode
ENV \
    RHODECODE_USER=admin \
    RHODECODE_USER_PASS=password \
    RHODECODE_USER_EMAIL=support@email.com \
    RHODECODE_DB=sqlite \
    RHODECODE_REPO_DIR=/repos \
    RHODECODE_VCS_PORT=10021 \
    RHODECODE_HTTP_PORT=10020 \
    RHODECODE_HOST=0.0.0.0 \
    RCCONTROL=/root/.rccontrol-profile/bin/rccontrol

RUN \
    echo "**** install base packages ****" && \
        apk update && \
        apk add --no-cache \
            logrotate \
            openssl \
            python3 \
            mercurial \
            git \
            wget \
            curl \
            nano \
            sudo \
    && \
    echo "**** install rhodecode ****" && \
        mkdir -p /repos && \
        mkdir -p /root/.rccontrol/cache && \
        cd /root/.rccontrol/cache && \
        wget ${VCSSERVER_URL} && \
        wget ${COMMUNITY_URL} && \
        cd /tmp/ && \
        wget --content-disposition https://dls-eu.rhodecode.com/dls/${RHODECODE_VERSION}/rhodecode-control/latest-linux-ce && \
        INSTALLER=$(ls -Art /tmp/RhodeCode-installer-* | tail -n 1) && \
        chmod +x ${INSTALLER} && \
        ${INSTALLER} --accept-license --create-install-directory --as-root && \
        ${RCCONTROL} self-init && \
    echo "**** setup rhodecode servers ****" && \
        ${RCCONTROL} install VCSServer --accept-license '{"host":"'"$RHODECODE_HOST"'", "port":'"$RHODECODE_VCS_PORT"'}' --version 4.12.4 --offline && \
        ${RCCONTROL} install Community --accept-license '{"host":"'"$RHODECODE_HOST"'", "port":'"$RHODECODE_HTTP_PORT"', "username":"'"$RHODECODE_USER"'", "password":"'"$RHODECODE_USER_PASS"'", "email":"'"$RHODECODE_USER_EMAIL"'", "repo_dir":"'"$RHODECODE_REPO_DIR"'", "database": "'"$RHODECODE_DB"'"}' --version 4.12.4 --offline  && \
    echo "**** configure rhodecode ****" && \
        sed -i "s/start_at_boot = True/start_at_boot = False/g" /root/.rccontrol.ini && \
        sed -i "s/self_managed_supervisor = False/self_managed_supervisor = True/g" /root/.rccontrol.ini && \
        touch /root/.rccontrol/supervisor/rhodecode_config_supervisord.ini && \
        echo "[supervisord]" >> /root/.rccontrol/supervisor/rhodecode_config_supervisord.ini && \
        echo "nodaemon = true" >> /root/.rccontrol/supervisor/rhodecode_config_supervisord.ini && \
        ${RCCONTROL} self-stop && \
    echo "**** cleanup ****" && \
        rm -f /tmp/* && \
        rm -f /repos/* && \
        rm -rf /var/lib/apt/lists/*


# add local files
COPY root/ /


# environment settings
USER root
ENV \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    PATH="/root/.rccontrol-profile/bin/:${PATH}" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_ALL=C 

# intended ports and volumes
EXPOSE 22 80 443
VOLUME /config
VOLUME /repos
