#!/bin/bash

# build_master.sh <dir> <release> <branch> <justbuild>

# <dir> is where the binaries are
# <release> is a SF subdir of /home/frs/project/b/bi/biblatex-biber/biblatex-biber/
# <branch> is a git branch to checkout on the build farm servers
# <justbuild> is a boolean which says to just build and stop without uploading

# Example: build_master.sh ~/Desktop/b development dev 1

BASE="/Users/philkime/data/code/biblatex-biber"
DOCDIR=$BASE/doc
DRIVERDIR=$BASE/lib/Biber/Input/
BINDIR=$BASE/dist
XSLDIR=$BASE/data
DIR=${1:-"/Users/philkime/Desktop/b"}
RELEASE=${2:-"development"}
BRANCH=${3:-"dev"}
JUSTBUILD=${4:-"0"}
export COPYFILE_DISABLE=true # no resource forks in archives - non-macs don't like them

echo "** Checking out branch '$BRANCH' on farm servers **"
echo "** If this is not correct, Ctrl-C now **"
sleep 5

# Make binary dir if it doesn't exist
if [ ! -e $DIR ]; then
  mkdir $DIR
fi

# Create the binaries from the build farm if they don't exist

# Build farm OSX 64-bit intel
# ntpdate is because Vbox doesn't timesync OSX and ntp never works because the
# time difference is too great between boots
if [ ! -e $DIR/biber-darwin_x86_64.tar.gz ]; then
  ssh root@wood "VBoxHeadless --startvm bbf-osx10.6 </dev/null >/dev/null 2>&1 &"
  sleep 4
  ssh bbf-osx10.6 "sudo ntpdate ch.pool.ntp.org;cd biblatex-biber;git checkout $BRANCH;git pull;perl ./Build.PL;sudo ./Build install;cd dist/darwin_x86_64;\\rm -f biber-darwin_x86_64;./build.sh"
  scp bbf-osx10.6:biblatex-biber/dist/darwin_x86_64/biber-darwin_x86_64 $DIR/
  ssh root@wood "VBoxManage controlvm bbf-osx10.6 savestate"
  cd $DIR
  mv biber-darwin_x86_64 biber
  chmod +x biber
  tar cf biber-darwin_x86_64.tar biber
  gzip biber-darwin_x86_64.tar
  \rm biber
  cd $BASE
fi

# Build farm OSX 32-bit intel (universal)
# ntpdate is because Vbox doesn't timesync OSX and ntp never works because the
# time difference is too great between boots
if [ ! -e $DIR/biber-darwin_x86_i386.tar.gz ]; then
  ssh root@wood "VBoxHeadless --startvm bbf-osx10.5 </dev/null >/dev/null 2>&1 &"
  sleep 4
  ssh bbf-osx10.5 "sudo ntpdate ch.pool.ntp.org;cd biblatex-biber;git checkout $BRANCH;git pull;perl ./Build.PL;sudo ./Build install;cd dist/darwin_x86_i386;\\rm -f biber-darwin_x86_i386;./build.sh"
  scp bbf-osx10.5:biblatex-biber/dist/darwin_x86_i386/biber-darwin_x86_i386 $DIR/
  ssh root@wood "VBoxManage controlvm bbf-osx10.5 savestate"
  cd $DIR
  mv biber-darwin_x86_i386 biber
  chmod +x biber
  tar cf biber-darwin_x86_i386.tar biber
  gzip biber-darwin_x86_i386.tar
  \rm biber
  cd $BASE
fi

# Build farm WinXP
# We run "Build realclean" at the end as we are using the same tree for
# win and cygwin builds
if [ ! -e $DIR/biber-MSWIN.zip ]; then
  ssh root@wood "VBoxHeadless --startvm bbf-wxp32 </dev/null >/dev/null 2>&1 &"
  sleep 4
  ssh bbf-wxp32 "cd biblatex-biber;git checkout $BRANCH;git pull;perl ./Build.PL;./Build install;cd dist/MSWin32;\\rm -f biber-MSWIN.exe;./build.bat;cd ~/biblatex-biber;./Build realclean"
  scp bbf-wxp32:biblatex-biber/dist/MSWin32/biber-MSWIN.exe $DIR/
  ssh root@wood "VBoxManage controlvm bbf-wxp32 savestate"
  cd $DIR
  mv biber-MSWIN.exe biber.exe
  chmod +x biber.exe
  /usr/bin/zip biber-MSWIN.zip biber.exe
  \rm biber.exe
  cd $BASE
fi

