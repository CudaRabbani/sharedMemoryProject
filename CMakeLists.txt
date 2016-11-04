cmake_minimum_required(VERSION 2.8.12)

project(testCmake)

find_package(CUDA QUIET REQUIRED)

include_directories(
common/inc
)

set (CMAKE_BUILD_TYPE Debug)

set (CUDA_SRC

	sources/reconstructionkernel.cu
	sources/reconstruction.h
)

set (CPP_SRC

	sources/main.cpp
	sources/generatepattern.cpp
)

set (H_SRC

	sources/generatepattern.h
	sources/header.h
)

cuda_add_executable(
	testCmake
	${CUDA_SRC}
	${CPP_SRC}
	${H_SRC}
)


