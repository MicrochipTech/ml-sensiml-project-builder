ARG XC_NUMBER_BITS
ARG XC_VERSION

FROM xc${XC_NUMBER_BITS}:latest

#%% Download DFP
ARG DFP_NAME
ARG DFP_VERSION
RUN \
    wget -qO /tmp/tmp-pack.atpack \
    https://packs.download.microchip.com/Microchip.${DFP_NAME}.${DFP_VERSION}.atpack \
    && mkdir -p /opt/microchip/mplabx/v${MPLABX_VERSION}/packs/Microchip/${DFP_NAME}/${DFP_VERSION} \
    && unzip -o /tmp/tmp-pack.atpack -d /opt/microchip/mplabx/v${MPLABX_VERSION}/packs/Microchip/${DFP_NAME}/${DFP_VERSION} \
    && rm /tmp/tmp-pack.atpack \
    && rm -rf /var/lib/apt/lists/*

# #%% Checkout prj builder
# ARG GIT_MCHP_PRJ_BUILDER="https://github.com/tjgarcia-mchp/ml-sensiml-project-builder.git"
# RUN \
#     git clone --depth 1 "${GIT_MCHP_PRJ_BUILDER}" /build \
#     && chmod a+x /build/build.sh

#%% Set up image as a build executable
ENV PRJ_PROJECT_FILE=sensiml.xc${XC_NUMBER_BITS}.project.ini
ENV PRJ_OPTIONS_FILE=sensiml.xc${XC_NUMBER_BITS}.options.ini

COPY build.sh /build/
COPY ${PRJ_PROJECT_FILE} ${PRJ_OPTIONS_FILE} /build/
COPY src /build/src
COPY knowledgepack /build/knowledgepack

WORKDIR /build/
ENTRYPOINT ["./build.sh"]
CMD [""]
