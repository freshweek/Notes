# CMAKE generated file: DO NOT EDIT!
# Generated by "MinGW Makefiles" Generator, CMake Version 3.24

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

SHELL = cmd.exe

# The CMake executable.
CMAKE_COMMAND = D:\CMake\bin\cmake.exe

# The command to remove a file.
RM = D:\CMake\bin\cmake.exe -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = E:\Notes\CMake

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = E:\Notes\build

# Include any dependencies generated for this target.
include math/CMakeFiles/math.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include math/CMakeFiles/math.dir/compiler_depend.make

# Include the progress variables for this target.
include math/CMakeFiles/math.dir/progress.make

# Include the compile flags for this target's objects.
include math/CMakeFiles/math.dir/flags.make

math/CMakeFiles/math.dir/oper.cpp.obj: math/CMakeFiles/math.dir/flags.make
math/CMakeFiles/math.dir/oper.cpp.obj: E:/Notes/CMake/math/oper.cpp
math/CMakeFiles/math.dir/oper.cpp.obj: math/CMakeFiles/math.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=E:\Notes\build\CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object math/CMakeFiles/math.dir/oper.cpp.obj"
	cd /d E:\Notes\build\math && D:\Mingw64\bin\g++.exe $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT math/CMakeFiles/math.dir/oper.cpp.obj -MF CMakeFiles\math.dir\oper.cpp.obj.d -o CMakeFiles\math.dir\oper.cpp.obj -c E:\Notes\CMake\math\oper.cpp

math/CMakeFiles/math.dir/oper.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/math.dir/oper.cpp.i"
	cd /d E:\Notes\build\math && D:\Mingw64\bin\g++.exe $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E E:\Notes\CMake\math\oper.cpp > CMakeFiles\math.dir\oper.cpp.i

math/CMakeFiles/math.dir/oper.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/math.dir/oper.cpp.s"
	cd /d E:\Notes\build\math && D:\Mingw64\bin\g++.exe $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S E:\Notes\CMake\math\oper.cpp -o CMakeFiles\math.dir\oper.cpp.s

# Object files for target math
math_OBJECTS = \
"CMakeFiles/math.dir/oper.cpp.obj"

# External object files for target math
math_EXTERNAL_OBJECTS =

bin/libmath.dll: math/CMakeFiles/math.dir/oper.cpp.obj
bin/libmath.dll: math/CMakeFiles/math.dir/build.make
bin/libmath.dll: math/CMakeFiles/math.dir/linklibs.rsp
bin/libmath.dll: math/CMakeFiles/math.dir/objects1.rsp
bin/libmath.dll: math/CMakeFiles/math.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=E:\Notes\build\CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX shared library ..\bin\libmath.dll"
	cd /d E:\Notes\build\math && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles\math.dir\link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
math/CMakeFiles/math.dir/build: bin/libmath.dll
.PHONY : math/CMakeFiles/math.dir/build

math/CMakeFiles/math.dir/clean:
	cd /d E:\Notes\build\math && $(CMAKE_COMMAND) -P CMakeFiles\math.dir\cmake_clean.cmake
.PHONY : math/CMakeFiles/math.dir/clean

math/CMakeFiles/math.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "MinGW Makefiles" E:\Notes\CMake E:\Notes\CMake\math E:\Notes\build E:\Notes\build\math E:\Notes\build\math\CMakeFiles\math.dir\DependInfo.cmake --color=$(COLOR)
.PHONY : math/CMakeFiles/math.dir/depend

