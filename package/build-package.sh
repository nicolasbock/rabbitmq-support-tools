#!/bin/bash

set -e -u -x

basedir=$(readlink --canonicalize $(dirname $0))

TAG=v9999
if (( $# != 0 )); then
  TAG=$1
  if ! git --no-pager show ${TAG}; then
    echo "please enter valid tag"
    exit 1
  fi
fi

DEB_VERSION=${TAG#v}
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
if [[  ${TAG} == v9999 ]]; then
  dch \
    --newversion ${DEB_VERSION} \
    --distribution $(lsb_release --codename | awk '{print $2}') \
    "CI testbuild"
fi
debuild -S -us -uc
cd ..

rm -rf ${PACKAGE}-${DEB_VERSION}
