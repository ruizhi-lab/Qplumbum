cmake_minimum_required(VERSION 3.21)

file(STRINGS "${CMAKE_SOURCE_DIR}/makespec/VERSION" PLUMBUM_VERSION)
file(STRINGS "${CMAKE_SOURCE_DIR}/makespec/BUILDVERSION" PLUMBUM_BUILD_VERSION)
file(STRINGS "${CMAKE_SOURCE_DIR}/makespec/VERSIONSUFFIX" PLUMBUM_VERSION_SUFFIX)

set(PLUMBUM_VERSION_STRING "${PLUMBUM_VERSION}${PLUMBUM_VERSION_SUFFIX}")
project(plumbum
    VERSION ${PLUMBUM_VERSION_STRING}
    DESCRIPTION "Linux Qt 6 GUI client for Xray and V2Ray"
    HOMEPAGE_URL "https://github.com/ruizhi-lab/Qplumbum")

macro(QVLOG MSG)
    set(PLUMBUM_BUILD_STATS "${PLUMBUM_BUILD_STATS}${MSG}: ${${MSG}}\r\n")
endmacro()

set(VERSION_LIST ${PLUMBUM_VERSION})
string(REPLACE "." ";" VERSION_LIST ${VERSION_LIST})
separate_arguments(VERSION_LIST)

list(GET VERSION_LIST 0 CMAKE_PROJECT_VERSION_MAJOR)
list(GET VERSION_LIST 1 CMAKE_PROJECT_VERSION_MINOR)
list(GET VERSION_LIST 2 CPACK_PACKAGE_VERSION_PATCH)

add_definitions(-DPLUMBUM_VERSION_MAJOR=${CMAKE_PROJECT_VERSION_MAJOR})
add_definitions(-DPLUMBUM_VERSION_MINOR=${CMAKE_PROJECT_VERSION_MINOR})
add_definitions(-DPLUMBUM_VERSION_BUGFIX=${CPACK_PACKAGE_VERSION_PATCH})
add_definitions(-DPLUMBUM_VERSION_BUILD=${PLUMBUM_BUILD_VERSION})
add_definitions(-DPLUMBUM_VERSION_STRING="${PLUMBUM_VERSION_STRING}")

# Tweaks and other defaults
# Setting CMAKE to use loose block and search for find modules in source directory
set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "Qplumbum currently supports Linux desktop builds only")
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.17.0")
    cmake_policy(SET CMP0100 NEW)
endif()

message(" ")
message("Qplumbum Version: ${PLUMBUM_VERSION_STRING}")
message("Qplumbum Build Version: ${PLUMBUM_BUILD_VERSION}")
message("|-------------------------------------------------|")
message("| Qplumbum, a Linux Qt6 Xray / V2Ray GUI Client.     |")
message("| Licenced under GPLv3                            |")
message("|                                                 |")
message("| You may only use this program to the extent     |")
message("| permitted by local law.                         |")
message("|                                                 |")
message("| See: https://www.gnu.org/licenses/gpl-3.0.html  |")
message("|-------------------------------------------------|")
message("| Project Homepage: https://github.com/ruizhi-lab/Qplumbum |")
message("| Welcome to contribute!                          |")
message("|-------------------------------------------------|")
message(" ")

# ==================================================================================
# Plumbum compile arguments
# ==================================================================================
option(PLUMBUM_AUTO_DEPLOY "Automatically run deploy command after build" ON)
QVLOG(PLUMBUM_AUTO_DEPLOY)

option(BUILD_TESTING "Build Tests" OFF)
QVLOG(BUILD_TESTING)

set(PLUMBUM_DEFAULT_VASSETS_PATH "unset" CACHE STRING "Default V2Ray assets path")
QVLOG(PLUMBUM_DEFAULT_VASSETS_PATH)

set(PLUMBUM_DEFAULT_VCORE_PATH "unset" CACHE STRING "Default V2Ray core path")
QVLOG(PLUMBUM_DEFAULT_VCORE_PATH)

