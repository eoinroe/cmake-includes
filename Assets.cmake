  # HEADS UP: Pamplejuce assumes anything you stick in the assets folder you want to included in your binary!                                                                                                              
  # This makes life easy, but will bloat your binary needlessly if you include unused files                                                                                                                                
  file(GLOB_RECURSE AssetFiles CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/assets/*")
  list (FILTER AssetFiles EXCLUDE REGEX "/\\.DS_Store$") # We don't want the .DS_Store on macOS though...                                                                                                                  

  # Include the precompiled Metal shader library on macOS                                                                                                                                                                  
  if(APPLE AND DEFINED METALLIB_OUTPUT)
      list(APPEND AssetFiles ${METALLIB_OUTPUT})
      set_source_files_properties(${METALLIB_OUTPUT} PROPERTIES GENERATED TRUE)
  endif()

  # Include precompiled HLSL shader blobs on Windows                                                                                                                                                                       
  if(WIN32 AND DEFINED HLSL_CSO_FILES)
      list(APPEND AssetFiles ${HLSL_CSO_FILES})
      set_source_files_properties(${HLSL_CSO_FILES} PROPERTIES GENERATED TRUE)
  endif()

  # Setup our binary data as a target called Assets                                                                                                                                                                        
  juce_add_binary_data(Assets SOURCES ${AssetFiles})

  # Ensure Metal shaders are compiled before BinaryData processes them                                                                                                                                                     
  if(APPLE AND TARGET MetalShaders)
      add_dependencies(Assets MetalShaders)
  endif()

  if(WIN32 AND TARGET HLSLShaders)
      add_dependencies(Assets HLSLShaders)
  endif()

  # Required for Linux happiness:                                                                                                                                                                                          
  # See https://forum.juce.com/t/loading-pytorch-model-using-binarydata/39997/2
  set_target_properties(Assets PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
                                                                                        