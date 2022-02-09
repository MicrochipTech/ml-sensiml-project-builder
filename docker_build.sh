#!/bin/sh
set -ex

: ${PRJ_TARGET:=AVR128DA48}
: ${BUILD_ARGS_FILE:=./AVR-Dx.args}
: ${PRJ_BUILD_LIB:=1}

. ${BUILD_ARGS_FILE}

docker build . \
    -f xc${XC_NUMBER_BITS}.dockerfile \
    -t xc${XC_NUMBER_BITS}

IMAGE_TAG=$(basename ${BUILD_ARGS_FILE%.*} | tr [:upper:] [:lower:])
docker build . \
    -f mchp-sensiml-build.dockerfile \
    -t $IMAGE_TAG \
    $(cat ${BUILD_ARGS_FILE} | awk '{print "--build-arg " $0}' )

mkdir -p dist
rm -rf dist/*

# Git Bash screws up paths when running docker, disabled with MSYS_NO_PATHCONV=1
MSYS_NO_PATHCONV=1 docker run \
    --rm \
    -v "$(pwd)"/dist:/dist \
    -e PRJ_BUILD_LIB=$PRJ_BUILD_LIB \
    $IMAGE_TAG \
    $PRJ_TARGET sensiml-template /dist