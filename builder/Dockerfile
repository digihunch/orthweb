FROM osimis/orthanc-builder-base:21.11.0 as build
RUN mkdir -p /sources /build && apt-get -y update && \ 
    apt-get install -y git mercurial build-essential unzip cmake libcrypto++-dev wget && \
    hg clone https://hg.orthanc-server.com/orthanc-object-storage/ /sources/orthanc-object-storage/
WORKDIR /build
RUN cmake -DSTATIC_BUILD=ON -DCMAKE_BUILD_TYPE=Release -DUSE_VCPKG_PACKAGES=OFF -DUSE_SYSTEM_GOOGLE_TEST=OFF /sources/orthanc-object-storage/Aws && \
    CORES=`grep -c ^processor /proc/cpuinfo` && make -j$CORES

FROM osimis/orthanc:21.11.0 as release
COPY --from=build /build/libOrthancAwsS3Storage.so /usr/local/share/orthanc/plugins/
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
