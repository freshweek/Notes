cmake_minimum_required(VERSION 3.24)

project(cmake_hello)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/dll)
set(LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/dll)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
# set(SOURCES test.cpp
#     math/oper.cpp
#     math/oper.h
# )
# add_library(math SHARED math/oper.cpp)
# add_library(math STATIC math/oper.cpp)
add_subdirectory(math)

add_executable(cmake_hello test.cpp)
# add_executable(cmake_hello ${SOURCES})
target_link_libraries(cmake_hello math)