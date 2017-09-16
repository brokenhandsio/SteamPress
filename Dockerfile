FROM swift:3.1

WORKDIR /package

COPY . ./

RUN swift package --enable-prefetching fetch
RUN swift package clean
CMD swift test
