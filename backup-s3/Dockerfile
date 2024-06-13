FROM ubuntu

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    gettext

RUN curl https://rclone.org/install.sh | bash

ENV SCW_ACCESS_KEY_ID=
ENV SCW_SECRET_ACCESS_KEY=
ENV CC_ACCESS_KEY_ID=
ENV CC_SECRET_ACCESS_KEY=

COPY rclone_config.tpl /root/.config/rclone/rclone.conf.tpl

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/rclone", "sync", "clevercloud:", "scaleway:mesads-backups/s3/", "-v"]