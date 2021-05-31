FROM osimis/orthanc:latest
COPY libOrthancAwsS3Storage.so /usr/share/orthanc/plugins-disabled
RUN chmod 644 /usr/share/orthanc/plugins-disabledlibOrthancAwsS3Storage.so && apt-get update && \
    apt-get install -y curl libssl1.1 libcrypto++* libcurl4-openssl-dev libjsoncpp-dev libboost-all-dev libcurl4 libssl-dev
