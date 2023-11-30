ARG DEBIAN_RELEASE=bookworm
ARG TARGETARCH

FROM rspamd/rbldnsd:build AS build

RUN	rm rbldnsd.c
RUN	rm yolo.swag
