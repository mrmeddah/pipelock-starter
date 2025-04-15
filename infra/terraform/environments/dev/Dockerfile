FROM metabase/metabase:latest
COPY rds-ca-2019-root.pem /usr/local/share/ca-certificates/rds-ca-2019-root.crt
RUN update-ca-certificates
