FROM ubuntu

# These are the environment variables that need to be set for the backup script to work
ENV PGHOST=
ENV PGPORT=
ENV PGUSER=
ENV PGPASSWORD=
ENV PGDATABASE=
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV S3_PATH=

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    unzip

# Install postgresql-client-15
RUN install -d /usr/share/postgresql-common/pgdg
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-get install -y lsb-release
RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update && apt-get install -y \
    postgresql-client-15

# Install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
RUN unzip /tmp/awscliv2.zip -d /tmp
RUN /tmp/aws/install

COPY ./aws_config /root/.aws/config
COPY backup.sh /backup.sh

CMD ["/backup.sh"]