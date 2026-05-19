cmake_minimum_required(VERSION 3.12)
project(ligero)

add_executable(ligero
            main.cpp
            ${CMAKE_SOURCE_DIR}/depends/libff/libff/algebra/fields/goldilocks_pp.cpp
            ${CMAKE_SOURCE_DIR}/depends/libff/libff/algebra/fields/goldilocks_field.cpp)

# Option to select the field: default = Goldilocks
option(USE_BN254 "Use AltBN128 instead of Goldilocks" OFF)

if(USE_BN254)
    target_compile_definitions(ligero PRIVATE USE_BN254)
else()
    target_compile_definitions(ligero PRIVATE USE_GOLDILOCKS)
endif()

# Link libraries
target_link_libraries(ligero PRIVATE
    iop
    ${GMP_LIBRARIES}
    gmpxx
    simdjson
)