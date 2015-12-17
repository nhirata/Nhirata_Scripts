#!/bin/sh

# I made this script previous to taskcluster for myself and modified it along the way
# note: If you use task cluster you would need to modify the yml to make the full image and full fota.

# tmp dir for packaging all of update image files
mkdir ~/Desktop/tmp
mkdir ~/Desktop/tmp/v18D_nightly_v5
cp ~/Desktop/v18D_nightly_v4/* ~/Desktop/tmp/v18D_nightly_v5/

# sync repo
./repo sync --force-sync

# add languages (script)
# copy the script from https://github.com/nhirata/gaia_locales
# make sure to run the clone.  This assumes you have things setup already
./update_l10n.sh

# set buildid
export BUILDID=`date +%Y%m%d%H%M%S`

# build full flash build
MOZ_BUILD_DATE=$BUILDID LOCALE_BASEDIR=locales/ LOCALES_FILE=locales/languages_all.json B2G_UPDATE_CHANNEL=nightly ENABLE_ADB_ROOT=1 B2G_UPDATER=1 MOZILLA_OFFICIAL=1 PRODUCTION=1 VARIANT=userdebug ./build.sh 

# move build files
cp out/target/product/flame/*.img ~/Desktop/tmp/v18D_nightly_v5/

# build FOTA update.zip and mar files
MOZ_BUILD_DATE=$BUILDID LOCALE_BASEDIR=locales/ LOCALES_FILE=locales/languages_all.json B2G_UPDATE_CHANNEL=nightly ENABLE_ADB_ROOT=1 B2G_UPDATER=1 MOZILLA_OFFICIAL=1 PRODUCTION=1 VARIANT=userdebug B2G_FOTA_FULLIMG_PARTS="/boot:boot.img /system:system.img /recovery:recovery.img" ./build.sh gecko-update-fota-fullimg

# move build files
cp out/target/product/flame/fota-flame-update-fullimg.mar ~/Desktop/tmp
cp out/target/product/flame/fota/fullimg/update.zip ~/Desktop/tmp

# build symbol files to push to socorro
./build.sh buildsymbols
cp objdir-gecko/dist/b2g-*.en-US.android-arm.crashreporter-symbols* ~/Desktop/tmp

# to upload the symbols 
# https://developer.mozilla.org/en-US/docs/Uploading_symbols_to_Mozillas_symbol_server

zip -r flame_${BUILDID}.zip ~/Desktop/tmp
mv flame_${BUILDID}.zip ~/Desktop/
# download build : scp <user>@<ip>:~/Desktop/flame_${BUILDID}.zip .

# verify contents manually

# rm -r ~/Desktop/tmp/*
