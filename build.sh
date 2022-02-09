#!/bin/sh
set -ex

if [ "$#" -lt 2 ]; then
    echo "usage: $0 <target-name> <project-name> [<output-directory>]"
    exit 1
fi

#%% Environment
: ${XC_NUMBER_BITS:=32}
: ${XC_VERSION:=4.00}
: ${MPLABX_VERSION:=6.00}

#%% Build options
PRJ_TARGET=${1}
: ${PRJ_BUILD_LIB:=1}
: ${PRJ_PROJECT_FILE:=sensiml.xc${XC_NUMBER_BITS}.project.ini}
: ${PRJ_OPTIONS_FILE:=sensiml.xc${XC_NUMBER_BITS}.options.ini}
PRJ_NAME="${2:-sensiml-template}"
DSTDIR="${3:-.}"

#%% Tool paths
if [ "${OS}" = "Windows_NT" ]; then
    : "${MPLABX_PATH:=$PROGRAMFILES/Microchip/MPLABX/v${MPLABX_VERSION}/mplab_platform/bin}"
    : "${XC_PATH:=$PROGRAMFILES/Microchip/xc${XC_NUMBER_BITS}/v${XC_VERSION}/bin}"
elif [ "$(uname)" = "Darwin" ]; then
    : "${MPLABX_PATH:=/Applications/microchip/mplabx/v${MPLABX_VERSION}/mplab_platform/bin}"
    : "${XC_PATH:=/Applications/microchip/xc${XC_NUMBER_BITS}/v${XC_VERSION}/bin}"
else
    : "${MPLABX_PATH:=/opt/microchip/mplabx/v${MPLABX_VERSION}/mplab_platform/bin}"
    : "${XC_PATH:=/opt/microchip/xc${XC_NUMBER_BITS}/v${XC_VERSION}/bin}"
fi

if [ "${OS}" = "Windows_NT" ]; then
    PRJMAKEFILESGENERATOR="${MPLABX_PATH}/prjMakefilesGenerator.bat"
    MAKE="${MPLABX_PATH}/../../gnuBins/GnuWin32/bin/make.exe"
    # Get around space in path issues with windows
    XC_PATH=$(cygpath -d "${XC_PATH}")
else
    PRJMAKEFILESGENERATOR="${MPLABX_PATH}/prjMakefilesGenerator.sh"
    MAKE="${MPLABX_PATH}/make"
fi

#%% Build up list of source files
SOURCE_LIST_FILE=."${PRJ_NAME}".sources.txt
rm -f "${SOURCE_LIST_FILE}"

set +x
if [ "${PRJ_BUILD_LIB}" -eq 0 ]; then
    # Add generic implementation files
    printf '%s\n' \
        src/ \
    >> "${SOURCE_LIST_FILE}"
fi

printf '%s\n' \
    knowledgepack/src/ \
>> "${SOURCE_LIST_FILE}"

set -x

# (Make paths relative to project dir)
echo "$(cat ${SOURCE_LIST_FILE} | awk '{print "../" $0}')" > "${SOURCE_LIST_FILE}"

#%% Create project
rm -rf ${PRJ_NAME}.X
"${PRJMAKEFILESGENERATOR}" -create=@"${PRJ_PROJECT_FILE}" "${PRJ_NAME}".X@default \
    -compilers="${XC_PATH}" \
    -device="${PRJ_TARGET}"

#%% Set project configuration
"${PRJMAKEFILESGENERATOR}" -setoptions=@"${PRJ_OPTIONS_FILE}" "${PRJ_NAME}".X@default

# (Change project to library type (3) manually)
if [ "${PRJ_BUILD_LIB}" -ne 0 ]; then
    echo "$(cat ${PRJ_NAME}.X/nbproject/configurations.xml | sed 's|\(<conf name="default" type="\)[0-9]\+|\13|g')" > "${PRJ_NAME}".X/nbproject/configurations.xml
fi

#%% Add files
"${PRJMAKEFILESGENERATOR}" -setitems "${PRJ_NAME}".X@default \
    -pathmode=relative \
    -files=@"${SOURCE_LIST_FILE}"

#%% Finalize project
if [ "${PRJ_BUILD_LIB}" -ne 0 ]; then
    cd "${PRJ_NAME}".X \
    && "${MAKE}" \
    && cp $(find . -name "${PRJ_NAME}.X.a") ../"${PRJ_NAME}".a \
    && cd ..
fi

if [ "$(readlink -f ${DSTDIR})" != "$PWD" ]; then
    mkdir -p "${DSTDIR}" \
    && mv \
        $(test -e ${PRJ_NAME} *.a -maxdepth 0 >/dev/null 2>&1) \
        *.X \
        src knowledgepack \
        "${DSTDIR}"
fi