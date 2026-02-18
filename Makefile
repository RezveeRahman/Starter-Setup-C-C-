# Makefile
#
# @author: Rezvee Rahman
# @date:   01/10/2026
#
# @details: This file is the build system for our project.
#

SHELL=/bin/sh

# The user can decide if thet want to use a different compiler (e.g. clang)
# Example:
#	$ make assemble CXX=clang++-20 CXX_FLAGS="-Wall -Xanalyzer"
#
# Alternatively do the following:
#	$ make assemble CLANG=True
#

CLANG=false

# Compilers
#
CXX?=g++
CXX_FLAGS?=-Wall -fanalyzer -std=${CXX_STD}
CXX_STD=c++20

CC=gcc
CC_FLAGS?=-Wall -fanalyzer -std=${CC_STD}
CC_STD=c17

ifeq (${CLANG},true)
	CXX=clang++-20;
	CXX_FLAGS=-Wall -Xanalyzer -std=${CXX_STD}
endif


# Directories
#
SRC_DIR=src
INC_DIR=include
BUILD_DIR=build
DEBUG_DIR:=${BUILD_DIR}/debug
OBJ_DIR:=${BUILD_DIR}/.obj
ASM_DIR:=${BUILD_DIR}/.asm

# Source files
#
SRCS= main.c
INC=main.h
BIN=main


ASMS=$(patsubst %.cpp,%.s,${SRCS})
ASMS=$(patsubst %.c,%.s,${SRCS})

OBJS=$(patsubst %.cpp,%.o,${SRCS})
OBJS=$(patsubst %.c,%.o,${SRCS})

VPATH=${SRC_DIR}

.DEFAULT_GOAL : help

# Note that using `echo -e` is not POSIX compliant
#
help:
	@echo "Help menu:\n"
	@echo "\tmake help (default)             - prints help menu\n"
	@echo "\tmake run                        - builds and runs the program\n"
	@echo "\tmake build                      - builds program\n"
	@echo "\tmake assemble                   - builds the assembly files for the program\n"
	@echo "\tmake debug (build is a pre-req) - builds a debug version of the executable\n"
	@echo "\tmake clean                      - cleans artifacts\n"
	@echo "\tmake obj                        - creates object files but does not link\n"
	@echo "\n"
.PHONY: help

run : build
	@${BUILD_DIR}/${BIN}
.PHONY: run

exe: build
	@cd ${OBJ_DIR}; \
	$(CC) $(CC_FLAGS) -o ${BIN} ${OBJS}; \
	mv ${BIN} ../
.PHONY: exe

build: ${OBJS} ${ASMS} build_directory
	@mv ${OBJS} ${OBJ_DIR}/
	@mv ${ASMS} ${ASM_DIR}/
	@echo -e "\x1b[38;5;2mSuccess!\x1b[0m\n"
.PHONY: build

clean:
	@echo -e "\x1b[38;5;3mCleaning artifacts\x1b[0m"
	@rm -rf ${DEBUG_DIR}
	@rm -rf ${OBJ_DIR}
	@rm -rf ${ASM_DIR}
	@rm -rf ${BUILD_DIR}/${BIN}
.PHONY: clean

build_directory:
	@mkdir -p ${BUILD_DIR};
	@mkdir -p {${OBJ_DIR},${ASM_DIR}}
.PHONY: build_directory

%.o : %.c
	$(CC) $(CC_FLAGS) -c $< -o $@ -I${INC_DIR}

%.o : %.cpp
	$(CXX) $(CXX_FLAGS) -c $< -o $@ -I${INC_DIR}

%.s : %.c
	$(CC) $(CC_FLAGS) -S $< -o $@ -I${INC_DIR}

%.s : %.cpp
	$(CXX) $(CXX_FLAGS) -S $< -o $@ -I${INC_DIR}