
# -------------------------------
# download source from github repo
# -------------------------------

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libultrahdr
    REF v2.0.2
    SHA512 a5df720e8c9af6f2fa19a015040b3a572a764145079d3a843520407a5f5dc1dc2a80c91b6000248cc99e27f30b7d18a7d7e22bc0c3d24122eea33bcc1eb4b1b9
    HEAD_REF main
    PATCHES
        0001-use-crt-from-vcpkg.patch
)

# -------------------------------
# create configure options
# -------------------------------

# set default configure flags
set(CONFIGURE_ARGS "")
list(APPEND CONFIGURE_ARGS
    "-DUHDR_BUILD_TESTS=OFF"
    "-DUHDR_BUILD_BENCHMARK=OFF"
    "-DUHDR_BUILD_FUZZERS=OFF"
    "-DUHDR_BUILD_DEPS=OFF"
    "-DUHDR_BUILD_JAVA=OFF"
    "-DUHDR_BUILD_PACKAGING=OFF"
    "-DUHDR_ENABLE_INSTALL=ON"
    "-DUHDR_ENABLE_INTRINSICS=ON"
    "-DUHDR_ENABLE_SMPTE2094_50=OFF"
)

# seem to be not compatible with vcpkg
list(APPEND CONFIGURE_ARGS
    "-DUHDR_ENABLE_GLES=OFF"
    "-DUHDR_ENABLE_HEIF=OFF"
)

# -------------------------------
# run cmake
# -------------------------------

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${CONFIGURE_ARGS}
)

# -------------------------------
# install
# -------------------------------

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# -------------------------------
# fix/remove installed files
# -------------------------------

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")


# Collect every executable in bin/ and move it to tools/${PORT}
file(GLOB TOOL_FILES "${CURRENT_PACKAGES_DIR}/bin/*")
set(TOOL_NAMES "")
foreach(tool_file IN LISTS TOOL_FILES)
    get_filename_component(tool_name "${tool_file}" NAME_WLE)
    list(APPEND TOOL_NAMES "${tool_name}")
endforeach()

if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()
