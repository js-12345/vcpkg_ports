vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ImageMagick/ImageMagick
    REF 7.1.2-18
    SHA512 168326e62c2ca5608a660e030b9777c7200458f9eb128854867e9bf20e1aa3d603a819aa3095fb3cf13133ceb9a9c9859374b7ce872bebb179c3afdf943ec831
    HEAD_REF main
    PATCHES
        0001-fix-autotools-prefix-on-type-fallbacks.patch
        0002-fix-fallthrough-msvc.patch
        0003-fix-winpath-malformed-path-define.patch
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

set(QUANTUM_DEPTH 16) # 16 is default

# search for features
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "disable-zero-config"   DISABLE_ZERO_CONFIG
        "hdri"                  ENABLE_HDRI
)

# create feature adding macros
macro(im_add_configure_arg _prefix _configure_name)
    if(${ARGN})
        list(APPEND IM_CONFIGURE_ARGS "--${_prefix}-${_configure_name}=yes")
    else()
        list(APPEND IM_CONFIGURE_ARGS "--${_prefix}-${_configure_name}=no")
    endif()
endmacro()

# adding convenience macros
macro(im_add_configure_enable_var _configure_name)
    im_add_configure_arg("enable" "${_configure_name}" ${ARGN})
endmacro()
macro(im_add_configure_with_var _configure_name)
    im_add_configure_arg("with" "${_configure_name}" ${ARGN})
endmacro()

# features enabling/disabling/with/without from vcpkg feature
im_add_configure_enable_var("zero-configuration" NOT ${DISABLE_ZERO_CONFIG})
im_add_configure_enable_var("hdri" ${ENABLE_HDRI})

# to be added into features
list(APPEND IM_CONFIGURE_ARGS
    "--with-quantum-depth=16"
    "--disable-openmp"
    "--disable-opencl"
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

# generating lib name from current config
set(_im_abi_name "Q${QUANTUM_DEPTH}")
if(ENABLE_HDRI)
    string(APPEND _im_abi_name "HDRI")
endif()

# windows fixes
if(VCPKG_TARGET_IS_WINDOWS)

    # emf.c uses c++ gdi so inject c++ flags into Makefile
    foreach(_config "rel" "dbg")
        set(_makefile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_config}/Makefile")
        if(EXISTS "${_makefile}")
            file(APPEND "${_makefile}"
                "\n# emf.c genuinely needs C++ mode (uses the GDI+ C++ API)\n"
                "coders/MagickCore_libMagickCore_7_${_im_abi_name}_la-emf.lo: CFLAGS += -TP\n"
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

# no share for debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# remove unneeded compile config files under ./tools
file(GLOB im_tools_config_files
    "${CURRENT_PACKAGES_DIR}/tools/imagemagick/bin/*-config"
    "${CURRENT_PACKAGES_DIR}/tools/imagemagick/debug/bin/*-config"
)
file(REMOVE ${im_tools_config_files})

# look for config files spread in multiple paths and delete them, if not build with 'disable-zero-config'
file(GLOB im_rel_config_files
    "${CURRENT_PACKAGES_DIR}/etc/ImageMagick-*/*.xml"
    "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*/config*/*.xml"
    "${CURRENT_PACKAGES_DIR}/share/imagemagick/ImageMagick-*/*.xml"
)
if(NOT DISABLE_ZERO_CONFIG)
    file(REMOVE ${im_rel_config_files})
endif()

file(GLOB im_dbg_config_files
    "${CURRENT_PACKAGES_DIR}/debug/etc/ImageMagick-*/*.xml"
    "${CURRENT_PACKAGES_DIR}/debug/lib/ImageMagick-*/config*/*.xml"
    "${CURRENT_PACKAGES_DIR}/debug/share/imagemagick/ImageMagick-*/*.xml"
)
file(REMOVE ${im_dbg_config_files})

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
