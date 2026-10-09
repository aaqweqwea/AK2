cmake_minimum_required(VERSION 3.16)
project(SampleStats VERSION 1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
add_compile_options(-Wall -Wextra -Wpedantic)

add_library(samplestats SHARED samplestats.c)
target_include_directories(samplestats PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
add_executable(stats-demo main.c)
target_link_libraries(stats-demo PRIVATE samplestats)
set_target_properties(stats-demo PROPERTIES BUILD_RPATH "$ORIGIN")
