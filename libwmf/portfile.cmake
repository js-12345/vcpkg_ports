
# -------------------------------
# download source from github repo
# -------------------------------

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caolanm/libwmf
    REF v0.2.17
    SHA512 758f62abf36d6993124b064eb1ec4295b0f571c02945861375474b93a1d68b4f298d64d295c836f4c34fc882192995845021ae69bb16d1e8e88630b7de4a5f08
    HEAD_REF master
    PATCHES
        0001-fix-bmp-header-file.patch
        0002-fix-detection-of-windows.patch
        0003-fix-include-dir-pc-file.patch
)

# -------------------------------
# create configure options
# -------------------------------

# set default configure flags
set(CONFIGURE_ARGS "")
list(APPEND CONFIGURE_ARGS
    "--without-x"
    "--with-freetype=yes"
    "--with-zlib=yes"
    "--with-png=yes"
)

# maybe add as feature??
list(APPEND CONFIGURE_ARGS
    "--with-expat=no"
    "--with-libxml2=no"
    "--with-jpeg=no"
    "--enable-gd=no"
    "--enable-pixbuf=no"
)

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

# -------------------------------
# fix/remove installed files
# -------------------------------

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
