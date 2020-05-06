#!/usr/bin/env bash
export  ECODATA_DIR=target/ecodata
export ECODATA_BRANCH=master

rm -rf $ECODATA_DIR
git clone https://github.com/AtlasOfLivingAustralia/ecodata.git $ECODATA_DIR
cd $ECODATA_DIR
git checkout $ECODATA_BRANCH


grails test run-app -Dgrails.server.port.http=8080&


