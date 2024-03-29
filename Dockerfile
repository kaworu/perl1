FROM alpine:3.14.2 as builder

RUN apk add build-base byacc
COPY . /build
WORKDIR /build
RUN patch -p1 < alpine-3.12.patch
RUN make depend
RUN make all perl.man

FROM alpine:3.14.2 as runner
LABEL org.opencontainers.image.source https://github.com/kaworu/perl1

RUN apk add mandoc
COPY --from=builder /build/perl   /bin/perl
COPY --from=builder /build/perldb /bin/perldb
COPY --from=builder /build/perl.man /usr/share/man/man1/perl.1
COPY --from=builder /build/perldb.man /usr/share/man/man1/perldb.1
