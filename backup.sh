#!/bin/bash

# this needs to stay in here. otherwise six will report it's not installed
pip install six

if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then
  echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable."
fi

if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then
  echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
fi

if [ "${S3_BUCKET}" == "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${MONGO_URI}" == "**None**" ]; then
  echo "You need to set the MONGO_URI environment variable."
  exit 1
fi

if [ "${MONGO_USER}" == "**None**" ]; then
  echo "You need to set the MONGO_USER environment variable."
  exit 1
fi

if [ "${MONGO_PASSWORD}" == "**None**" ]; then
  echo "You need to set the MONGO_PASSWORD environment variable or link to a container named MONGO."
  exit 1
fi

if [ "${S3_IAMROLE}" != "true" ]; then
  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION=$S3_REGION
fi

DUMP_START_TIME=$(date +"%Y-%m-%dT%H%M%SZ")

copy_s3 () {
  SRC_FILE=$1
  DEST_FILE=$2

  if [ "${S3_ENDPOINT}" == "**None**" ]; then
    AWS_ARGS=""
  else
    AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  echo "Uploading ${DEST_FILE} on S3..."

  cat $SRC_FILE | aws $AWS_ARGS s3 cp - s3://$S3_BUCKET/$S3_PREFIX/$DEST_FILE

  if [ $? != 0 ]; then
    >&2 echo "Error uploading ${DEST_FILE} on S3"
  fi

  rm $SRC_FILE
}

echo "Creating dump for ${MONGODUMP_DATABASE} from ${MONGO_URI}..."

DUMP_FILE="/tmp/db.dump.gz"
mongodump --uri $MONGO_URI $MONGODUMP_OPTIONS | gzip > $DUMP_FILE

if [ $? == 0 ]; then
  if [ "${S3_FILENAME}" == "**None**" ]; then
    S3_FILE="${DUMP_START_TIME}.dump.sql.gz"
  else
    S3_FILE="${S3_FILENAME}.sql.gz"
  fi
  copy_s3 $DUMP_FILE $S3_FILE
else
  >&2 echo "Error creating dump"
fi

echo "MONGODB backup finished"