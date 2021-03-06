#! /bin/bash

_HOME_="$(pwd)"
export _HOME_

_CTC_SRC_DIR_="/root/work/c-toxcore"
export _CTC_SRC_DIR_

export _SRC_=$_HOME_/src/
export _INST_=$_HOME_/inst/


export CF2=" -O3 -g"
export CF3=" "
export VV1=" " # VERBOSE=1 V=1 "


mkdir -p $_SRC_
mkdir -p $_INST_

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig

cd /root/work/
git clone https://github.com/zoff99/c-toxcore "$_CTC_SRC_DIR_"/

cd "$_CTC_SRC_DIR_"/
pwd
ls -al

git checkout zoff99/zoxcore_local_fork

./autogen.sh
make clean
export CFLAGS_=" $CF2 -D_GNU_SOURCE -I$_INST_/include/ -O3 -g -fstack-protector-all "
export CFLAGS="$CFLAGS_"
# export CFLAGS=" $CFLAGS -Werror=div-by-zero -Werror=format=2 -Werror=implicit-function-declaration "
export LDFLAGS="-L$_INST_/lib"

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared
make -j$(nproc) || exit 1
make install

export CFLAGS=" $CFLAGS_ -fPIC "
export CXXFLAGS=" $CFLAGS_ -fPIC "
export LDFLAGS=" $LDFLAGS_ -fPIC "
# timeout -k 242 240 make V=1 -j20 check || exit 0 # tests fail too often on CI -> don't error out on test failures



# -------------- sqlite ----------------------
cd /root/work/

if [ 1 == 1 ]; then
    # sqlite amalgamation
    wget 'https://www.sqlite.org/2019/sqlite-amalgamation-3290000.zip' -O sqlite_amal.zip
    echo 'a0eba79e5d1627946aead47e100a8a6f9f6fafff  sqlite_amal.zip' > sqlite_amal.zip.sha1
    sha1sum -c sqlite_amal.zip.sha1
    shasum_ok=$?

    if [ $shasum_ok -ne 0 ]; then
        echo "sqlite-amalgamation source checksum error"
        exit 1
    else
        echo "sqlite-amalgamation source checksum OK"
    fi

    unzip -o sqlite_amal.zip
    cp sqlite-amalgamation-*/sqlite3.h $_INST_/include/
    cp sqlite-amalgamation-*/sqlite3.c /root/work/src/
fi
# -------------- sqlite ----------------------


# -------------- now compile toxproxy ----------------------

cd /root/work/
pwd
ls -al

cd src/
pwd
ls -al

echo "--------------"
ls -al $_INST_/lib/libtoxcore.a
echo "--------------"

set -x

export CFLAGS=" -Wall -Wextra -Wno-unused-parameter -flto -fPIC -std=gnu99 -I$_INST_/include/ -L$_INST_/lib -O3 -g -fstack-protector-all "
gcc $CFLAGS \
ToxProxy.c \
sqlite3.c \
$_INST_/lib/libtoxcore.a \
$_INST_/lib/libtoxav.a \
$_INST_/lib/libtoxencryptsave.a \
$_INST_/lib/libopus.a \
$_INST_/lib/libvpx.a \
$_INST_/lib/libx264.a \
$_INST_/lib/libavcodec.a \
$_INST_/lib/libavutil.a \
$_INST_/lib/libsodium.a \
-lsqlite3 \
-lm \
-ldl \
-lpthread \
-o ToxProxy

# $_INST_/lib/sqlite3.a \

ls -hal ToxProxy
file ToxProxy
ldd ToxProxy

mkdir -p ~/work/artefacts/
cp -av ToxProxy ~/work/artefacts/

# -------------- now compile toxproxy ----------------------
