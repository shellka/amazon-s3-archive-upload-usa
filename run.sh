if [ ! -n "$WERCKER_S3_ARCHIVE_UPLOAD_KEY" ]; then
  error 'Please specify key'
  exit 1
fi

if [ ! -n "$WERCKER_S3_ARCHIVE_UPLOAD_SECRET" ]; then
  error 'Please specify secret'
  exit 1
fi

if [ ! -n "$WERCKER_S3_ARCHIVE_UPLOAD_BUCKET3" ]; then
  #set default bucket
  export WERCKER_S3_ARCHIVE_UPLOAD_BUCKET3="wercker-deployments"
fi

if [ ! -n "$WERCKER_S3_ARCHIVE_UPLOAD_REGION3" ]; then
  error 'Please specify region'
  exit 1
fi

info 'Installing pip...'
sudo apt-get update
sudo apt-get install -y python-pip libpython-all-dev zip

info 'Installing the AWS CLI...';
sudo pip install awscli;

info 'EB Version...'
aws --version

mkdir -p $HOME/.aws
echo '[default]' > $HOME/.aws/config
echo 'output = json' >> $HOME/.aws/config
echo "region = $WERCKER_S3_ARCHIVE_UPLOAD_REGION3" >> $HOME/.aws/config
echo "aws_access_key_id = $WERCKER_S3_ARCHIVE_UPLOAD_KEY" >> $HOME/.aws/config
echo "aws_secret_access_key = $WERCKER_S3_ARCHIVE_UPLOAD_SECRET" >> $HOME/.aws/config

export AMAZON_ACCESS_KEY_ID=$WERCKER_S3_ARCHIVE_UPLOAD_KEY
export AMAZON_SECRET_ACCESS_KEY=$WERCKER_S3_ARCHIVE_UPLOAD_SECRET
export AWS_DEFAULT_REGION=$WERCKER_S3_ARCHIVE_UPLOAD_REGION3
export AWS_APP_VERSION_LABEL=$WERCKER_GIT_COMMIT
export AWS_APP_FILENAME=$AWS_APP_VERSION_LABEL.zip

rm -rf .git
rm -rf node_modules
zip -r $AWS_APP_FILENAME .

if [ ! -f $AWS_APP_FILENAME ]; then
  error 'Zip could not be created'
  exit 1
fi

#aws configure set default.s3.signature_version s3v4
aws s3 cp --acl private $AWS_APP_FILENAME s3://$WERCKER_S3_ARCHIVE_UPLOAD_BUCKET3
