ARG DEBIAN_RELEASE=bookworm
ARG TARGETARCH

FROM rspamd/rbldnsd:build AS build

RUN	ls -la
