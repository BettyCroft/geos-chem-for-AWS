# Build the fullchem mechanism if configured with -DMECH=fullchem
# (This is the default option)
if("${MECH}" STREQUAL fullchem)
  add_subdirectory(fullchem)
endif()

# Comment out this option for now (bmy, 9/16/21)
## Build the aciduptake mechanism if configured with -DMECH=aciduptake
#if("${MECH}" STREQUAL aciduptake)
#  add_subdirectory(aciduptake)
#endif()

# Build the custom mechanism if configured with -DMECH=custom
if("${MECH}" STREQUAL custom)
  add_subdirectory(custom)
endif()