option(PLUMBUM_DISABLE_AUTO_UPDATE "Disable Update Checker" OFF)
QVLOG(PLUMBUM_DISABLE_AUTO_UPDATE)

option(PLUMBUM_HAS_BUILTIN_PLUGINS "Build with builtin plugins" ON)
QVLOG(PLUMBUM_HAS_BUILTIN_PLUGINS)

option(PLUMBUM_EMBED_TRANSLATIONS "Embed Translations" OFF)
option(PLUMBUM_HAS_SINGLEAPPLICATION "Build With SingleApplication" ON)

set(PLUMBUM_UI_TYPE "QML" CACHE STRING "Qplumbum GUI Component")
QVLOG(PLUMBUM_UI_TYPE)

option(PLUMBUM_USE_V5_CORE "Use V5 Core" ON)
QVLOG(PLUMBUM_USE_V5_CORE)

if(PLUMBUM_UI_TYPE STREQUAL "QWidget")
    set(PLUMBUM_USE_QWIDGET ON)
    set(PLUMBUM_USE_QML OFF)
elseif(PLUMBUM_UI_TYPE STREQUAL "QML")
    set(PLUMBUM_USE_QWIDGET OFF)
    set(PLUMBUM_USE_QML ON)
elseif(PLUMBUM_UI_TYPE STREQUAL "CLI")
    set(PLUMBUM_USE_QWIDGET OFF)
    set(PLUMBUM_USE_QML OFF)
else()
    message(FATAL_ERROR "The given PLUMBUM_UI_TYPE: ${PLUMBUM_UI_TYPE} is invalid, expected: QWidget, QML, CLI")
endif()

QVLOG(PLUMBUM_EMBED_TRANSLATIONS)
QVLOG(PLUMBUM_USE_QML)
QVLOG(PLUMBUM_USE_QWIDGET)
QVLOG(PLUMBUM_HAS_SINGLEAPPLICATION)

if(PLUMBUM_HAS_SINGLEAPPLICATION)
    set(PLUMBUM_SINGLEAPPLICATION_PROVIDER "module" CACHE STRING "SingleApplication Provider")
    QVLOG(PLUMBUM_SINGLEAPPLICATION_PROVIDER)
endif()

if(PLUMBUM_USE_QML)
    message("-- Use Qt6 for QML build.")
    option(PLUMBUM_QML_LIVE_UPDATE "Use QMLLive for live updated QML" OFF)
    QVLOG(PLUMBUM_QML_LIVE_UPDATE)
elseif(PLUMBUM_USE_QWIDGET)
    option(PLUMBUM_HAS_BUILTIN_THEMES "Build with built-in themes" ON)
    set(PLUMBUM_QNODEEDITOR_PROVIDER "module" CACHE STRING "QNodeEditor Provider")
    QVLOG(PLUMBUM_HAS_BUILTIN_THEMES)
    QVLOG(PLUMBUM_QNODEEDITOR_PROVIDER)
endif()

cmake_policy(SET CMP0072 NEW)
set(QV_QT_MAJOR_VERSION 6)
set(QV_QT_MINOR_VERSION 5)
set(QV_QT_LIBNAME Qt6)


# ==================================================================================
# Default Core/Assets Path
# ==================================================================================
if(PLUMBUM_DEFAULT_VCORE_PATH AND NOT PLUMBUM_DEFAULT_VCORE_PATH STREQUAL "unset")
    add_definitions(-DPLUMBUM_DEFAULT_VCORE_PATH="${PLUMBUM_DEFAULT_VCORE_PATH}")
endif()
if(PLUMBUM_DEFAULT_VASSETS_PATH AND NOT PLUMBUM_DEFAULT_VASSETS_PATH STREQUAL "unset")
    add_definitions(-DPLUMBUM_DEFAULT_VASSETS_PATH="${PLUMBUM_DEFAULT_VASSETS_PATH}")
endif()

