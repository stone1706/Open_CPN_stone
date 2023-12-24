# - Try to find Glib and its components (gio, gobject etc)
# Once done, this will define
#
#  GLIB_FOUND - system has Glib
#  GLIB_INCLUDE_DIRS - the Glib include directories
#  GLIB_LIBRARIES - link these to use Glib
#
# Optionally, the COMPONENTS keyword can be passed to find_package()
# and Glib components can be looked for.  Currently, the following
# components can be used, and they define the following variables if
# found:
#
#  gio:             GLIB_GIO_LIBRARIES
#  gobject:         GLIB_GOBJECT_LIBRARIES
#  gmodule:         GLIB_GMODULE_LIBRARIES
#  gthread:         GLIB_GTHREAD_LIBRARIES
#
# Note that the respective _INCLUDE_DIR variables are not set, since
# all headers are in the same directory as GLIB_INCLUDE_DIRS.
#
# Copyright (C) 2012 Raphael Kubo da Costa <rakuco@webkit.org>
# Copyright (c) 2023 Alec Leamas
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND ITS CONTRIBUTORS ``AS
# IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR ITS
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

find_library(GLIB_LIBRARIES NAMES glib-2.0)

# Files in glib's main include path may include glibconfig.h, which,
# is normally in $LIBDIR/glib-2.0/include.
get_filename_component(_GLIB_LIBRARY_DIR ${GLIB_LIBRARIES} PATH)
find_path(GLIBCONFIG_INCLUDE_DIR
    NAMES glibconfig.h
    HINTS ${_GLIB_LIBRARY_DIR}
    PATH_SUFFIXES glib-2.0/include
)
find_path(GLIB_INCLUDE_DIR
    NAMES glib.h
    PATH_SUFFIXES glib-2.0
)
set(GLIB_INCLUDE_DIRS ${GLIB_INCLUDE_DIR} ${GLIBCONFIG_INCLUDE_DIR})
# Additional Glib components.  We only look for libraries, as not all of them
# have corresponding headers and all headers are installed alongside the main
# glib ones.
foreach (_component ${GLIB_FIND_COMPONENTS})
  if (${_component} STREQUAL "gio")
    find_library(
      GLIB_GIO_LIBRARIES NAMES gio-2.0 HINTS ${_GLIB_LIBRARY_DIR}
    )
    list(APPEND ADDITIONAL_REQUIRED_VARS ${GLIB_GIO_LIBRARIES})
  elseif (${_component} STREQUAL "gobject")
    find_library(
      GLIB_GOBJECT_LIBRARIES NAMES gobject-2.0 HINTS ${_GLIB_LIBRARY_DIR}
    )
    list(APPEND ADDITIONAL_REQUIRED_VARS ${GLIB_GOBJECT_LIBRARIES})
  elseif (${_component} STREQUAL "gmodule")
    find_library(
      GLIB_GMODULE_LIBRARIES NAMES gmodule-2.0 HINTS ${_GLIB_LIBRARY_DIR}
    )
    list(APPEND ADDITIONAL_REQUIRED_VARS ${GLIB_GMODULE_LIBRARIES})
  elseif (${_component} STREQUAL "gthread")
    find_library(
      GLIB_GTHREAD_LIBRARIES NAMES gthread-2.0 HINTS ${_GLIB_LIBRARY_DIR}
    )
    list(APPEND ADDITIONAL_REQUIRED_VARS ${GLIB_GTHREAD_LIBRARIES})
  endif ()
endforeach ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GLIB REQUIRED_VARS GLIB_INCLUDE_DIRS
  GLIB_LIBRARIES ${ADDITIONAL_REQUIRED_VARS} VERSION_VAR   GLIB_VERSION
)
if (GLIB_LIBRARIES AND GLIB_INCLUDE_DIRS)
  set(GLIB_FOUND 1)
endif ()
add_library(_GLIB_IF INTERFACE)
add_library(glib::glib ALIAS _GLIB_IF)
target_link_libraries(_GLIB_IF
  INTERFACE ${GLIB_LIBRARIES} ${ADDITIONAL_REQUIRED_VARS}
)
target_include_directories(_GLIB_IF INTERFACE ${GLIB_INCLUDE_DIRS})