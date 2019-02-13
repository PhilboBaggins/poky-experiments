#!/usr/bin/env bash
# Download and configure Poky

# https://wiki.yoctoproject.org/wiki/Releases
# https://wiki.yoctoproject.org/wiki/Stable_branch_maintenance
POKY_BRANCH="thud"

SOURCE_DIR="$HOME/sources"
BUILD_DIR="$HOME/build-poky"
BITBAKE_RUN_SCRIPT="${HOME}/run-bitbake"

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

cloneRepoBranch "$POKY_BRANCH" "git://git.yoctoproject.org/poky"
cloneRepoBranch "$POKY_BRANCH" "git://git.openembedded.org/meta-openembedded"

rm -rf "${BUILD_DIR}"
source "${SOURCE_DIR}/poky/oe-init-build-env" "${BUILD_DIR}"

# Create a script to make running bitbake easier
cat > "$BITBAKE_RUN_SCRIPT" << EOF
#!/usr/bin/env bash
source "${SOURCE_DIR}/poky/oe-init-build-env" "${BUILD_DIR}"
exec bitbake \$@
EOF
chmod 755 "$BITBAKE_RUN_SCRIPT"

# Set up bblayers.conf
cat > "${BUILD_DIR}/conf/bblayers.conf" << EOF
# LAYER_CONF_VERSION is increased each time build/conf/bblayers.conf
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
cat >> "${BUILD_DIR}/conf/local.conf" << 'EOF'

#
# My config
#
INHERIT += "rm_work"
MACHINE ?= "qemux86-64"
EOF
