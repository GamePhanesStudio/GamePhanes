cmake_minimum_required(VERSION 3.16)
project(shadow_runtime LANGUAGES CXX)

add_library(shadow_runtime STATIC
    engine/src/render/graphics.cpp
    engine/src/scene/scene.cpp
)
target_include_directories(shadow_runtime PUBLIC engine/include)
target_compile_features(shadow_runtime PUBLIC cxx_std_17)
