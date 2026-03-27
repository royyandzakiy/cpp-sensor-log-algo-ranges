# =============================================================================
# Windows Development Environment Setup
# =============================================================================
cmake_minimum_required(VERSION 3.20)

message(STATUS "Running Windows dependency setup...")

# --- Admin privileges check (best effort) ---
execute_process(
    COMMAND net session
    RESULT_VARIABLE IS_ADMIN
    OUTPUT_QUIET ERROR_QUIET
)
if(NOT IS_ADMIN EQUAL 0)
    message(WARNING "Some operations may require administrator privileges (PATH modification, system installs)")
endif()

# --- Configuration ---
set(VCPKG_ROOT "C:/vcpkg" CACHE PATH "Path to vcpkg installation")
set(GIT_PATH "C:/Program Files/Git" CACHE PATH "Git install path")
set(DOXYGEN_PATH "C:/Program Files/doxygen" CACHE PATH "Doxygen install path")

# --- Helper function for downloading and installing ---
function(download_and_install name url installer_args)
    set(tmpfile "${CMAKE_BINARY_DIR}/${name}-installer.exe")
    message(STATUS "Downloading ${name} from ${url}")
    
    file(DOWNLOAD 
        "${url}" 
        "${tmpfile}" 
        STATUS download_status
        SHOW_PROGRESS
    )
    
    list(GET download_status 0 status_code)
    if(NOT status_code EQUAL 0)
        message(WARNING "Failed to download ${name} installer")
        return()
    endif()
    
    message(STATUS "Installing ${name}...")
    execute_process(
        COMMAND "${tmpfile}" ${installer_args}
        RESULT_VARIABLE install_result
        TIMEOUT 300  # 5 minute timeout
    )
    
    if(NOT install_result EQUAL 0)
        message(WARNING "Failed to install ${name} (exit code: ${install_result})")
    else()
        message(STATUS "Successfully installed ${name}")
    endif()
    
    # Cleanup
    if(EXISTS "${tmpfile}")
        file(REMOVE "${tmpfile}")
    endif()
endfunction()

# --- Git Installation Check ---
message(STATUS "Checking Git installation...")
find_program(GIT_EXE git PATHS "${GIT_PATH}/bin" "$ENV{ProgramFiles}/Git/bin")
if(NOT GIT_EXE)
    message(STATUS "Git not found. Installing Git for Windows...")
    download_and_install(
        "git"
        "https://github.com/git-for-windows/git/releases/download/v2.45.1.windows.1/Git-2.45.1-64-bit.exe"
        "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS=icons,ext\\reg\\shellhere,assoc,assoc_sh"
    )
    
    # Refresh Git executable search
    unset(GIT_EXE CACHE)
    find_program(GIT_EXE git PATHS "${GIT_PATH}/bin" "$ENV{ProgramFiles}/Git/bin")
else()
    message(STATUS "Git found: ${GIT_EXE}")
endif()

# --- Doxygen Installation Check ---
message(STATUS "Checking Doxygen installation...")
find_program(DOXYGEN_EXE doxygen PATHS "${DOXYGEN_PATH}/bin" "$ENV{ProgramFiles}/doxygen/bin")
if(NOT DOXYGEN_EXE)
    message(STATUS "Doxygen not found. Installing...")
    download_and_install(
        "doxygen"
        "https://www.doxygen.nl/files/doxygen-1.10.0-setup.exe"
        "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES"
    )
else()
    message(STATUS "Doxygen found: ${DOXYGEN_EXE}")
endif()

# --- vcpkg Installation Check ---
message(STATUS "Checking vcpkg installation...")
if(NOT EXISTS "${VCPKG_ROOT}/vcpkg.exe")
    if(NOT GIT_EXE)
        message(WARNING "Git not available - cannot install vcpkg")
    else()
        message(STATUS "vcpkg not found. Cloning and bootstrapping...")
        
        # Create parent directory if it doesn't exist
        get_filename_component(VCPKG_PARENT_DIR "${VCPKG_ROOT}" DIRECTORY)
        if(NOT EXISTS "${VCPKG_PARENT_DIR}")
            file(MAKE_DIRECTORY "${VCPKG_PARENT_DIR}")
        endif()
        
        execute_process(
            COMMAND "${GIT_EXE}" clone https://github.com/microsoft/vcpkg.git "${VCPKG_ROOT}"
            RESULT_VARIABLE git_clone_result
            WORKING_DIRECTORY "${VCPKG_PARENT_DIR}"
        )
        
        if(NOT git_clone_result EQUAL 0)
            message(WARNING "Failed to clone vcpkg repository")
        else()
            message(STATUS "Bootstrapping vcpkg...")
            execute_process(
                COMMAND "${VCPKG_ROOT}/bootstrap-vcpkg.bat" -disableMetrics
                WORKING_DIRECTORY "${VCPKG_ROOT}"
                RESULT_VARIABLE bootstrap_result
            )
            
            if(NOT bootstrap_result EQUAL 0)
                message(WARNING "vcpkg bootstrap failed")
            else()
                message(STATUS "vcpkg bootstrap successful")
            endif()
        endif()
    endif()
else()
    message(STATUS "vcpkg found: ${VCPKG_ROOT}/vcpkg.exe")
endif()

# --- Set environment for current CMake session ---
if(EXISTS "${VCPKG_ROOT}")
    set(ENV{VCPKG_ROOT} "${VCPKG_ROOT}")
    
    # Only set toolchain if vcpkg is properly installed
    if(EXISTS "${VCPKG_ROOT}/vcpkg.exe")
        set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")
        message(STATUS "Vcpkg toolchain configured: ${CMAKE_TOOLCHAIN_FILE}")
    endif()
endif()

# --- Verify critical dependencies ---
message(STATUS "--- Dependency Verification ---")
if(GIT_EXE)
    message(STATUS "✓ Git: ${GIT_EXE}")
else()
    message(STATUS "✗ Git: Not found")
endif()

if(DOXYGEN_EXE)
    message(STATUS "✓ Doxygen: ${DOXYGEN_EXE}")
else()
    message(STATUS "✗ Doxygen: Not found")
endif()

if(EXISTS "${VCPKG_ROOT}/vcpkg.exe")
    message(STATUS "✓ vcpkg: ${VCPKG_ROOT}")
else()
    message(STATUS "✗ vcpkg: Not properly installed")
endif()

message(STATUS "============================================")
message(STATUS " Windows Development Setup Complete ")
message(STATUS "============================================")