# mongo-backup-s3

Backup MongoDB to S3 (supports periodic backups)

This work is derived from https://github.com/schickling/mysql-backup-s3
## Basic usage

```sh
$ docker run -e S3_ACCESS_KEY_ID=key -e S3_SECRET_ACCESS_KEY=secret -e S3_BUCKET=my-bucket -e S3_PREFIX=backup -e MONGO_URI=mongodb://<USER>:<PASSWORD>@mongodb-0.mongodb-headless.default.svc.cluster.local,mongodb-1.mongodb-headless.default.svc.cluster.local,mongodb-2.mongodb-headless.default.svc.cluster.local/admin?retryWrites=true&w=majority ticketteer/mongo-backup-s3
```

## Environment variables

- `MONGODUMP_OPTIONS` mysqldump options (default: --archive)
- `MONGO_URI` the mongo database connection uri *required*
- `S3_ACCESS_KEY_ID` your AWS access key *required*
- `S3_SECRET_ACCESS_KEY` your AWS secret key *required*
- `S3_BUCKET` your AWS S3 bucket path *required*
- `S3_PREFIX` path prefix in your bucket (default: 'backup')
- `S3_FILENAME` a consistent filename to overwrite with your backup.  If not set will use a timestamp.
- `S3_REGION` the AWS S3 bucket region (default: us-west-1)
- `S3_ENDPOINT` the AWS Endpoint URL, for S3 Compliant APIs such as [minio](https://minio.io) (default: none)
- `S3_S3V4` set to `yes` to enable AWS Signature Version 4, required for [minio](https://minio.io) servers (default: no)
- `SCHEDULE` backup schedule time, see explainatons below

### Automatic Periodic Backups

You can additionally set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).
