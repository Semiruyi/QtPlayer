# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appQtPlayer_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appQtPlayer_autogen.dir\\ParseCache.txt"
  "appQtPlayer_autogen"
  )
endif()
