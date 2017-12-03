#! /bin/bash
#
# Purpose:
#    Fetch and build CERNLIB on macOS
#
# Args:
#    $1  - location of top level directory [default: "/opt/cern/cernlib" ]
#
export CC=/usr/local/bin/gcc-7
export CXX=/usr/local/bin/g++-7
export FC=/usr/local/bin/gfortran-7

CERN=$1
if [ -z "$CERN" ] ; then
   CERN=/opt/cern/cernlib
fi
CERN_LEVEL=2006
export CERN CERN_LEVEL

#
# cernlib build scripts desire some env variables
#
export CERN_ROOT=${CERN}/${CERN_LEVEL}
export CVSCOSRC=${CERN_ROOT}/src
export PATH=${CERN_ROOT}/bin:${PATH}
# make *really* sure that they're exported ... or kablooie
export CERN_ROOT CVSCOSRC PATH CERN CERN_LEVEL

if [ ! -d ${CERN} ] ; then echo "Missing required folder: ${CERN}" ; exit ; fi
if [ ! -d ${CERN_ROOT} ] ; then mkdir -p ${CERN_ROOT} ; fi
cd ${CERN_ROOT} || exit

#
# clean out previous tries ...
#
if [ -d downloads ] ; then rm -r downloads ; fi

cd ${CERN_ROOT} || exit
dirlist='bin include lib src aux'
for subdir in $dirlist ; do
    if [ -d "$subdir" ] ; then
        chmod -R +w "$subdir"
        rm -r "$subdir"
    fi
done

#
# create (if necessary) some of the subdirs we'll be using
#
cd ${CERN_ROOT} || exit
for subdir in bin include lib src download aux ; do
  if [ ! -d $subdir ] ; then mkdir -p $subdir ; fi
done

#
# fetch what we need
#
function fetchit()
{  # usage:  fetchit pathURL
    url=$1
    srcfile=$(basename "$url")
    srcpath=$(dirname "$url")
    #echo "fetchit $url -> $srcfile"
    if [ "$srcfile" == "" ] ; then
        echo 'fetchit() missing file name ' ; return ; fi
    if [ "$srcpath" == "" ] ; then
        echo 'fetchit() missing pathURL ' ; return ; fi
    if [ -f "$srcfile" ] ; then
        echo "Already have \"$srcfile\""
    else
        echo "Fetching $srcfile"
        curl -O "$srcpath/$srcfile"
        status=$?
        if [ $status != 0 ] || [ ! -f "$srcfile" ] ; then
            echo "Failed to get $srcfile from $srcpath, status=$status"
            exit
        fi
        echo " "
    fi
}

cd ${CERN_ROOT}/download || exit

CERN_SRCTAR="http://cernlib.web.cern.ch/cernlib/download/2006_source/tar"
for pkg in 2006_src include mathlib32_src minuit32_src gcalor nypatchy_boot
do
  fetchit $CERN_SRCTAR/$pkg.tar.gz
done

#
# unpack the CERNLIB sources
#
echo "unpack source .tar.gz"
cd ${CERN} || exit
for pkg in 2006_src include mathlib32_src minuit32_src gcalor nypatchy_boot
do
  tar zxf ${CERN_ROOT}/download/$pkg.tar.gz
done
echo "untar done"



ln -s ${CERN_LEVEL} new
ln -s ${CERN_LEVEL} pro
mkdir -p ${CERN_LEVEL}/work
cd ${CERN_LEVEL}/src || exit


