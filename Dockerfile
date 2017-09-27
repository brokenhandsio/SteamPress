FROM swiftdocker/swift:latest

WORKDIR /package

COPY . ./

RUN swift --version
RUN swift package tools-version
RUN swift package --enable-prefetching fetch
RUN swift package clean
CMD swift test
