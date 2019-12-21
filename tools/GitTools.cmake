macro(find_git)
  find_package(Git)
  
  if(NOT Git_FOUND)
    message(FATAL_ERROR "Could not find git executable!")
  endif()
endmacro()

function(git_fetch)
  set(options "")
  set(oneValueArgs DIRECTORY REPOSITORY)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_FETCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  find_git()
  execute_process(COMMAND ${GIT_EXECUTABLE} fetch --all WORKING_DIRECTORY ${GIT_FETCH_DIRECTORY})
endfunction()

function(git_checkout)
  set(options "")
  set(oneValueArgs DIRECTORY REPOSITORY)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_CHECKOUT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT EXISTS ${GIT_CHECKOUT_DIRECTORY})
    find_git()
    message(STATUS "Checkout ${GIT_CHECKOUT_REPOSITORY} to ${GIT_CHECKOUT_DIRECTORY}")
    execute_process(COMMAND ${GIT_EXECUTABLE} clone ${GIT_CHECKOUT_REPOSITORY} ${GIT_CHECKOUT_DIRECTORY})
  else()
    message(STATUS "Found subdirectory ${GIT_CHECKOUT_DIRECTORY}")
  endif()
endfunction()

function(git_change_branch)
  set(options "")
  set(oneValueArgs DIRECTORY BRANCH)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_CHANGE_BRANCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(EXISTS ${GIT_CHANGE_BRANCH_DIRECTORY})
    find_git()
    message(STATUS "Update to ${GIT_CHANGE_BRANCH_BRANCH}")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} checkout ${GIT_CHANGE_BRANCH_BRANCH} 
        WORKING_DIRECTORY ${GIT_CHANGE_BRANCH_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git update branch ${GIT_CHANGE_BRANCH_BRANCH} failed !")
    endif()
  endif()
endfunction()

function(git_update_branch)
  set(options "")
  set(oneValueArgs DIRECTORY BRANCH)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_UPDATE_BRANCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(EXISTS ${GIT_UPDATE_BRANCH_DIRECTORY})
    find_git()
    message(STATUS "Update to ${GIT_UPDATE_BRANCH_BRANCH}")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} checkout ${GIT_UPDATE_BRANCH_BRANCH} 
        WORKING_DIRECTORY ${GIT_UPDATE_BRANCH_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git update branch ${GIT_UPDATE_BRANCH_BRANCH} failed !")
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} status
        WORKING_DIRECTORY ${GIT_UPDATE_BRANCH_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git update branch ${GIT_UPDATE_BRANCH_BRANCH} failed !")
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} pull
        WORKING_DIRECTORY ${GIT_UPDATE_BRANCH_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git update branch ${GIT_UPDATE_BRANCH_BRANCH} failed !")
    endif()
  endif()
endfunction()

function(git_new_branch)
  set(options "")
  set(oneValueArgs DIRECTORY BRANCH)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_NEW_BRANCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(EXISTS ${GIT_NEW_BRANCH_DIRECTORY})
    find_git()
    message(STATUS "New branch ${GIT_NEW_BRANCH_BRANCH}")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} checkout -b ${GIT_NEW_BRANCH_BRANCH} 
        WORKING_DIRECTORY ${GIT_NEW_BRANCH_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git new branch ${GIT_NEW_BRANCH_BRANCH} failed !")
    endif()
  endif()
endfunction()

function(git_add)
  set(options "")
  set(oneValueArgs DIRECTORY)
  set(multiValueArgs FILES)
  cmake_parse_arguments(GIT_ADD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(EXISTS ${GIT_ADD_DIRECTORY})
    find_git()
    message(STATUS "Add to git: ${GIT_ADD_FILES}")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} add ${GIT_ADD_FILES} 
        WORKING_DIRECTORY ${GIT_ADD_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git add ${GIT_ADD_BRANCH} failed !")
    endif()
  endif()
endfunction()

function(git_get_branch)
  set(options "")
  set(oneValueArgs DIRECTORY)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_GET_BRANCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  find_git()
  message(STATUS "Get branch ${GIT_GET_BRANCH_DIRECTORY}")
  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${GIT_GET_BRANCH_DIRECTORY} symbolic-ref --short HEAD OUTPUT_VARIABLE BRANCH)
  string(REPLACE "\n" "" _GIT_BRANCH ${BRANCH})
  message(STATUS "Branch ${_GIT_BRANCH}")
  set(GIT_BRANCH ${_GIT_BRANCH} PARENT_SCOPE)
endfunction()

function(git_submodule_update)
  set(options "")
  set(oneValueArgs SUBMODULE DIRECTORY)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_SUBMODULE_UPDATE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  message(STATUS "Try to checkout ... ${GIT_SUBMODULE_UPDATE_SUBMODULE}")
  find_package(Git REQUIRED)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} submodule update --init -- ${GIT_SUBMODULE_UPDATE_SUBMODULE}
    WORKING_DIRECTORY ${GIT_SUBMODULE_UPDATE_DIRECTORY}
    RESULT_VARIABLE _RESULT
    ERROR_VARIABLE _ERR)
    if(_RESULT)
        message(SEND_ERROR "Executing: ${GIT_EXECUTABLE} submodule update --init -- ${GIT_SUBMODULE_UPDATE_SUBMODULE} in working dir ${GIT_SUBMODULE_UPDATE_GIT_DIRECTORY}\n${_ERR}")
        message(FATAL_ERROR "Checkout ${GIT_SUBMODULE_UPDATE_DIRECTORY} FAILED!")
    endif()
endfunction()

function(git_commit)
  set(options "")
  set(oneValueArgs DIRECTORY MESSAGE)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_COMMIT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(EXISTS ${GIT_COMMIT_DIRECTORY})
    find_git()
    message(STATUS "New branch ${GIT_COMMIT_MESSAGE}")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} commit -m "${GIT_COMMIT_MESSAGE}"
        WORKING_DIRECTORY ${GIT_COMMIT_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git commit ${GIT_COMMIT_MESSAGE} failed !")
    endif()
  endif()
endfunction()

function(git_merge_branch)
  set(options "")
  set(oneValueArgs DIRECTORY BRANCH)
  set(multiValueArgs "")
  cmake_parse_arguments(GIT_MERGE_BRANCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(EXISTS ${GIT_MERGE_BRANCH_DIRECTORY})
    find_git()
    message(STATUS "Update to ${GIT_MERGE_BRANCH_BRANCH}")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} merge ${GIT_MERGE_BRANCH_BRANCH} 
        WORKING_DIRECTORY ${GIT_MERGE_BRANCH_DIRECTORY}
        RESULT_VARIABLE _RESULT
        ERROR_VARIABLE _ERR
    )
    if(_RESULT)
        message(SEND_ERROR "${_ERR}")
        message(FATAL_ERROR "git update branch ${GIT_MERGE_BRANCH_BRANCH} failed !")
    endif()
  endif()
endfunction()