# ==================================================================================
# Embed Translations, Translation Search Path
# ==================================================================================
set(PLUMBUM_TRANSLATION_PATH "unset" CACHE STRING "Qplumbum translations path")
if(PLUMBUM_TRANSLATION_PATH AND NOT PLUMBUM_TRANSLATION_PATH STREQUAL "unset")
    add_definitions(-DPLUMBUM_TRANSLATION_PATH="${PLUMBUM_TRANSLATION_PATH}")
endif()
if(PLUMBUM_EMBED_TRANSLATIONS)
    add_definitions(-DPLUMBUM_EMBED_TRANSLATIONS)
    configure_file(translations/translations.qrc ${CMAKE_BINARY_DIR} COPYONLY)
    set(PLUMBUM_EMBED_TRANSLATION_QRC ${CMAKE_BINARY_DIR}/translations.qrc)
endif()

# ==================================================================================
# Disable Auto Update
# ==================================================================================
if(PLUMBUM_DISABLE_AUTO_UPDATE)
    add_definitions(-DDISABLE_AUTO_UPDATE)
endif()

# ==================================================================================
# Plumbum Build Info
# ==================================================================================
if(PLUMBUM_BUILD_INFO)
    set(_PLUMBUM_BUILD_INFO_STR_ "${PLUMBUM_BUILD_INFO}")
elseif(DEFINED ENV{_PLUMBUM_BUILD_INFO_})
    set(_PLUMBUM_BUILD_INFO_STR_ "$ENV{_PLUMBUM_BUILD_INFO_}")
else()
    set(_PLUMBUM_BUILD_INFO_STR_ "Qplumbum from manual build")
endif()

if(PLUMBUM_BUILD_EXTRA_INFO)
    set(_PLUMBUM_BUILD_EXTRA_INFO_STR_ "${PLUMBUM_BUILD_EXTRA_INFO}")
elseif(DEFINED ENV{_PLUMBUM_BUILD_EXTRA_INFO_})
    set(_PLUMBUM_BUILD_EXTRA_INFO_STR_ "$ENV{_PLUMBUM_BUILD_EXTRA_INFO_}")
else()
    set(_PLUMBUM_BUILD_EXTRA_INFO_STR_ "${PLUMBUM_VERSION_STRING}:${PLUMBUM_BUILD_VERSION}")
endif()

set(PLUMBUM_BUILD_INFO ${_PLUMBUM_BUILD_INFO_STR_})
set(PLUMBUM_BUILD_EXTRA_INFO ${_PLUMBUM_BUILD_EXTRA_INFO_STR_})

add_definitions(-D_PLUMBUM_BUILD_INFO_STR_="${_PLUMBUM_BUILD_INFO_STR_}")
add_definitions(-D_PLUMBUM_BUILD_EXTRA_INFO_STR_="${_PLUMBUM_BUILD_EXTRA_INFO_STR_}")
message("Qplumbum Version: ${_PLUMBUM_BUILD_INFO_STR_} - ${_PLUMBUM_BUILD_EXTRA_INFO_STR_}")

# ==================================================================================
# 3rdparty Sources
# ==================================================================================
include(cmake/libuv.cmake)
include(cmake/libcurl.cmake)
include(cmake/libsemver.cmake)
include(cmake/backend.cmake)
include(3rdparty/QJsonStruct/QJsonStruct.cmake)

# ==================================================================================
# Plumbum Base, Qt Libraries, Plumbum GUI Libraries, libThreads
# ==================================================================================
find_package(Threads REQUIRED)
find_package(${QV_QT_LIBNAME} ${QV_QT_MAJOR_VERSION}.${QV_QT_MINOR_VERSION} COMPONENTS Core Network REQUIRED)
list(APPEND PLUMBUM_QT_LIBS ${QV_QT_LIBNAME}::Core ${QV_QT_LIBNAME}::Network)

