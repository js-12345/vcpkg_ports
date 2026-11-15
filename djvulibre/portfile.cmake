
# -------------------------------
# download source from github repo
# -------------------------------

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO barak/djvulibre
    REF upstream/3.5.27.1
    SHA512 70c7071091caf639af860cfbcfbc3a9e15cc27b784b89730b72e16164dedc45a971832750bdb10e01d030b6e822dccd69c1a69c49351e99161e3a7c7029fcd9c
    HEAD_REF master
    PATCHES
        0001-fix-declspec-static-windows.patch
        0002-printout-configuration-into-log.patch
)

# -------------------------------
# run autotools/configure
# -------------------------------

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    USE_WRAPPERS
    AUTOCONFIG
)

# -------------------------------
# build and install
# -------------------------------

vcpkg_build_make()
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

# -------------------------------
# fix/remove installed files
# -------------------------------

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
