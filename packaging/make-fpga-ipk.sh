#!/usr/bin/env bash

error() { echo >&2 "$@"; exit 1; }

set -e

usage()
{
    echo "Usage: $0 <top-path> <build-path> <version>"
    exit 0
}

(( $# == 3 )) || error 'Missing arguments: try -h for help'

# Arguments
TOP_DIR="$1"
BUILD_DIR="$2"
VERSION="$3"
# Package metadata
PACKAGE="panda-slowfpga"
DESCRIPTION="PandABlocks-slowFPGA machine-dependent package"
DEPENDS="panda-fpga-loader"
# Temporary work directory to build the package
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
IPK_DIR="$WORK_DIR/ipk-$PACKAGE"
mkdir -p "$IPK_DIR/CONTROL"
cd "$IPK_DIR"
sed -e "s|@PACKAGE@|$PACKAGE|" \
    -e "s|@VERSION@|$VERSION|" \
    -e "s|@DESCRIPTION@|$DESCRIPTION|" \
    -e "s|@DEPENDS@|$DEPENDS|" \
    $TOP_DIR/packaging/ipk-control-template > $IPK_DIR/CONTROL/control
FPGA_DIR="opt/share/$PACKAGE"
mkdir -p "$FPGA_DIR"
cp "$BUILD_DIR/slow_top.bin" "$FPGA_DIR"
$TOP_DIR/packaging/opkg-utils/opkg-build -o 0 -g 0 -Z xz "$IPK_DIR" "$BUILD_DIR"
