#!/bin/bash
#---------------------------------------------------------------------------------
# Build scripts for
#	devkitPPC release 24
#---------------------------------------------------------------------------------

if [ 0 -eq 1 ] ; then
  echo "Currently in release cycle, proceed with caution, do not report problems, do not ask for support."
  echo "Please use the latest release buildscripts unless advised otherwise by devkitPro staff."
  echo "http://sourceforge.net/projects/devkitpro/files/buildscripts/"
  echo
  echo "The scripts in svn are quite often dependent on things which currently only exist on developer"
  echo "machines. This is not a bug, use stable releases."
  exit 1
fi


#---------------------------------------------------------------------------------
# specify some urls to download the source packages from
#---------------------------------------------------------------------------------
LIBOGC_VER=1.8.7
LIBMIRKO_VER=0.9.7
MAXMOD_VER=1.0.6
FILESYSTEM_VER=0.9.9
LIBFAT_VER=1.0.10

LIBOGC="libogc-src-$LIBOGC_VER.tar.bz2"
MAXMOD="maxmod-src-$MAXMOD_VER.tar.bz2"
FILESYSTEM="libfilesystem-src-$FILESYSTEM_VER.tar.bz2"
LIBFAT="libfat-src-$LIBFAT_VER.tar.bz2"
LIBMIRKO="libmirko-src-$LIBMIRKO_VER.tar.bz2"
DEVKITPRO_URL="http://downloads.sourceforge.net/devkitpro"

LIBOGC_URL="$DEVKITPRO_URL/$LIBOGC"
LIBMIRKO_URL="$DEVKITPRO_URL/$LIBMIRKO"
MAXMOD_URL="$DEVKITPRO_URL/$MAXMOD"
FILESYSTEM_URL="$DEVKITPRO_URL/$FILESYSTEM"
LIBFAT_URL="$DEVKITPRO_URL/$LIBFAT"

#---------------------------------------------------------------------------------
# Sane defaults for building toolchain
#---------------------------------------------------------------------------------
export CFLAGS="-O2 -pipe"
export CXXFLAGS="$CFLAGS"
unset LDFLAGS

#---------------------------------------------------------------------------------
# Look for automated configuration file to bypass prompts
#---------------------------------------------------------------------------------
 
BUILD_DKPRO_PACKAGE=2

BUILD_DKPRO_DOWNLOAD=0

BUILD_DKPRO_INSTALLDIR=/home/twin_aphex/bin/devkitpro

SRCDIR=/home/twin_aphex/devkit/srcdir

BUILD_DKPRO_AUTOMATED=1

#---------------------------------------------------------------------------------
# Ask whether to download the source packages or not
#---------------------------------------------------------------------------------

echo
echo "This script will build and install devkitPPC."

GCC_VER=4.6.1
BINUTILS_VER=2.21
NEWLIB_VER=1.19.0
GDB_VER=7.2
basedir='dkppc'
package=devkitPPC
builddir=powerpc-eabi
target=powerpc-eabi
toolchain=DEVKITPPC

GCC_CORE="gcc-core-$GCC_VER.tar.bz2"
GCC_GPP="gcc-g++-$GCC_VER.tar.bz2"
GCC_OBJC="gcc-objc-$GCC_VER.tar.bz2"

GCC_CORE_URL="$DEVKITPRO_URL/$GCC_CORE"
GCC_GPP_URL="$DEVKITPRO_URL/gcc-g++-$GCC_VER.tar.bz2"
GCC_OBJC_URL="$DEVKITPRO_URL/$GCC_OBJC"

BINUTILS="binutils-$BINUTILS_VER.tar.bz2"
GDB="gdb-$GDB_VER.tar.bz2"
GDB_URL="$DEVKITPRO_URL/$GDB"
BINUTILS_URL="$DEVKITPRO_URL/$BINUTILS"
NEWLIB="newlib-$NEWLIB_VER.tar.gz"
NEWLIB_URL="$DEVKITPRO_URL/$NEWLIB"

DOWNLOAD=0

if [ ! -z "$BUILD_DKPRO_DOWNLOAD" ] ; then
	DOWNLOAD="$BUILD_DKPRO_DOWNLOAD"
fi

#---------------------------------------------------------------------------------
# Get preferred installation directory and set paths to the sources
#---------------------------------------------------------------------------------

if [ ! -z "$BUILD_DKPRO_INSTALLDIR" ] ; then
	INSTALLDIR="$BUILD_DKPRO_INSTALLDIR"
else
	echo
	echo "Please enter the directory where you would like '$package' to be installed:"
	echo "for mingw/msys you must use <drive>:/<install path> or you will have include path problems"
	echo "this is the top level directory for devkitpro, i.e. e:/devkitPro"

	read INSTALLDIR
	echo
