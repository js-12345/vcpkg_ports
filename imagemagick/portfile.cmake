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

# search for features
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "zero-configuration" ZERO_CONFIGURATION
)

if(ZERO_CONFIGURATION)
    list(APPEND IM_CONFIGURE_ARGS "--enable-zero-configuration")
else()
    list(APPEND IM_CONFIGURE_ARGS "--disable-zero-configuration")
endif()

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

# remove unneeded compile config files under ./tools
file(GLOB im_tools_config_files
    "${CURRENT_PACKAGES_DIR}/tools/imagemagick/bin/*-config"
    "${CURRENT_PACKAGES_DIR}/tools/imagemagick/debug/bin/*-config"
)
file(REMOVE ${im_tools_config_files})

# remove xml config files if zero config is build
if(ZERO_CONFIGURATION)
    # config files under ./etc/ImageMagick-*
    file(GLOB im_etc_config_files
        "${CURRENT_PACKAGES_DIR}/etc/ImageMagick-*/*.xml"
        "${CURRENT_PACKAGES_DIR}/debug/etc/ImageMagick-*/*.xml"
    )
    file(REMOVE ${im_etc_config_files})

    # config files under ./lib/ImageMagick-*/config*
    file(GLOB im_lib_config_files
        "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*/config*/*.xml"
        "${CURRENT_PACKAGES_DIR}/debug/lib/ImageMagick-*/config*/*.xml"
    )
    file(REMOVE ${im_lib_config_files})

    # config files under ./share/imagemagick/ImageMagick
    file(GLOB im_share_config_files
        "${CURRENT_PACKAGES_DIR}/share/imagemagick/ImageMagick-*/*.xml"
        "${CURRENT_PACKAGES_DIR}/debug/share/imagemagick/ImageMagick-*/*.xml"
    )
    file(REMOVE ${im_share_config_files})
endif()

# adding function to remove empty dirs
function(remove_empty_directories DIR)
    file(GLOB _red_files "${DIR}/*")

    foreach(_red_file IN LISTS _red_files)
        if(IS_DIRECTORY "${_red_file}")
            remove_empty_directories("${_red_file}")
        endif()
    endforeach()

    file(GLOB _red_still_rem_files "${DIR}/*")

    if(NOT _red_still_rem_files)
        file(REMOVE_RECURSE "${DIR}")
    endif()
endfunction()

# removing all empty dirs in install location
remove_empty_directories("${CURRENT_PACKAGES_DIR}")
