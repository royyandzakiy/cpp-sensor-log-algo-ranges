cmake_minimum_required(VERSION 3.28..3.31)

# =============================================================================
# Project Configuration
# =============================================================================
project(sensor_log_algo_ranges 
    LANGUAGES CXX
    VERSION 1.0.0
)

# =============================================================================
# Compiler Configuration
# =============================================================================
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
cmake_policy(SET CMP0091 NEW)

if(MSVC)
    add_compile_options(/W4 /permissive- /WX)
else()
    # Clang/GCC
    add_compile_options(-Wall -Wextra -Werror -pedantic)
endif()

# =============================================================================
# Sanitizers Configuration (Clang/GCC only)
# =============================================================================
option(ENABLE_SANITIZERS "Enable Address, Undefined, and Leak sanitizers" ON)

if(ENABLE_SANITIZERS AND NOT MSVC)
    message(STATUS "Building with Address, Undefined, and Leak Sanitizers")
    
    set(SANITIZER_FLAGS 
        -fsanitize=address,undefined,leak 
        -fno-omit-frame-pointer
    )
    
    # Add to compiler flags
    add_compile_options(${SANITIZER_FLAGS})
    
    # Add to linker flags (CRITICAL: sanitizers need library linking)
    add_link_options(${SANITIZER_FLAGS})
endif()

# =============================================================================
# Dependencies
# =============================================================================
# find_package(fmt REQUIRED)

# =============================================================================
# Main Executable
# =============================================================================
add_executable(${PROJECT_NAME} 
    src/main.cpp
)

# target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)