# Build farm cygwin
# We run "Build realclean" at the end as we are using the same tree for
# win and cygwin builds
if [ ! -e $DIR/biber-cygwin32.tar.gz ]; then
  ssh root@wood "VBoxHeadless --startvm bbf-wxp32 </dev/null >/dev/null 2>&1 &"
  sleep 4
  # We have to move aside the windows libbtparse.dll otherwise it's picked up by cygwin
  ssh bbf-wxp32 ". bin/set-biber-cyg-build-env.sh;mv /cygdrive/c/WINDOWS/libbtparse.dll /cygdrive/c/WINDOWS/libbtparse.dll.DIS;cd biblatex-biber;git checkout $BRANCH;git pull;perl ./Build.PL;./Build install;cd dist/cygwin32;\\rm -f biber-cygwin32;./build.sh;mv /cygdrive/c/WINDOWS/libbtparse.dll.DIS /cygdrive/c/WINDOWS/libbtparse.dll;cd ~/biblatex-biber;./Build realclean"
  scp bbf-wxp32:biblatex-biber/dist/cygwin32/biber-cygwin32.exe $DIR/
  ssh root@wood "VBoxManage controlvm bbf-wxp32 savestate"
  cd $DIR
  mv biber-cygwin32.exe biber.exe
  chmod +x biber.exe
  tar cf biber-cygwin32.tar biber.exe
  gzip biber-cygwin32.tar
  \rm biber.exe
  cd $BASE
fi

# Build farm Linux 32
if [ ! -e $DIR/biber-linux_x86_32.tar.gz ]; then
  ssh root@wood "VBoxHeadless --startvm bbf-jj32 </dev/null >/dev/null 2>&1 &"
  sleep 4
  ssh bbf-jj32 "cd biblatex-biber;git checkout $BRANCH;git pull;/usr/local/perl/bin/perl ./Build.PL;sudo ./Build install;cd dist/linux_x86_32;\\rm -f biber-linux_x86_32;./build.sh"
  scp bbf-jj32:biblatex-biber/dist/linux_x86_32/biber-linux_x86_32 $DIR/
  ssh root@wood "VBoxManage controlvm bbf-jj32 savestate"
  cd $DIR
  mv biber-linux_x86_32 biber
  chmod +x biber
  tar cf biber-linux_x86_32.tar biber
  gzip biber-linux_x86_32.tar
  \rm biber
  cd $BASE
fi

# Build farm Linux 64
if [ ! -e $DIR/biber-linux_x86_64.tar.gz ]; then
  ssh root@wood "VBoxHeadless --startvm bbf-jj64 </dev/null >/dev/null 2>&1 &"
  sleep 4
  ssh bbf-jj64 "cd biblatex-biber;git checkout $BRANCH;git pull;/usr/local/perl/bin/perl ./Build.PL;sudo ./Build install;cd dist/linux_x86_64;\\rm -f biber-linux_x86_64;./build.sh"
  scp bbf-jj64:biblatex-biber/dist/linux_x86_64/biber-linux_x86_64 $DIR/
  ssh root@wood "VBoxManage controlvm bbf-jj64 savestate"
  cd $DIR
  mv biber-linux_x86_64 biber
  chmod +x biber
  tar cf biber-linux_x86_64.tar biber
  gzip biber-linux_x86_64.tar
  \rm biber
  cd $BASE
fi

# Stop here if JUSTBUILD is set
if [ "$JUSTBUILD" = "1" ]; then
  echo "JUSTBUILD is set, will not upload anything";
  exit 0;
fi

cd $DIR
# OSX 64-bit
if [ -e $DIR/biber-darwin_x86_64.tar.gz ]; then
  scp biber-darwin_x86_64.tar.gz philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/binaries/OSX_Intel/biber-darwin_x86_64.tar.gz
fi

# OSX 32-bit universal
if [ -e $DIR/biber-darwin_x86_i386.tar.gz ]; then
  scp biber-darwin_x86_i386.tar.gz philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/binaries/OSX_Intel/biber-darwin_x86_i386.tar.gz
fi

# Windows
if [ -e $DIR/biber-MSWIN.zip ]; then
  scp biber-MSWIN.zip philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/binaries/Windows/biber-MSWIN.zip
fi

# Cygwin
if [ -e $DIR/biber-cygwin32.tar.gz ]; then
  scp biber-cygwin32.tar.gz philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/binaries/Cygwin/biber-cygwin32.tar.gz
fi

# Linux 32-bit
if [ -e $DIR/biber-linux_x86_32.tar.gz ]; then
  scp biber-linux_x86_32.tar.gz philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/binaries/Linux/biber-linux_x86_32.tar.gz
fi

# Linux 64-bit
if [ -e $DIR/biber-linux_x86_64.tar.gz ]; then
  scp biber-linux_x86_64.tar.gz philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/binaries/Linux/biber-linux_x86_64.tar.gz
fi

# Doc
scp $DOCDIR/biber.pdf philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/documentation/biber.pdf
# Changes file
scp $BASE/Changes philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/Changes
# Driver control file docs
find $DRIVERDIR -name \*.dcf | xargs -I{} cp {} $DIR
for dcf in $DIR/*.dcf
do
$BINDIR/make-pretty-dcfs.pl $dcf $XSLDIR/dcf.xsl
scp $dcf.html philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/documentation/drivers/
\rm -f $dcf $dcf.html
done

if [ $RELEASE != "development" ]; then
# Perl dist tree
scp $BASE/biblatex-biber-*.tar.gz philkime,biblatex-biber@frs.sourceforge.net:/home/frs/project/b/bi/biblatex-biber/biblatex-biber/$RELEASE/biblatex-biber.tar.gz
rm $BASE/biblatex-biber-*.tar.gz
fi

cd $BASE