#!/bin/bash

set -e
set -x

echo "$(date)" > runtime.txt

# Define variables
BUILD_ROOT=$(pwd)
PREBUILT="${BUILD_ROOT}/focal.aarch64.2.7.0_2021_11_17.tar.gz"
REPO_URL="https://github.com/sarafs1926/ZCU216-PYNQ"
ZCU216_SUBDIR="${BUILD_ROOT}/ZCU216"
PYNQ_SUBDIR="${BUILD_ROOT}/PYNQ"
TICS_SOURCE_DIR="${BUILD_ROOT}/tics"
TICS_TARGET_DIR="${PYNQ_SUBDIR}/sdbuild/packages/xrfclk/package/xrfclk"
BSP_SOURCE="${BUILD_ROOT}/xilinx-zcu216-v2020.2-final.bsp"
BSP_TARGET="${ZCU216_SUBDIR}/xilinx-zcu216-v2020.2-final.bsp"

# Check for prebuilt file
if [ ! -e "$BSP_SOURCE" ]; then
    echo "$BSP_SOURCE does not exist."
    echo "Manually download from https://www.xilinx.com/member/forms/download/xef.html?filename=xilinx-zcu216-v2020.2-final.bsp and rename to $BSP_SOURCE"
    exit 1
else
    echo "Found $BSP_SOURCE"
fi

# Check for prebuilt file
if [ ! -e "$PREBUILT" ]; then
    echo "$PREBUILT does not exist."
    echo "Manually download from https://www.xilinx.com/bin/public/openDownload?filename=focal.aarch64.2.7.0_2021_11_17.tar.gz and rename to $PREBUILT"
    exit 1
else
    echo "Found $PREBUILT"
fi

# Link the BSP file
if [ ! -e "$BSP_TARGET" ]; then
    ln -s $BSP_SOURCE $BSP_TARGET
fi

# Clear build.sh to avoid rebuilding other boards
pushd "$PYNQ_SUBDIR"
echo "# $(date)" > build.sh
git commit -a -m "Clean out build.sh"
popd

# Move tics files to the proper directory
cp -a "$TICS_SOURCE_DIR/." "$TICS_TARGET_DIR/"

# Build the project
pushd "${PYNQ_SUBDIR}/sdbuild"
make BOARDDIR="${BUILD_ROOT}" PREBUILT="$PREBUILT"

# Define board and version variables
BOARD="ZCU216"
VERSION="2.7.0"
BOARD_NAME=$(echo "${BOARD}" | tr '[:upper:]' '[:lower:]' | tr - _)
TIMESTAMP=$(date +'%Y_%m_%d')

# Define image and zip file names
IMAGE_FILE="${BOARD_NAME}_${TIMESTAMP}.img"
ZIP_FILE="${BOARD_NAME}_${TIMESTAMP}.zip"

# Move and zip the image file
mv "output/${BOARD}-${VERSION}.img" "$IMAGE_FILE"
zip -j "$ZIP_FILE" "$IMAGE_FILE"

popd

echo "$(date)" >> runtime.txt
cat runtime.txt


 

 
