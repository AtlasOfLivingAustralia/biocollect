#!/bin/bash -v

BIOCOLLECT_DIR=$PWD
BACKGROUND_PIDS=()

cleanup() {
    local pid
    for pid in "${BACKGROUND_PIDS[@]}"; do
        kill "$pid" 2>/dev/null || true
    done
}
trap cleanup EXIT

start_background() {
    local log_name=$1
    shift
    "$@" >> "$BIOCOLLECT_DIR/logs/${log_name}.log" 2>&1 &
    BACKGROUND_PIDS+=($!)
}

wait_for_port() {
    local name=$1
    local port=$2
    local pid=$3
    while ! nc -z localhost "$port"; do
        if ! kill -0 "$pid" 2>/dev/null; then
            echo "$name exited before listening on port $port"
            tail -n 80 "$BIOCOLLECT_DIR/logs/${name}.log" || true
            exit 1
        fi
        echo "Waiting for $name to start on port $port..."
        sleep 5
    done
}

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
mongosh ecodata-functional-test loadAcsaHub.js

echo "Hosts file configuration"
cat /etc/hosts

cd $BIOCOLLECT_DIR
mkdir -p "$BIOCOLLECT_DIR/logs"
echo "Starting wire mock"
./gradlew startWireMock

cd $PWA_LOCAL_DIR
echo "Starting biocollect-pwa"

echo "Installing PWA pnpm dependencies"
pnpm ci
start_background pwa pnpm run:functionaltest
wait_for_port pwa 5173 $!


cd $ECODATA_LOCAL_DIR
echo "Starting ecodata from `pwd`"
ls -la
start_background ecodata env GRADLE_OPTS="-Xmx1g" ./gradlew :bootRun "-Dorg.gradle.jvmargs=-Xmx1g" -Dgrails.env=meritfunctionaltest
wait_for_port ecodata 8080 $!


cd $BIOCOLLECT_DIR
echo "Starting biocollect from `pwd`"
start_background biocollect env GRADLE_OPTS="-Xmx1g" ./gradlew :bootRun "-Dorg.gradle.jvmargs=-Xmx1g" -Dgrails.env=test -Dgrails.server.port.http=8087
wait_for_port biocollect 8087 $!
chmod u+x src/main/scripts/loadFunctionalTestData.sh

echo "Installing BioCollect pnpm dependencies"
pnpm ci

echo "Running functional tests"
export DISABLE_FUNCTIONAL_TEST_CAPTURE=1
node_modules/@wdio/cli/bin/wdio.js run wdio.local.conf.js

RETURN_VALUE=$?

trap - EXIT
cleanup

exit $RETURN_VALUE