cmake_policy(SET CMP0071 NEW)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(PLUMBUM_USE_QML)
    find_package(${QV_QT_LIBNAME} ${QV_QT_MAJOR_VERSION}.${QV_QT_MINOR_VERSION} COMPONENTS Qml Quick Widgets Svg QuickControls2 Gui REQUIRED)
    list(APPEND PLUMBUM_QT_LIBS
        ${QV_QT_LIBNAME}::Quick
        ${QV_QT_LIBNAME}::Qml
        ${QV_QT_LIBNAME}::Widgets
        ${QV_QT_LIBNAME}::Svg
        ${QV_QT_LIBNAME}::QuickControls2
        ${QV_QT_LIBNAME}::Gui)
    set(_PLUMBUM_HAS_GUI_INTERNAL_ ON)
elseif(PLUMBUM_USE_QWIDGET)
    find_package(${QV_QT_LIBNAME} ${QV_QT_MAJOR_VERSION}.${QV_QT_MINOR_VERSION} COMPONENTS Widgets Svg Gui REQUIRED)
    list(APPEND PLUMBUM_QT_LIBS
        ${QV_QT_LIBNAME}::Widgets
        ${QV_QT_LIBNAME}::Svg
        ${QV_QT_LIBNAME}::Gui)
    set(_PLUMBUM_HAS_GUI_INTERNAL_ ON)
else()
endif()

# Plumbum baselib sources
include(cmake/components/plumbum-base.cmake)
include(src/plugin-interface/QvPluginInterface.cmake)

if(PLUMBUM_HAS_SINGLEAPPLICATION)
    include(cmake/singleapplication.cmake)
else()
    add_definitions(-DPLUMBUM_NO_SINGLEAPPLICATON)
endif()

add_library(plumbum_baselib STATIC
    ${PLUMBUM_BASE_SOURCES}
    ${SINGLEAPPLICATION_SOURCES}
    ${QVPLUGIN_INTERFACE_HEADERS}
    ${LIBSEMVER_SOURCES}
    ${PROTO_SRCS}
    ${PROTO_HDRS}
    ${API_GRPC_SRCS}
    ${API_PROTO_SRCS}
    )

target_link_libraries(plumbum_baselib
    ${PLUMBUM_QT_LIBS}
    ${PLUMBUM_BACKEND_LIBRARY}
    ${LibUV_LIBRARIES}
    ${CURL_LIBRARIES}
    ${SINGLEAPPLICATION_LIBRARY}
    Threads::Threads
    )

