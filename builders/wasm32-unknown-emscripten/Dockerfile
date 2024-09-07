# syntax=docker/dockerfile:1

FROM emscripten/emsdk:3.1.65

RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked <<EOF

set -eux
apt-get update

# install dependencies for building the host Perl
apt-get install -y build-essential

# install dependencies for running the build scripts
apt-get install -y ca-certificates curl perl carton

EOF
