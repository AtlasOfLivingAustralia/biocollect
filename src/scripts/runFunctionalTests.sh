#!/bin/bash -v

MERIT_DIR=$PWD

GEB_ENV=$1
if [ -z $GEB_ENV ]; then
    GEB_ENV=chromeHeadless
fi

BRANCH=$3
if [ -z $BRANCH ]; then
    BRANCH=dev
fi

ECODATA_LOCAL_DIR=$2
if [ -z $ECODATA_LOCAL_DIR ]; then
    ECODATA_LOCAL_DIR=/tmp/ecodata
fi

if [ ! -d $ECODATA_LOCAL_DIR ]; then
    cd /tmp
    git clone https://github.com/AtlasOfLivingAustralia/ecodata.git
    cd ecodata
    git checkout $BRANCH
else
    cd $ECODATA_LOCAL_DIR
    git pull
fi

echo "Dropping database"
mongo ecodata-functional-test --eval 'db.dropDatabase();'
mongo ecodata-functional-test --eval 'db.project.count();'

echo "Starting ecodata from `pwd`"
ls -la
GRADLE_OPTS="-Xmx512m" ./gradlew bootRun --no-daemon "-Dorg.gradle.jvmargs=-Xmx512m" -Dgrails.env=meritfunctionaltest &
sleep 120

cd $MERIT_DIR
GRADLE_OPTS="-Xmx512m" ./gradlew bootRun --no-daemon "-Dorg.gradle.jvmargs=-Xmx512m" -Dgrails.env=test -Dgrails.server.port.http=8087 &
sleep 180

chmod u+x src/main/scripts/loadFunctionalTestData.sh

echo "Running functional tests"
./gradlew integrationTest --stacktrace -Dgeb.env=$GEB_ENV

RETURN_VALUE=$?

kill %2
kill %1

exit $RETURN_VALUE
