if (CMAKE_VERSION VERSION_GREATER_EQUAL "4.0.0")
  set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
endif()

cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

set(CMAKE_POLICY_DEFAULT_CMP0063 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0069 NEW)

project(sherpa-onnx)

# Remember to update
# ./CHANGELOG.md
# ./new-release.sh
set(SHERPA_ONNX_VERSION "1.12.1")

# Disable warning about
#
# "The DOWNLOAD_EXTRACT_TIMESTAMP option was not given and policy CMP0135 is
#  not set.
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()


if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  set(SUGGEST_BUILD_BINARIES ON)
else()
  set(SUGGEST_BUILD_BINARIES OFF)
endif()

option(SHERPA_ONNX_ENABLE_TESTS "Whether to build tests" OFF)
option(SHERPA_ONNX_ENABLE_CHECK "Whether to build with assert" OFF)
option(BUILD_SHARED_LIBS "Whether to build shared libraries" OFF)
option(SHERPA_ONNX_ENABLE_JNI "Whether to build JNI internface" ON)
option(SHERPA_ONNX_ENABLE_C_API "Whether to build C API" OFF)

option(SHERPA_ONNX_ENABLE_BINARY "Whether to build binaries" ${SUGGEST_BUILD_BINARIES})
option(SHERPA_ONNX_ENABLE_TTS "Whether to build TTS related code" ON)
option(SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION "Whether to build speaker diarization related code" ON)
option(SHERPA_ONNX_LINK_LIBSTDCPP_STATICALLY "True to link libstdc++ statically. Used only when BUILD_SHARED_LIBS is OFF on Linux" ON)
option(SHERPA_ONNX_USE_PRE_INSTALLED_ONNXRUNTIME_IF_AVAILABLE "True to use pre-installed onnxruntime if available" ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

if(NOT CMAKE_BUILD_TYPE)
  message(STATUS "No CMAKE_BUILD_TYPE given, default to Release")
  set(CMAKE_BUILD_TYPE Release)
endif()

if(DEFINED ANDROID_ABI AND NOT SHERPA_ONNX_ENABLE_JNI AND NOT SHERPA_ONNX_ENABLE_C_API)
  message(STATUS "Set SHERPA_ONNX_ENABLE_JNI to ON for Android")
  set(SHERPA_ONNX_ENABLE_JNI ON CACHE BOOL "" FORCE)
endif()

message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS}")
message(STATUS "SHERPA_ONNX_ENABLE_TESTS ${SHERPA_ONNX_ENABLE_TESTS}")
message(STATUS "SHERPA_ONNX_ENABLE_CHECK ${SHERPA_ONNX_ENABLE_CHECK}")
message(STATUS "SHERPA_ONNX_ENABLE_JNI ${SHERPA_ONNX_ENABLE_JNI}")
message(STATUS "SHERPA_ONNX_ENABLE_BINARY ${SHERPA_ONNX_ENABLE_BINARY}")
message(STATUS "SHERPA_ONNX_ENABLE_TTS ${SHERPA_ONNX_ENABLE_TTS}")
message(STATUS "SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION ${SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION}")
message(STATUS "SHERPA_ONNX_LINK_LIBSTDCPP_STATICALLY ${SHERPA_ONNX_LINK_LIBSTDCPP_STATICALLY}")
message(STATUS "SHERPA_ONNX_USE_PRE_INSTALLED_ONNXRUNTIME_IF_AVAILABLE ${SHERPA_ONNX_USE_PRE_INSTALLED_ONNXRUNTIME_IF_AVAILABLE}")

if(BUILD_SHARED_LIBS OR SHERPA_ONNX_ENABLE_JNI)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
  set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

if(BUILD_SHARED_LIBS AND NOT CMAKE_SYSTEM_NAME STREQUAL iOS AND CMAKE_BUILD_TYPE STREQUAL Release)
  # Don't use LTO for iOS since it causes the following error
  # error: unable to find any architecture information in the binary
  # at '/Users/fangjun/open-source/sherpa-onnx/build-ios/build/os64/sherpa-onnx.a':
  # Unknown header: 0xb17c0de
  # See also https://forums.developer.apple.com/forums/thread/714324

  include(CheckIPOSupported)
  check_ipo_supported(RESULT ipo)
  if(ipo)
    message(STATUS "IPO is enabled")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
  else()
    message(STATUS "IPO is not available")
  endif()
endif()

if(SHERPA_ONNX_ENABLE_TTS)
  message(STATUS "TTS is enabled")
  add_definitions(-DSHERPA_ONNX_ENABLE_TTS=1)
else()
  message(WARNING "TTS is disabled")
  add_definitions(-DSHERPA_ONNX_ENABLE_TTS=0)
endif()

if(SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION)
  message(STATUS "speaker diarization is enabled")
  add_definitions(-DSHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=1)
else()
  message(WARNING "speaker diarization is disabled")
  add_definitions(-DSHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=0)
endif()

if(SHERPA_ONNX_ENABLE_DIRECTML)
  message(STATUS "DirectML is enabled")
  add_definitions(-DSHERPA_ONNX_ENABLE_DIRECTML=1)
else()
  message(STATUS "DirectML is disabled")
  add_definitions(-DSHERPA_ONNX_ENABLE_DIRECTML=0)
endif()

if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17 CACHE STRING "The C++ version to be used.")
endif()
set(CMAKE_CXX_EXTENSIONS OFF)
message(STATUS "C++ Standard version: ${CMAKE_CXX_STANDARD}")

include(CheckIncludeFileCXX)

check_include_file_cxx(cxxabi.h SHERPA_ONNX_HAVE_CXXABI_H)
check_include_file_cxx(execinfo.h SHERPA_ONNX_HAVE_EXECINFO_H)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(kaldi-native-fbank)
include(kaldi-decoder)
include(onnxruntime)
include(simple-sentencepiece)
set(ONNXRUNTIME_DIR ${onnxruntime_SOURCE_DIR})
message(STATUS "ONNXRUNTIME_DIR: ${ONNXRUNTIME_DIR}")

if(SHERPA_ONNX_ENABLE_TESTS)
  enable_testing()
  include(googletest)
endif()

if(SHERPA_ONNX_ENABLE_TTS)
  include(espeak-ng-for-piper)
  set(ESPEAK_NG_DIR ${espeak_ng_SOURCE_DIR})
  message(STATUS "ESPEAK_NG_DIR: ${ESPEAK_NG_DIR}")
  include(piper-phonemize)
endif()

include(cppjieba) # It is a header-only C++ library

if(SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION)
  include(hclust-cpp)
endif()

add_subdirectory(sherpa-onnx)

message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")

if(NOT BUILD_SHARED_LIBS)
  if(APPLE)
    set(SHERPA_ONNX_PKG_CONFIG_EXTRA_LIBS "-lc++ -framework Foundation")
  endif()

  if(UNIX AND NOT APPLE)
    set(SHERPA_ONNX_PKG_CONFIG_EXTRA_LIBS "-lstdc++ -lm -pthread -ldl")
  endif()
endif()

message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