target_include_directories(plumbum_baselib PUBLIC
    ${CMAKE_BINARY_DIR}
    ${PLUMBUM_BASEDIR_COMPONENTS}
    ${LibUV_INCLUDE_DIR}
    ${SINGLEAPPLICATION_DIR}
    ${CURL_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${Protobuf_INCLUDE_DIRS}
    )

if(PLUMBUM_USE_V5_CORE)
    message("-- Use V2Ray Core V5")
    target_compile_definitions(plumbum_baselib PUBLIC PLUMBUM_USE_V5_CORE)
endif()

# ==================================================================================
# Plumbum Builtin Plugins
# ==================================================================================
if(PLUMBUM_HAS_BUILTIN_PLUGINS)
    include(src/plugins/protocols/QvPlugin-BuiltinProtocolSupport.cmake)
    include(src/plugins/subscription-adapters/QvPlugin-BuiltinSubscriptionAdapters.cmake)
    #include(src/plugins/utils/QvPlugin-BuiltinUtils.cmake)
endif()

# ==================================================================================
# Plumbum UI Frontend
# ==================================================================================
if(_PLUMBUM_HAS_GUI_INTERNAL_)
    add_definitions(-DPLUMBUM_GUI)
    include(cmake/qrencode.cmake)

    include(cmake/components/plumbum-ui.cmake)
    list(APPEND PLUMBUM_UI_SOURCES ${PLUMBUM_UI_COMMON_SOURCES})

    include(src/plugin-interface/QvGUIPluginInterface.cmake)
    list(APPEND PLUMBUM_UI_SOURCES ${QVGUIPLUGIN_INTERFACE_HEADERS})

    if(PLUMBUM_USE_QML)
        add_definitions(-DPLUMBUM_GUI_QML)
        include(cmake/components/plumbum-ui-qml.cmake)
        list(APPEND PLUMBUM_UI_SOURCES ${PLUMBUM_QML_SOURCES})
    elseif(PLUMBUM_USE_QWIDGET)
        add_definitions(-DPLUMBUM_GUI_QWIDGETS)
        include(cmake/components/plumbum-ui-widget.cmake)
        list(APPEND PLUMBUM_UI_SOURCES ${PLUMBUM_UI_WIDGET_SOURCES})
        #
        if (PLUMBUM_HAS_BUILTIN_THEMES)
            include(3rdparty/uistyles/uistyles.cmake)
            list(APPEND PLUMBUM_QRC_RESOURCES ${UISTYLE_QRCS})
        endif()
        #
        include(cmake/qnodeeditor.cmake)
        list(APPEND PLUMBUM_QRC_RESOURCES ${QNODEEDITOR_QRC_RESOURCES})
    endif()
else()
    add_definitions(-DPLUMBUM_CLI)
    include(cmake/components/plumbum-cli.cmake)
    list(APPEND PLUMBUM_UI_SOURCES ${PLUMBUM_CLI_SOURCES})
endif()

# Platform Dependent Sources
include(cmake/components/plumbum-platform.cmake)
include(cmake/translations.cmake)

list(APPEND PLUMBUM_QRC_RESOURCES
    ${CMAKE_SOURCE_DIR}/resources.qrc
    ${CMAKE_SOURCE_DIR}/resources.new.qrc
    )

set(PLUMBUM_FULL_SOURCES
    ${PLUMBUM_RC}
    ${CMAKE_CURRENT_LIST_DIR}/src/main.cpp
    ${PLUMBUM_UI_SOURCES}
    ${PLUMBUM_PLATFORM_SOURCES}
    ${PLUMBUM_EMBED_TRANSLATION_QRC}
    ${PLUMBUM_QRC_RESOURCES}
    ${PLUMBUM_QM_FILES}
    )

QVLOG(PLUMBUM_QM_FILES)
QVLOG(PLUMBUM_QRC_RESOURCES)

qt6_add_executable(plumbum ${GUI_TYPE} ${PLUMBUM_FULL_SOURCES})

# set_target_properties(MAIN PROPERTIES OUTPUT_NAME "plumbum")

target_include_directories(plumbum PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_BINARY_DIR}
    ${QNODEEDITOR_INCLUDE_PATH}
    ${Protobuf_INCLUDE_DIRS}
    )

target_link_libraries(plumbum PUBLIC
    plumbum_baselib
    ${QNODEEDITOR_LIBRARY}
    ${PLUMBUM_PLATFORM_LIBS}
    ${PLUMBUM_QRENCODE_LIBRARY}
    )


# ==================================================================================
# Plumbum Unit Tests
# ==================================================================================
if (BUILD_TESTING)
    include(CTest)
    add_subdirectory(test)
endif()

# ==================================================================================
# Platform-dependent installation process and deployment
# ==================================================================================
include(cmake/platforms/linux.cmake)


# ==================================================================================
# Print Plumbum Build Statistics
# ==================================================================================
get_target_property(PLUMBUM_BASE_LINK_LIBS plumbum_baselib LINK_LIBRARIES)
get_target_property(PLUMBUM_EXEC_LINK_LIBS plumbum LINK_LIBRARIES)
QVLOG(PLUMBUM_BUILD_VERSION)
QVLOG(PLUMBUM_VERSION_STRING)
QVLOG(CMAKE_INSTALL_PREFIX)
QVLOG(CMAKE_BINARY_DIR)
QVLOG(PLUMBUM_BASE_LINK_LIBS)
QVLOG(PLUMBUM_EXEC_LINK_LIBS)
message("")
message("======== Qplumbum Build Statistics ========")
message("${PLUMBUM_BUILD_STATS}")
message("=========================================")
message("")
