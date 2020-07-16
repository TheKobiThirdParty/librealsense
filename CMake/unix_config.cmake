message(STATUS "Setting Unix configurations")

macro(os_set_flags)
    set(BACKEND RS2_USE_V4L2_BACKEND)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -fPIC -pedantic -g -D_BSD_SOURCE")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -pedantic -g -Wno-missing-field-initializers")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-switch -Wno-multichar -Wsequence-point -Wformat-security")

    add_definitions(-DUSE_SYSTEM_LIBUSB)

    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpmachine OUTPUT_VARIABLE MACHINE)
    if(${MACHINE} MATCHES "arm-linux-gnueabihf")
        set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -mfpu=neon -mfloat-abi=hard -ftree-vectorize")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon -mfloat-abi=hard -ftree-vectorize")
    elseif(${MACHINE} MATCHES "aarch64-linux-gnu")
        set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -mstrict-align -ftree-vectorize")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mstrict-align -ftree-vectorize")
    else()
        set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -mssse3")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mssse3")
        set(LRS_TRY_USE_AVX true)
    endif(${MACHINE} MATCHES "arm-linux-gnueabihf")

    if(NOT BUILD_WITH_OPENMP)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
    endif()

    if(APPLE)
        set(FORCE_LIBUVC ON)
        set(BUILD_WITH_TM2 OFF)
    endif()
endmacro()

macro(os_target_config)
    find_file (LibUSB_HEADER_FILE
      NAMES
        libusb.h usb.h
      HINTS
        /usr
        /usr/local
      PATH_SUFFIXES
        include
        include/libusb-1.0
    )
    get_filename_component (LibUSB_INCLUDE_DIRS "${LibUSB_HEADER_FILE}" PATH)
    mark_as_advanced(LibUSB_INCLUDE_DIRS)

    find_library (LibUSB_LIBRARY
      NAMES
        usb-1.0 libusb usb
      HINTS
        /usr
        /usr/local
      PATH_SUFFIXES
        lib
        lib/gcc
    )
    mark_as_advanced(LibUSB_LIBRARY)

    message(STATUS "libusb include dirs: ${LibUSB_INCLUDE_DIRS}")
    message(STATUS "libusb library: ${LibUSB_LIBRARY}")

    target_include_directories(${LRS_TARGET} PRIVATE ${LibUSB_INCLUDE_DIRS})
    target_link_libraries(${LRS_TARGET} PRIVATE ${LibUSB_LIBRARY})
endmacro()
