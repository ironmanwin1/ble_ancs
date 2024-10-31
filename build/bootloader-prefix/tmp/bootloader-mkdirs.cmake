# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "C:/Users/spide/esp/v5.3.1/esp-idf/components/bootloader/subproject"
  "D:/ble_ancs/build/bootloader"
  "D:/ble_ancs/build/bootloader-prefix"
  "D:/ble_ancs/build/bootloader-prefix/tmp"
  "D:/ble_ancs/build/bootloader-prefix/src/bootloader-stamp"
  "D:/ble_ancs/build/bootloader-prefix/src"
  "D:/ble_ancs/build/bootloader-prefix/src/bootloader-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "D:/ble_ancs/build/bootloader-prefix/src/bootloader-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "D:/ble_ancs/build/bootloader-prefix/src/bootloader-stamp${cfgdir}") # cfgdir has leading slash
endif()