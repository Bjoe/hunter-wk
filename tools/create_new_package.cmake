#!/usr/bin/cmake -P

include(${CMAKE_CURRENT_LIST_DIR}/GitTools.cmake)
find_git()

if("${PKG}" STREQUAL "")
  message(FATAL_ERROR "No PKG parameter")
endif()

set(HUNTER_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/../hunter")

include(${CMAKE_CURRENT_LIST_DIR}/hunter-git.config)
git_checkout(DIRECTORY ${HUNTER_SRC_DIR} REPOSITORY ${HUNTER_ORIG_REPO})
git_fetch(DIRECTORY ${HUNTER_SRC_DIR})
git_update_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH master)
git_submodule_update(DIRECTORY ${HUNTER_SRC_DIR} SUBMODULE gate)
git_new_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH pr.${PKG})

configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/hunter.cmake.in 
  ${HUNTER_SRC_DIR}/cmake/projects/${PKG}/hunter.cmake 
  @ONLY)
  
configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/foo.rst.in
  ${HUNTER_SRC_DIR}/docs/packages/pkg/${PKG}.rst
  @ONLY
)

configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/example-CMakeLists.txt.in
  ${HUNTER_SRC_DIR}/examples/${PKG}/CMakeLists.txt
  @ONLY
)

file(COPY ${HUNTER_SRC_DIR}/examples/foo/boo.cpp
  DESTINATION ${HUNTER_SRC_DIR}/examples/${PKG}
)

git_add(DIRECTORY ${HUNTER_SRC_DIR} FILES 
"cmake/projects/${PKG}/hunter.cmake" 
"docs/packages/pkg/${PKG}.rst"
"examples/${PKG}/CMakeLists.txt"
"examples/${PKG}/boo.cpp"
)

git_commit(DIRECTORY ${HUNTER_SRC_DIR} MESSAGE "Initial commit")


#
# Create pkg branch
#
git_update_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH pkg.template)
git_new_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH pr.pkg.${PKG})

file(READ "${HUNTER_SRC_DIR}/.travis.yml" TRAVIS_CONTENT)
string(REPLACE "foo" "${PKG}" UPDATE_TRAVIS_CONTENT "${TRAVIS_CONTENT}")
file(WRITE "${HUNTER_SRC_DIR}/.travis.yml" "${UPDATE_TRAVIS_CONTENT}")

file(READ "${HUNTER_SRC_DIR}/appveyor.yml" APPVEYOR_CONTENT)
string(REPLACE "foo" "${PKG}" UPDATE_APPVEYOR_CONTENT "${APPVEYOR_CONTENT}")
file(WRITE "${HUNTER_SRC_DIR}/appveyor.yml" "${UPDATE_APPVEYOR_CONTENT}")

git_add(DIRECTORY ${HUNTER_SRC_DIR} FILES .travis.yml appveyor.yml)
git_commit(DIRECTORY ${HUNTER_SRC_DIR} MESSAGE "Test ${PKG} package")

#
# Create test branch
#
git_change_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH pr.${PKG})
git_new_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH test.${PKG})
git_merge_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH pr.pkg.${PKG})


git_change_branch(DIRECTORY ${HUNTER_SRC_DIR} BRANCH pr.${PKG})

message("Edit following files:")
message("cmake/configs/default.cmake         <------ Add version number!")
message("cmake/projects/${PKG}/hunter.cmake")
message("docs/packages/pkg/${PKG}.rst")
message("examples/${PKG}/CMakeLists.txt")
message("examples/${PKG}/boo.cpp")
