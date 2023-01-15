cmake_minimum_required(VERSION 3.24)
set(LIBRARY_OUTPUT_DIRECTORY {CMAKE_BINARY_DIR}/lib)
add_library(math SHARED oper.cpp)
target_include_directories(math INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})