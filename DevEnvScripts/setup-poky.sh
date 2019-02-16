#!/usr/bin/env bash
# Download and configure Poky

# https://wiki.yoctoproject.org/wiki/Releases
# https://wiki.yoctoproject.org/wiki/Stable_branch_maintenance
POKY_BRANCH="thud"

if [ "$#" -gt 0 ]; then
    BASE_DIR="$(realpath -- "$1")"
else
    BASE_DIR="$HOME/poky"
fi

SOURCE_DIR="$BASE_DIR/sources"
BUILD_DIR="$BASE_DIR/build"
DOWNLOAD_DIR="$BASE_DIR/downloads"
BITBAKE_RUN_SCRIPT="$BASE_DIR/run-bitbake"

function cloneRepoBranch()
{
    local BRANCH="$1"
    local URL="$2"
    local DEST_DIR="${SOURCE_DIR}/$(basename -- "$URL")"
    mkdir -p "${SOURCE_DIR}"
    if [ -d "$DEST_DIR" ]; then
        pushd "$DEST_DIR"
        git pull
        popd >> /dev/null
    else
        git clone -b "$BRANCH" "$URL" "$DEST_DIR"
    fi
}

# Clone Poky source repos
cloneRepoBranch "$POKY_BRANCH" "git://git.yoctoproject.org/poky"
cloneRepoBranch "$POKY_BRANCH" "git://git.openembedded.org/meta-openembedded"

# Setup build dir build if it doesn't already exist
if [ ! -d "$BUILD_DIR" ]; then
    source "${SOURCE_DIR}/poky/oe-init-build-env" "${BUILD_DIR}" >> /dev/null
    mv "${BUILD_DIR}/conf/local.conf" "${BUILD_DIR}/conf/local.conf.sample"
    mv "${BUILD_DIR}/conf/bblayers.conf" "${BUILD_DIR}/conf/bblayers.conf.sample"
fi

# Create a script to make running bitbake easier
cat > "$BITBAKE_RUN_SCRIPT" << EOF
#!/usr/bin/env bash
source "${SOURCE_DIR}/poky/oe-init-build-env" "${BUILD_DIR}"
exec bitbake \$@
EOF
chmod 755 "$BITBAKE_RUN_SCRIPT"

# Set up bblayers.conf
cat > "${BUILD_DIR}/conf/bblayers.conf" << EOF
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \\
  ${SOURCE_DIR}/poky/meta \\
  ${SOURCE_DIR}/poky/meta-poky \\
  ${SOURCE_DIR}/poky/meta-yocto-bsp \\
  ${SOURCE_DIR}/meta-openembedded/meta-oe \\
  ${SOURCE_DIR}/meta-openembedded/meta-multimedia \\
  "

BBLAYERS_NON_REMOVABLE ?= " \\
 ${SOURCE_DIR}/poky/meta \\
 ${SOURCE_DIR}/poky/meta-poky \\
 "
EOF

# Set up local.conf
cat > "${BUILD_DIR}/conf/local.conf" << EOF
INHERIT += "rm_work"
#MACHINE ?= "qemux86-64"
MACHINE ?= "genericx86-64"
DL_DIR ?= "$DOWNLOAD_DIR"
EOF
