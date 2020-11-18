#!/bin/sh

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

if [ "$ARCH" = "i586" ]; then
  SLKCFLAGS="-O2 -march=i586 -mtune=i686 -fcommon"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686 -fcommon"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fcommon"
  LIBDIRSUFFIX="64"
else
  SLKCFLAGS="-O2 -fcommon"
  LIBDIRSUFFIX=""
fi

rm -rf cdesktopenv-code
echo Decompressing...
tar xJpf cde.tar.xz
cd cdesktopenv-code/cde || exit -1
echo Setting Permissions...
chown -R mau:users .
find -L . \
 \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
 -o -perm 511 \) -exec chmod 755 {} \; -o \
 \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
 -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# Check for a previous install
if [ -d /var/dt ]; then
  echo Deleting existing CDE installation...
  su -c "rm -fR /var/dt /usr/dt /etc/dt /usr/spool/calendar"
fi

echo linking X11 libraries
mkdir -p imports/x11/include
ln -s /usr/include/X11 imports/x11/include/X11
ln -s $(which cpp) /lib/cpp
ln -s /usr/bin/gawk /usr/bin/nawk 

echo Setting Flags...
sed -i "s|-g -pipe| $SLKCFLAGS -pipe|" config/cf/linux.cf

cat >> config/cf/site.def <<EOF
#define KornShell /bin/ksh
#define CppCmd cpp
#define YaccCmd byacc -y
#define RegisterRPC
#define HasTIRPCLib YES
#define HasZlib YES
#define DtLocalesToBuild
EOF

export LANG=C
export LC_ALL=C
##export IMAKECPP=cpp

echo Compiling...
sleep 3
CFLAGS="$SLKCFLAGS" \
CXXFLAGS="$SLKCFLAGS" \
make -j1 World 2>errors 1>good
