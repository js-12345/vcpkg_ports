vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ImageMagick/ImageMagick
    REF 7.1.2-18
    SHA512 168326e62c2ca5608a660e030b9777c7200458f9eb128854867e9bf20e1aa3d603a819aa3095fb3cf13133ceb9a9c9859374b7ce872bebb179c3afdf943ec831
    HEAD_REF main
    PATCHES
        0001-fix-autotools-prefix-on-type-fallbacks.patch
        0002-fix-fallthrough-msvc.patch
)

# -------------------------------
# create configure options
# -------------------------------

# set default configure flags
set(IM_CONFIGURE_ARGS "")
list(APPEND IM_CONFIGURE_ARGS
    "--disable-docs"
    "--without-utilities"
    "--without-perl"
    "--disable-installed"
    "--without-modules"
)

# to be added into features
list(APPEND IM_CONFIGURE_ARGS
    "--without-bzlib"
    "--without-x"
    "--without-zip"
    "--without-zlib"
    "--without-zstd"
    "--without-autotrace"
    "--without-dps"
    "--without-fftw"
    "--without-flif"
    "--without-fpx"
    "--without-djvu"
    "--without-fontconfig"
    "--without-freetype"
    "--without-raqm"
    "--without-gdi32"
    "--without-gslib"
    "--without-gvc"
    "--without-dmr"
    "--without-heic"
    "--without-jbig"
    "--without-jpeg"
    "--without-jxl"
    "--without-lcms"
    "--without-openjp2"
    "--without-lqr"
    "--without-lzma"
    "--without-openexr"
    "--without-pango"
    "--without-png"
    "--without-raw"
    "--without-rsvg"
    "--without-tiff"
    "--without-uhdr"
    "--without-webp"
    "--without-wmf"
    "--without-xml"
)

# -------------------------------
# run autotools/configure
# -------------------------------

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    USE_WRAPPERS
    OPTIONS
        ${IM_CONFIGURE_ARGS}
)

# -------------------------------
# fixing windows build problems
# -------------------------------

if(VCPKG_TARGET_IS_WINDOWS)

    # emf.c uses c++ gdi so inject c++ flags into Makefile
    foreach(_config "rel" "dbg")
        set(_makefile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_config}/Makefile")
        if(EXISTS "${_makefile}")
            file(APPEND "${_makefile}"
                "\n# emf.c genuinely needs C++ mode (uses the GDI+ C++ API)\n"
                "coders/MagickCore_libMagickCore_7_Q16HDRI_la-emf.lo: CFLAGS += -TP\n"
            )
        endif()
    endforeach()
endif()

# -------------------------------
# build and install
# -------------------------------

vcpkg_build_make()
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# -------------------------------
# fix/remove installed files
# -------------------------------

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# be careful if there is stuff to be installed under tools
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
