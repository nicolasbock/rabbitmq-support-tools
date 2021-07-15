#!/bin/bash

PS4="($LINENO)"

set -e -u -x

basedir=$(readlink --canonicalize $(dirname $0))

release=0
DEB_VERSION=9999
if (( $# != 0 )) && [[ $1 = --release ]]; then
  release=1
  DEB_VERSION=$(head -n 1 debian/changelog | sed -e 's/^.*(\(.*\)).*$/\1/')
fi

PACKAGE=rabbitmq-support-tools

cd ${basedir}/..

git archive \
  --format tar.gz \
  --output ${PACKAGE}_${DEB_VERSION}.orig.tar.gz \
  --prefix ${PACKAGE}-${DEB_VERSION}/ \
  HEAD

tar xf ${PACKAGE}_${DEB_VERSION}.orig.tar.gz
rsync -av ${basedir}/debian ${PACKAGE}-${DEB_VERSION}/

cd ${PACKAGE}-${DEB_VERSION}
if [[ ${release} == 0 ]]; then
  dch \
    --newversion ${DEB_VERSION} \
    --distribution $(lsb_release --codename | awk '{print $2}') \
    "CI testbuild"
fi
debuild -S -us -uc
cd ..

rm -rf ${PACKAGE}-${DEB_VERSION}
