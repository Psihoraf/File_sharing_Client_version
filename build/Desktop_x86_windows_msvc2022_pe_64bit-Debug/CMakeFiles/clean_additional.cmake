# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appMyClient_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appMyClient_autogen.dir\\ParseCache.txt"
  "appMyClient_autogen"
  )
endif()