fi

[ ! -z "$INSTALLDIR" ] && mkdir -p $INSTALLDIR && touch $INSTALLDIR/nonexistantfile && rm $INSTALLDIR/nonexistantfile || exit 1;

BINUTILS_SRCDIR="binutils-$BINUTILS_VER"
GCC_SRCDIR="gcc-$GCC_VER"
GDB_SRCDIR="gdb-$GDB_VER"
NEWLIB_SRCDIR="newlib-$NEWLIB_VER"
LIBOGC_SRCDIR="libogc-$LIBOGC_VER"
LIBFAT_SRCDIR="libfat-$LIBFAT_VER"
MAXMOD_SRCDIR="maxmod-$MAXMOD_VER"
FILESYSTEM_SRCDIR="filesystem-$FILESYSTEM_VER"
LIBMIRKO_SRCDIR="libmirko-$LIBMIRKO_VER"


#---------------------------------------------------------------------------------
# find proper make
#---------------------------------------------------------------------------------
if [ -z "$MAKE" -a -x "$(which gnumake)" ]; then MAKE=$(which gnumake); fi
if [ -z "$MAKE" -a -x "$(which gmake)" ]; then MAKE=$(which gmake); fi
if [ -z "$MAKE" -a -x "$(which make)" ]; then MAKE=$(which make); fi
if [ -z "$MAKE" ]; then
  echo no make found
  exit 1
fi
echo use $MAKE as make
export MAKE

  
#---------------------------------------------------------------------------------
# find proper gawk
#---------------------------------------------------------------------------------
if [ -z "$GAWK" -a -x "$(which gawk)" ]; then GAWK=$(which gawk); fi
if [ -z "$GAWK" -a -x "$(which awk)" ]; then GAWK=$(which awk); fi
if [ -z "$GAWK" ]; then
  echo no awk found
  exit 1
fi
echo use $GAWK as gawk
export GAWK

#---------------------------------------------------------------------------------
# find makeinfo, needed for newlib
#---------------------------------------------------------------------------------
if [ ! -x $(which makeinfo) ]; then
  echo makeinfo not found
  exit 1
fi

#---------------------------------------------------------------------------------
# Add installed devkit to the path, adjusting path on minsys
#---------------------------------------------------------------------------------
TOOLPATH=$(echo $INSTALLDIR | sed -e 's/^\([a-zA-Z]\):/\/\1/')
export PATH=$PATH:$TOOLPATH/$package/bin

if [ "$BUILD_DKPRO_AUTOMATED" != "1" ] ; then

	echo
	echo 'Ready to install '$package' in '$INSTALLDIR
	echo
	echo 'press return to continue'

	read dummy
fi

patchdir=$(pwd)/$basedir/patches
scriptdir=$(pwd)/$basedir/scripts

#---------------------------------------------------------------------------------
# Extract source packages
#---------------------------------------------------------------------------------

BUILDSCRIPTDIR=$(pwd)

if [ ! -f extracted_archives ]
then
  echo "Extracting $BINUTILS"
  tar -xjf $SRCDIR/$BINUTILS || { echo "Error extracting "$BINUTILS; exit 1; }

  echo "Downloading $GCC_CORE"
  cd $SRCDIR
  wget http://ftp.gnu.org/gnu/gcc/gcc-4.6.1/gcc-core-4.6.1.tar.bz2 
  cd ..
  echo "Extracting $GCC_CORE"
  tar -xjf $SRCDIR/$GCC_CORE || { echo "Error extracting "$GCC_CORE; exit 1; }

  echo "Downloading $GCC_GPP"
  cd $SRCDIR
  wget http://ftp.gnu.org/gnu/gcc/gcc-4.6.1/gcc-g++-4.6.1.tar.bz2
  cd ..
  echo "Extracting $GCC_GPP"
  tar -xjf $SRCDIR/$GCC_GPP || { echo "Error extracting "$GCC_GPP; exit 1; }

  echo "Downloading $GCC_OBJC"
  cd $SRCDIR
  wget http://ftp.gnu.org/gnu/gcc/gcc-4.6.1/gcc-objc-4.6.1.tar.bz2
  cd ..
  echo "Extracting $GCC_OBJC"
  tar -xjf $SRCDIR/$GCC_OBJC || { echo "Error extracting "$GCC_OBJC; exit 1; }

  echo "Extracting $NEWLIB"
  tar -xzf $SRCDIR/$NEWLIB || { echo "Error extracting "$NEWLIB; exit 1; }

  echo "Downloading $GDB"
  cd $SRCDIR
  wget http://mirrors.usc.edu/pub/gnu/gdb/gdb-7.2.tar.bz2
  cd ..
  echo "Extracting $GDB"
  tar -xjf $SRCDIR/$GDB || { echo "Error extracting "$GDB; exit 1; }

  echo "Extracting $LIBOGC"
  mkdir -p $LIBOGC_SRCDIR
  bzip2 -cd $SRCDIR/$LIBOGC | tar -xf - -C $LIBOGC_SRCDIR  || { echo "Error extracting "$LIBOGC; exit 1; }

  echo "Extracting $LIBFAT"
  mkdir -p $LIBFAT_SRCDIR
  bzip2 -cd $SRCDIR/$LIBFAT | tar -xf - -C $LIBFAT_SRCDIR || { echo "Error extracting "$LIBFAT; exit 1; }

  touch extracted_archives

