#!/bin/sh
set -ex

if [ "$#" -lt 2 ]; then
    echo "usage: XC_NUMBER_BITS=XX $0 <target-name> <project-name> [<output-directory>]"
    exit 1
fi

#%% Environment
test -n ${XC_NUMBER_BITS} \
    || ( test -n ${PRJ_PROJECT_FILE} \
         && test -n ${PRJ_OPTIONS_FILE} \
         && test -n ${XC_PATH} )

#%% Build options
PRJ_TARGET=${1}
PRJ_NAME=${2}
DSTDIR=${3:-.}
: ${PRJ_BUILD_LIB:=1}
: ${PRJ_PROJECT_FILE:=xc${XC_NUMBER_BITS}.project.ini}
: ${PRJ_OPTIONS_FILE:=xc${XC_NUMBER_BITS}.options.ini}

test -e ${PRJ_OPTIONS_FILE} \
&& test -e ${PRJ_PROJECT_FILE}

#%% Tool paths
if [ "${OS}" = "Windows_NT" ]; then
    MPLABX_ROOT="$PROGRAMFILES/Microchip/MPLABX"
    XC_ROOT="$PROGRAMFILES/Microchip/xc${XC_NUMBER_BITS}"
elif [ "$(uname)" = "Darwin" ]; then
    MPLABX_ROOT="/Applications/microchip/mplabx"
    XC_ROOT="/Applications/microchip/xc${XC_NUMBER_BITS}"
else
    MPLABX_ROOT="/opt/microchip/mplabx"
    XC_ROOT="/opt/microchip/xc${XC_NUMBER_BITS}"
fi

if [ -z "${MPLABX_PATH}" ] && [ -z "${MPLABX_VERSION}" ] && [ -e "${MPLABX_ROOT}" ]; then
    # Select latest installed version
    MPLABX_VERSION=$(\
        find "${MPLABX_ROOT}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; \
        | sed -n 's/^v\([0-9]\+\.[0-9]\+\)$/\1/p' \
        | sort -gr | head -n1 \
        )
fi

: ${MPLABX_PATH:="${MPLABX_ROOT}/v${MPLABX_VERSION}/mplab_platform/bin"}

if [ -z "${XC_PATH}" ] && [ -z "${XC_VERSION}" ] && [ -e "${XC_ROOT}" ]; then
    # Select latest installed version
    XC_VERSION=$(\
        find "${XC_ROOT}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; \
        | sed -n 's/^v\([0-9]\+\.[0-9]\+\)$/\1/p' \
        | sort -gr | head -n1 \
        )
fi

: ${XC_PATH:="${XC_ROOT}/v${XC_VERSION}/bin"}

#%% Check tools exist before going any further
test -e "${XC_PATH}" && test -e "${MPLABX_PATH}"

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
    knowledgepack/ \
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
        $(test -e "${PRJ_NAME}.a" && echo "${PRJ_NAME}.a" || true) \
        *.X \
        src knowledgepack \
        "${DSTDIR}"
fi