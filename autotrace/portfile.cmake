
# -------------------------------
# download source from github repo
# -------------------------------

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO autotrace/autotrace
    REF 0.31.10
    SHA512 a497cc792370205d24f4ecfdbc22f86e98e934c400fae6cbfab3b2e561ca59def657b36a5e4be54ee8d23d2668d7745e902fc6c14464a2374192064ed994e704
    HEAD_REF master
    PATCHES
        0001-fix-glib-gettext-windows.patch
        0002-deactivate-autotrace-bin.patch
        0003-fix-rint-redefinition-on-win.patch
        0004-fix-pc-file-for-magick-lib.patch
        0005-fix-log4-on-debug-build.patch
)

# -------------------------------
# create configure options
# -------------------------------

# set default configure flags
set(CONFIGURE_ARGS "")
list(APPEND CONFIGURE_ARGS
    "--disable-nls"
    "--with-magick=no"
    "--with-png=no"
    "--with-pstoedit=no"
)

# TODO: add lib integrations (currently autotrace is only dep for ImageMagick as a tracer so no additional libs for IM from AT are needed):
# libpng
# libming
# GraphicsMagick/ImageMagick (probably not)
# pstoedit

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

# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
