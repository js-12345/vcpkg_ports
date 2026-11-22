
# -------------------------------
# download source from github repo
# -------------------------------

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO carlobaldassi/liblqr
    REF v0.4.3
    SHA512 f9b163e52c11589d3176a73287845e6377c6f30291a9e52d71d811b2b247a6a6f4a64f74a67fadda570585164cecb2eced14058d509359f089497a1d20035d38
    HEAD_REF master
    PATCHES
        0001-fix-pkg-config-file-with-cflag.patch
)

# -------------------------------
# create configure options
# -------------------------------

# set default configure flags
set(CONFIGURE_ARGS "")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND CONFIGURE_ARGS "--disable-declspec")
endif()

# -------------------------------
# run autotools/configure
# -------------------------------

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    USE_WRAPPERS
    AUTOCONFIG
    OPTIONS
        ${CONFIGURE_ARGS}
)

# -------------------------------
# build and install
# -------------------------------

vcpkg_build_make()
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
