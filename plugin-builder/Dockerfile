FROM debian:buster-20210511-slim as s3-plugin-builder 
# Refer to image osimis/orthanc-builder-base

# START Prep build envivornment and clone source code for plugin
RUN export DEBIAN_FRONTEND=noninteractive && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && apt-get update && \
    apt-get -y install apt-transport-https apt-utils build-essential ca-certificates cmake curl git libboost-all-dev libcharls-dev libcrypto++-dev libcurl4-openssl-dev libdcmtk14 libdcmtk2-dev libgtest-dev libjpeg-dev libjpeg62-turbo libjsoncpp-dev libjsoncpp1 liblua5.3 liblua5.3-dev libmariadb3 libpng-dev libpng16-16 libpq5 libpugixml-dev libpugixml1v5 libsqlite3-0 libsqlite3-dev libssl1.1 libuuid1 libwrap0-dev locales lsb-base mercurial python3-pip python3.7 tzdata unzip uuid-dev vim wget zip zlib1g zlib1g-dev && \
    locale-gen && apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/* && mkdir -p /sources && mkdir -p /build && \
    hg clone https://hg.orthanc-server.com/orthanc-object-storage/ /sources/orthanc-object-storage/
# END Prep build environment and clone source code for plugin

### START BUILD Orthanc S3 Plugin
WORKDIR /build
CMD cmake -DUSE_VCPKG_PACKAGES=FALSE -DSTATIC_AWS_CLIENT=TRUE /sources/orthanc-object-storage/Aws && \
    cmake --build . --config Release && \
    ./UnitTests && \
    cp /build/*.so /out/
### END BUILD Orthanc S3 Plugin

