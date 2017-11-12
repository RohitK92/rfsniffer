INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_RFSNIFFER rfsniffer)

FIND_PATH(
    RFSNIFFER_INCLUDE_DIRS
    NAMES rfsniffer/api.h
    HINTS $ENV{RFSNIFFER_DIR}/include
        ${PC_RFSNIFFER_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/include
          /usr/include
)

FIND_LIBRARY(
    RFSNIFFER_LIBRARIES
    NAMES gnuradio-rfsniffer
    HINTS $ENV{RFSNIFFER_DIR}/lib
        ${PC_RFSNIFFER_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /usr/local/lib
          /usr/local/lib64
          /usr/lib
          /usr/lib64
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(RFSNIFFER DEFAULT_MSG RFSNIFFER_LIBRARIES RFSNIFFER_INCLUDE_DIRS)
MARK_AS_ADVANCED(RFSNIFFER_LIBRARIES RFSNIFFER_INCLUDE_DIRS)

