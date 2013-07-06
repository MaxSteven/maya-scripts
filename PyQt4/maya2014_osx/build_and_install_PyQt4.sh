#!/usr/bin/env bash
 
MAYAQTBUILD="`dirname \"$0\"`" # Relative
export MAYAQTBUILD="`( cd \"$MAYAQTBUILD\" && pwd )`" # Absolutized and normalized
cd $MAYAQTBUILD
 
export MAYA_LOCATION=/Applications/Autodesk/maya2014
export QTDIR=$MAYA_LOCATION/Maya.app/Contents
export QMAKESPEC=$QTDIR/mkspecs/macx-g++
export INCDIR_QT=$MAYA_LOCATION/devkit/include/Qt
export LIBDIR_QT=$QTDIR/MacOS
 
if [ ! -f $QMAKESPEC/qmake.conf ];
then
  echo "You need to install qt-4.8.2-64-mkspecs.tar.gz in $QTDIR/mkspecs !"
  exit
fi
if [ ! -f $INCDIR_QT/QtCore/qdir.h ];
then
  echo "You need to uncompress $MAYA_LOCATION/devkit/include/qt-4.8.2-include.tar.gz in $INCDIR_QT !"
  exit
fi
# qt.conf - /Applications/Autodesk/maya2014/Maya.app/Contents/Resources
if [ ! -f $QTDIR/bin/qt.conf ];
then
  echo "You need to copy $QTDIR/Resources/qt.conf in $QTDIR/bin !"
  exit
fi
 
test=`grep "Data=../.." $QTDIR/bin/qt.conf`
if [ ! -z "$test" ];
then
  echo "You need to edit $QTDIR/bin/qt.conf to use 'Data=..'"
  exit
fi
test=`grep "Headers=../../include" $QTDIR/bin/qt.conf`
if [ ! -z "$test" ];
then
  echo "You need to edit $QTDIR/bin/qt.conf to use 'Headers=../../../devkit/include/Qt'"
  exit
fi
test=`grep "Libraries=../lib" $QTDIR/bin/qt.conf`
if [ ! -z "$test" ];
then
  echo "You need to edit $QTDIR/bin/qt.conf to use 'Libraries =../MacOS'"
  exit
fi
test=`grep "Plugins = qt-plugins" $QTDIR/bin/qt.conf`
if [ ! -z "$test" ];
then
  echo "You need to edit $QTDIR/bin/qt.conf to use 'Plugins=../qt-plugins'"
  exit
fi
test=`grep "Translations = qt-translations" $QTDIR/bin/qt.conf`
if [ ! -z "$test" ];
then
  echo "You need to edit $QTDIR/bin/qt.conf to use 'Translations=../qt-translations'"
  exit
fi
 
for mod in Core Declarative Designer DesignerComponents Gui Help Multimedia Network OpenGL Script ScriptTools Sql Svg WebKit Xml XmlPatterns
do
  if [ ! -f $QTDIR/MacOS/libQt${mod}.dylib ];
  then
    echo "You need to copy a fake Qt$mod dylib - cp $QTDIR/MacOS/Qt$mod $QTDIR/MacOS/libQt${mod}.dylib !"
    #cp $QTDIR/MacOS/Qt$mod $QTDIR/MacOS/libQt${mod}.dylib
    exit
  fi
done
if [ ! -f $QTDIR/MacOS/libphonon.dylib ];
then
  echo "You need to copy a fake phonon dylib - cp $QTDIR/MacOS/phonon $QTDIR/MacOS/libphonon.dylib !"
  #cp $QTDIR/MacOS/phonon $QTDIR/MacOS/libphonon.dylib
  exit
fi
 
export DYLD_LIBRARY_PATH=$QTDIR/MacOS
export DYLD_FRAMEWORK_PATH=$QTDIR/Frameworks
 
export SIPDIR=$MAYAQTBUILD/sip-4.14.5
export PYQTDIR=$MAYAQTBUILD/PyQt-mac-gpl-4.10
 
cd $PYQTDIR
export PATH=$QTDIR/bin:$PATH
$QTDIR/bin/mayapy ./configure.py LIBDIR_QT=$LIBDIR_QT INCDIR_QT=$INCDIR_QT MOC=$QTDIR/bin/moc -w --no-designer-plugin -g
make -j 8
sudo make install