patch -p1 -s < ${HOME}/Codice/cernlib/002-fix-missing-mclibs.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/114-install-scripts-properly.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/210-improve-cfortran-header-files.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/306-patch-assert.h-for-makedepend.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/307-use-canonical-cfortran.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/315-fixes-for-MacOSX.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/700-remove-kernlib-from-packlib-Imakefile.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/702-patch-Imakefiles-for-packlib-mathlib.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/703-patch-code_motif-packlib-Imakefiles.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/705-patch-paw_motif-paw-Imakefiles.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/802-create-shared-libraries.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-102-dont-optimize-some-code.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-103-ignore-overly-long-macro-in-gen.h.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-104-fix-undefined-insertchar-warning.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-105-fix-obsolete-xmfontlistcreate-warning.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-106-fix-paw++-menus-in-lesstif.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-107-define-strdup-macro-safely.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-110-ignore-included-lapack-rule.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-111-fix-kuesvr-install-location.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-112-remove-nonexistent-prototypes-from-gen.h.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-115-rsrtnt64-goto-outer-block.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-116-fix-fconc64-spaghetti-code.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-118-rename-mathlib-common-blocks.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-119-fix-compiler-warnings.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-120-fix-gets-usage-in-kuipc.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-121-fix-mathlib-test-case-c209m.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-122-fix-cdf-file-syntax-errors.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-123-extern-memmove-only-if-not-macro.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-124-integrate-patchy-bootstrap.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-125-fix-PLINAME-creation.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-126-fix-patchy-compile-flags.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-127-yexpand-makes-tmpfiles-in-pwd.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-201-update-kuip-helper-apps.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-202-fix-includes-in-minuit-example.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-205-max-path-length-to-256.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-208-fix-redundant-packlib-dependencies.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-209-ignore-unneeded-headers-in-kmutil.c.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-211-support-amd64-and-itanium.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-211-support-digital-alpha.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-212-print-test-results.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-213-fix-test-suite-build.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-214-fix-kernnum-funcs-on-64-bit.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-215-work-around-g77-bug-on-ia64.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-216-use-cernlib-gamma-not-intrinsic.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-217-abend-on-mathlib-test-failure.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-300-skip-duplicate-lenocc.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-303-shadow-passwords-supported.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-304-update-Imake-config-files.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-308-use-canonical-cfortran-location.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-311-skip-duplicate-qnext.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-313-comis-preserves-filename-case.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-318-additional-gcc-3.4-fixes.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-319-work-around-imake-segfaults.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-320-support-ifort.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-321-support-gfortran.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-600-use-host.def-config-file.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-701-patch-hbook-comis-Imakefiles.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-704-patch-code_kuip-higzcc-Imakefiles.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-800-implement-shared-library-rules-in-Imake.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-801-non-optimized-rule-uses-fPIC-g.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-803-link-binaries-dynamically.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-805-expunge-missing-mathlib-kernlib-symbols.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-806-bump-mathlib-and-dependents-sonames.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/cernlib-807-static-link-some-tests-on-64-bit.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-001-fix-missing-fluka.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-003-geant-dummy-functions.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-109-fix-broken-xsneut95.dat-link.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-117-fix-optimizer-bug-in-gphot.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-203-compile-geant-with-ertrak.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-213-fix-test-suite-build.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-806-bump-mathlib-and-dependents-sonames.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/geant321-807-static-link-some-tests-on-64-bit.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-100-fix-isajet-manual-corruption.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-101-undefine-PPC.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-102-dont-optimize-some-code.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-204-compile-isajet-with-isasrt.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-206-herwig-uses-DBLE-not-REAL.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-213-fix-test-suite-build.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-220-compile-isajet-with-isarun.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-221-use-double-in-hepevt.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-305-use-POWERPC-not-PPC-as-test.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-309-define-dummy-herwig-routines.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-310-define-dummy-fowl-routines.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-312-skip-duplicate-gamma.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-321-support-gfortran.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-806-bump-mathlib-and-dependents-sonames.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/mclibs-807-static-link-some-tests-on-64-bit.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-102-dont-optimize-some-code.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-105-fix-obsolete-xmfontlistcreate-warning.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-108-quote-protect-comis-script.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-119-fix-compiler-warnings.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-120-fix-mlp-cdf-file.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-121-call-gfortran-in-cscrexec.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-200-comis-allow-special-chars-in-path.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-207-compile-temp-libs-with-fPIC.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-211-support-amd64-and-itanium.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-305-use-POWERPC-not-PPC-as-test.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-308-use-canonical-cfortran-location.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-313-comis-preserves-filename-case.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-320-support-ifort-and-gfortran.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-701-patch-hbook-comis-Imakefiles.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-706-use-external-xbae-and-xaw.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-801-non-optimized-rule-uses-fPIC-g.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-803-link-binaries-dynamically.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-804-workaround-for-comis-mdpool-struct-location.dpatch
patch -p1 -s < ${HOME}/Codice/cernlib/paw-806-bump-mathlib-and-dependents-sonames.dpatch

cd ${CERN_ROOT} || exit
mkdir -p lib
ln -s /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libLAPACK.dylib lib/liblapack3.a
ln -s /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib lib/libblas.a
cd work || exit
export CVSCOSRC=${CERN_ROOT}/src
mkdir -p ../bin
cp $CVSCOSRC/scripts/cernlib ../bin/
$CVSCOSRC/config/imake_boot
export PATH=$PATH:${CERN_ROOT}/bin
mkdir -p ../logs
make tree HAVE_MOTIF='YES' >& ../logs/tree.log &
pushd ../src/packlib/kuip/programs/kuipc || exit
make
make install.bin
popd || exit
make HAVE_MOTIF='YES' >& ../logs/make.log &
cd ${CERN_ROOT}/work/packlib || exit
make install.bin HAVE_MOTIF=YES PACKAGE_LIB='/cern/pro/lib/libpacklib.a' EXTRA_LOAD_FLAGS='-L/opt/osxws/lib -lgfortran' >& ../../logs/packlib.bin.log &
cd ../pawlib || exit
make install.bin HAVE_MOTIF=YES PACKAGE_LIB='/cern/pro/lib/libpawlib.a' EXTRA_INCLUDES='-I/cern/2006/src/pawlib/comis' >& ../../logs/pawlib.bin.log &
cd ../graflib || exit
make install.bin HAVE_MOTIF=YES PACKAGE_LIB='/cern/pro/lib/libgraflib.a' >& ../../logs/graflib.bin.log &
cd ../scripts || exit
make install.bin HAVE_MOTIF='YES' >& ../../logs/scripts.bin.log &
cd .. && make install.include CERN_INCLUDEDIR=/cern/new/include >& ../logs/install.include.log &

## TESTS
# cd packlib
# make test PACKAGE_LIB='/cern/pro/lib/libpacklib.a' >& ../../logs/packlib.test.log &
# cd ../mathlib
# make test PACKAGE_LIB='/cern/pro/lib/libmathlib.a' >& ../../logs/mathlib.test.log &
# cd ../graflib/higz/examples
# make higzex PACKAGE_LIB='/cern/pro/lib/libgraflib.a'
# ./higzex
# cd ../../../../src/pawlib/paw/demo
# paw all.kumac
# cd ../../../../work/mclibs
# FC='gfortran -O0' make test >& ../../logs/mclibs.test.log &
# tail -f ../../logs/mclibs.test.log
# cd ../phtools
# make test >& ../../logs/phtools.test.log &
# tail -f ../../logs/phtools.test.log
# cd ../geant321
# make test EXTRA_LOAD_FLAGS='-undefined dynamic_lookup' >& ../../logs/geant321.test.log &
# tail -f ../../logs/geant321.test.log
