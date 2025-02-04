cmake_minimum_required(VERSION 3.10)
project(wzhutest)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Debug)

find_package(OpenGL REQUIRED)
find_package(glfw3 REQUIRED)

add_library(glad STATIC glad.c)

add_executable(wzhutest main.cpp)
target_link_libraries(wzhutest PRIVATE glfw glad OpenGL::GL)
