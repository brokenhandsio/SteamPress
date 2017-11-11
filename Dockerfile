FROM swift:4

WORKDIR /package

COPY . ./

RUN swift package --enable-prefetching resolve
RUN swift package clean
CMD swift test