fi

#---------------------------------------------------------------------------------
# apply patches
#---------------------------------------------------------------------------------
if [ ! -f patched_sources ]
then

  if [ -f $patchdir/binutils-$BINUTILS_VER.patch ]
  then
    patch -p1 -d $BINUTILS_SRCDIR -i $patchdir/binutils-$BINUTILS_VER.patch || { echo "Error patching binutils"; exit 1; }
  fi

  if [ -f $patchdir/gcc-$GCC_VER.patch ]
  then
    patch -p1 -d $GCC_SRCDIR -i $patchdir/gcc-$GCC_VER.patch || { echo "Error patching gcc"; exit 1; }
  fi

  if [ -f $patchdir/newlib-$NEWLIB_VER.patch ]
  then
    patch -p1 -d $NEWLIB_SRCDIR -i $patchdir/newlib-$NEWLIB_VER.patch || { echo "Error patching newlib"; exit 1; }
  fi

  if [ -f $patchdir/gdb-$GDB_VER.patch ]
  then
    patch -p1 -d $GDB_SRCDIR -i $patchdir/gdb-$GDB_VER.patch || { echo "Error patching gdb"; exit 1; }
  fi

  touch patched_sources
fi

#---------------------------------------------------------------------------------
# Build and install devkit components
#---------------------------------------------------------------------------------
if [ -f $scriptdir/build-gcc.sh ]; then . $scriptdir/build-gcc.sh || { echo "Error building toolchain"; exit 1; }; cd $BUILDSCRIPTDIR; fi
if [ -f $scriptdir/build-crtls.sh ]; then . $scriptdir/build-crtls.sh || { echo "Error building crtls"; exit 1; }; cd $BUILDSCRIPTDIR; fi
if [ -f $scriptdir/build-tools.sh ]; then . $scriptdir/build-tools.sh || { echo "Error building tools"; exit 1; }; cd $BUILDSCRIPTDIR; fi

#---------------------------------------------------------------------------------
# strip binaries
# strip has trouble using wildcards so do it this way instead
#---------------------------------------------------------------------------------
for f in $INSTALLDIR/$package/bin/* \
         $INSTALLDIR/$package/$target/bin/* \
         $INSTALLDIR/$package/libexec/gcc/$target/$GCC_VER/*
do
  # exclude dll for windows, so for linux/osx, directories .la files, embedspu script & the gccbug text file
  if  ! [[ "$f" == *.dll || "$f" == *.so || -d $f || "$f" == *.la || "$f" == *-embedspu || "$f" == *-gccbug ]]
  then
    strip $f
  fi
done

#---------------------------------------------------------------------------------
# strip debug info from libraries
#---------------------------------------------------------------------------------
find $INSTALLDIR/$package/lib/gcc/$target -name *.a -exec $target-strip -d {} \;
find $INSTALLDIR/$package/$target -name *.a -exec $target-strip -d {} \;

#---------------------------------------------------------------------------------
# Clean up temporary files and source directories
#---------------------------------------------------------------------------------

if [ "$BUILD_DKPRO_AUTOMATED" != "1" ] ; then
  echo
  echo "Would you like to delete the build folders and patched sources? [Y/n]"
  read answer
else
  answer=y
fi

if [ "$answer" != "n" -a "$answer" != "N" ]
  then

  echo "Removing patched sources and build directories"

  rm -fr $target
  rm -fr $BINUTILS_SRCDIR
  rm -fr $NEWLIB_SRCDIR
  rm -fr $GCC_SRCDIR
  rm -fr $LIBOGC_SRCDIR $LIBMIRKO_SRCDIR $LIBFAT_SRCDIR $GDB_SRCDIR $MAXMOD_SRCDIR $FILESYSTEM_SRCDIR
  rm -fr mn10200
  rm -fr extracted_archives patched_sources checkout-psp-sdk

fi

echo
echo "note: Add the following to your environment;  DEVKITPRO=$TOOLPATH $toolchain=$TOOLPATH/$package"
echo
