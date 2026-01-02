#
#
#

SHELL=/bin/sh

# The user can decide if thet want to use a different compiler (e.g. clang)
# Example:
#	$ make assemble CXX=clang++-20 CXX_FLAGS="-Wall -Xanalyzer"
#
#
CXX?=g++
CXX_FLAGS?=-Wall -fanalyzer -std=${CXX_STD}
CXX_STD?=c++20

# Directories
#
SRC_DIR:=src
INC_DIR:=include
BUILD_DIR:=build
DEBUG_DIR:=${BUILD_DIR}/debug
OBJ_DIR:=${BUILD_DIR}/.obj
ASM_DIR:=${BUILD_DIR}/.asm

# Source files
#
SRCS:= main.cpp
ASMS:=$(patsubst %.cpp,%.s,${SRCS})
OBJS:=$(patsubst %.cpp,%.o,${SRCS})
INC:=main.h
BIN:=main

VPATH=${SRC_DIR}:${INC_DIR}

.DEFAULT_GOAL : help

# Note that using `echo -e` is not POSIX compliant
#
help:
	@echo "Help menu:"
	@echo -e "\tmake help (default)             - prints help menu"
	@echo -e "\tmake build                      - builds program"
	@echo -e "\tmake assemble                   - builds the assembly files for the program"
	@echo -e "\tmake debug (build is a pre-req) - builds a debug version of the executable"
	@echo -e "\tmake clean                      - cleans artifacts"
	@echo -e "\tmake obj                        - creates object files but does not link"
	@echo ""
.PHONY: help

build: ${OBJS}
	@echo "Starting to build (Objects)"
	@if [ ! -d ${OBJ_DIR} ]; then \
		echo "Creating build directory."; \
		mkdir ${OBJ_DIR}; \
	fi;
	@mv *.o ${OBJ_DIR}
	@if [ ! -d ${DEBUG_DIR} ]; then \
		echo "Creating a debug directory." \
		mkdir ${DEBUG_DIR}; \
	fi;
	@pushd ${OBJ_DIR}; \
	$(CXX) $(CXX_FLAGS) ${OBJS} -o ${BIN}; popd; \
	if [ -f ${OBJ_DIR}/${BIN} ]; then \
		mv ${OBJ_DIR}/${BIN} ${BUILD_DIR}/${BIN}; \
	fi;
	@echo -e "\x1b[38;5;2mSuccess!\x1b[0m"
.PHONY: build

assemble: ${ASMS}
	@echo "Starting to build (Assembly *.s )"
	@if [ ! -d ${ASM_DIR} ]; then \
		echo "Creating build directory."; \
		mkdir ${ASM_DIR}; \
	fi;
	@mv *.s ${ASM_DIR}
	@echo -e "Assembled files"
.PHONY: assemble

clean:
	echo "Cleaning artifacts"
	rm -rf ${DEBUG_DIR}
	rm -rf ${OBJ_DIR}
	rm -rf ${ASM_DIR}
.PHONY: clean

%.o : %.cpp
	$(CXX) $(CXX_FLAGS) -c $< -o $@

%.s : %.cpp
	$(CXX) $(CXX_FLAGS) $@ -S $<