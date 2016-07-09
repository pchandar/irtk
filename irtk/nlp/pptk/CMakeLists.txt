cmake_minimum_required(VERSION 3.5)
project(pptk C CXX)
add_library(pptk SHARED ${SOURCES})

set_target_properties(pptk PROPERTIES LINKER_LANGUAGE CXX)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -m64 -std=c++11")

set(SOURCE_FILES src/*.cpp)

include_directories(include)


