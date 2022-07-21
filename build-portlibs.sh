#!/bin/sh
BUILD_DIR=/home/twin_aphex/devkit
SRCDIR=$BUILD_DIR/portlibssrcdir
BUILD_DKPRO_INSTALLDIR=/home/twin_aphex/bin/devkitpro

# Build dirs
BUILD_DIR_MXML=$BUILD_DIR/mxml
BUILD_DIR_FREETYPE=$BUILD_DIR/freetype
BUILD_DIR_ZLIB=$BUILD_DIR/zlib
BUILD_DIR_TREMOR=$BUILD_DIR/tremor
BUILD_DIR_LIBPNG=$BUILD_DIR/libpng
BUILD_DIR_EXPAT=$BUILD_DIR/expat

#---------------------------------------------------------------------------------
# MXML
#---------------------------------------------------------------------------------

if [ ! -d "$BUILD_DIR_MXML" ] ; then
	mkdir $BUILD_DIR_MXML
fi

cd $BUILD_DIR_MXML
tar -xjf $SRCDIR/mxml-2.6-ppc.tar.bz2
cp include/mxml.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp lib/libmxml.a $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii/
echo "Copied mxml files to install dir: $BUILD_DKPRO_INSTALLDIR"
echo "Now cleaning up.."
cd $BUILD_DIR
rm -rf $BUILD_DIR_MXML

#---------------------------------------------------------------------------------
# Freetype
#---------------------------------------------------------------------------------

if [ ! -d "$BUILD_DIR_FREETYPE" ] ; then
	mkdir $BUILD_DIR_FREETYPE
fi
cd $BUILD_DIR_FREETYPE
tar -xjf $SRCDIR/freetype-2.4.2-ppc.tar.bz2
cp bin/freetype-config $BUILD_DKPRO_INSTALLDIR/devkitPPC/bin/
cp include/ft2build.h $BUILD_DKPRO_INSTALLDIR/libogc/include/

if [ ! -d "$BUILD_DKPRO_INSTALLDIR/libogc/include/freetype2" ] ; then
	cp -r include/freetype2/freetype $BUILD_DKPRO_INSTALLDIR/libogc/include/freetype
else
	rm -rf $BUILD_DKPRO_INSTALLDIR/libogc/include/freetype
	cp -r include/freetype2/freetype $BUILD_DKPRO_INSTALLDIR/libogc/include/freetype
fi

cp lib/libfreetype.a $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii/
echo "Copied freetype files to install dir $BUILD_DKPRO_INSTALLDIR"
echo "Now cleaning up.."
cd $BUILD_DIR
rm -rf $BUILD_DIR_FREETYPE

#---------------------------------------------------------------------------------
# Zlib
#---------------------------------------------------------------------------------
if [ ! -d "$BUILD_DIR_ZLIB" ] ; then
	mkdir $BUILD_DIR_ZLIB
fi
cd $BUILD_DIR_ZLIB
tar -xjf $SRCDIR/zlib-1.2.5-ppc.tar.bz2
cp include/zconf.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp include/zlib.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp lib/libz.a $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii
echo "Copied zlib files to install dir $BUILD_DKPRO_INSTALLDIR"
echo "Now cleaning up.."
cd $BUILD_DIR
rm -rf $BUILD_DIR_ZLIB

#---------------------------------------------------------------------------------
# Tremor
#---------------------------------------------------------------------------------
if [ ! -d "$BUILD_DIR_TREMOR" ] ; then
	mkdir $BUILD_DIR_TREMOR
fi
cd $BUILD_DIR_TREMOR
tar -xjf $SRCDIR/tremor-lowmem-ppc.tar.bz2
cp -r include/tremor $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp lib/libvorbisidec.a $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii
echo "Copied Tremor files to install dir $BUILD_DKPRO_INSTALLDIR"
echo "Now cleaning up.."
cd $BUILD_DIR
rm -rf $BUILD_DIR_TREMOR

#---------------------------------------------------------------------------------
# libPNG
#---------------------------------------------------------------------------------
if [ ! -d "$BUILD_DIR_LIBPNG" ] ; then
	mkdir $BUILD_DIR_LIBPNG
fi
cd $BUILD_DIR_LIBPNG
tar -xjf $SRCDIR/libpng-1.5.4-ppc.tar.bz2
cp bin/libpng-config $BUILD_DKPRO_INSTALLDIR/devkitPPC/bin/
cp bin/libpng15-config $BUILD_DKPRO_INSTALLDIR/devkitPPC/bin/
cp -r include/libpng15 $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp include/pnglibconf.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp include/png.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp include/pngconf.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp lib/libpng15.a $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii
cp lib/libpng.a $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii
echo "Copied libPNG files to install dir $BUILD_DKPRO_INSTALLDIR"
echo "Now cleaning up.."
cd $BUILD_DIR
rm -rf $BUILD_DIR_LIBPNG

#---------------------------------------------------------------------------------
# Expat
#---------------------------------------------------------------------------------
if [ ! -d "$BUILD_DIR_EXPAT" ] ; then
	mkdir $BUILD_DIR_EXPAT
fi
cd $BUILD_DIR_EXPAT
tar -xjf $SRCDIR/expat-2.0.1-ppc.tar.bz2
cp include/expat_external.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp include/expat.h $BUILD_DKPRO_INSTALLDIR/libogc/include/
cp lib/libexpat.a $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii
cp lib/libexpat.la $BUILD_DKPRO_INSTALLDIR/libogc/lib/wii
echo "Copied exPAT files to install dir $BUILD_DKPRO_INSTALLDIR"
echo "Now cleaning up.."
cd $BUILD_DIR
rm -rf $BUILD_DIR_EXPAT
