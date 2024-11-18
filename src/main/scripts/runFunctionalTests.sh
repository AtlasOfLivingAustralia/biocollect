#!/bin/bash -v

BIOCOLLECT_DIR=$PWD

GEB_ENV=$1
if [ -z $GEB_ENV ]; then
    GEB_ENV=chromeHeadless
fi

BRANCH=$3
if [ -z $BRANCH ]; then
    BRANCH=dev
fi

PWA_BRANCH=$5
if [ -z $PWA_BRANCH ]; then
    PWA_BRANCH=testing
fi

ECODATA_LOCAL_DIR=$2
if [ -z $ECODATA_LOCAL_DIR ]; then
    ECODATA_LOCAL_DIR=/tmp/ecodata
fi

PWA_LOCAL_DIR=$4
if [ -z $PWA_LOCAL_DIR ]; then
    PWA_LOCAL_DIR=/tmp/biocollect-pwa
fi

if [ ! -d $ECODATA_LOCAL_DIR ]; then
    cd /tmp
    git clone https://github.com/AtlasOfLivingAustralia/ecodata.git
    cd ecodata
    git checkout $BRANCH
    echo "Cloned ecodata $BRANCH into /tmp/ecodata"
else
    cd $ECODATA_LOCAL_DIR
    git checkout $BRANCH
    git pull
fi

if [ ! -d $PWA_LOCAL_DIR ]; then
    cd /tmp
    git clone https://github.com/AtlasOfLivingAustralia/biocollect-pwa
    cd biocollect-pwa
    git checkout $PWA_BRANCH
    echo "Cloned biocollect pwa $PWA_BRANCH into /tmp/biocollect-pwa"
else
    cd $PWA_LOCAL_DIR
    git checkout $PWA_BRANCH
    git pull
    echo "Updated  pwa $PWA_BRANCH in $PWA_LOCAL_DIR"
fi


echo "Dropping database"
mongosh ecodata-functional-test --eval 'db.dropDatabase();'
mongosh ecodata-functional-test --eval 'db.project.count();'
cd "$BIOCOLLECT_DIR/src/integration-test/resources/data_common/"
mongosh ecodata-functional-test loadAlaHub.js

echo "Hosts file configuration"
cat /etc/hosts

cd $BIOCOLLECT_DIR
echo "Starting wire mock"
./gradlew startWireMock &
sleep 60

cd $PWA_LOCAL_DIR
echo "Starting biocollect-pwa"
cd $PWA_LOCAL_DIR
npm install
npm run run:functionaltest &
sleep 15

cd $ECODATA_LOCAL_DIR
echo "Starting ecodata from `pwd`"
ls -la
GRADLE_OPTS="-Xmx1g" ./gradlew bootRun "-Dorg.gradle.jvmargs=-Xmx1g" -Dgrails.env=meritfunctionaltest &
sleep 180

cd $BIOCOLLECT_DIR
echo "Starting biocollect from `pwd`"
GRADLE_OPTS="-Xmx1g" ./gradlew bootRun "-Dorg.gradle.jvmargs=-Xmx1g" -Dgrails.env=test -Dgrails.server.port.http=8087 &
sleep 180
chmod u+x src/main/scripts/loadFunctionalTestData.sh

echo "Running functional tests"
node_modules/@wdio/cli/bin/wdio.js run wdio.local.conf.js

RETURN_VALUE=$?

kill %4
kill %3
kill %2
kill %1

exit $RETURN_VALUE
