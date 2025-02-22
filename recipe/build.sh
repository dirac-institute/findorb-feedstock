#!/bin/bash

set -e
# Makefiles in find_orb and its dependencies use an environment variable called CPP
# which is reserved in the conda build environment as the C preprocessor. Here we
# overwrite the CPP environment variable and point it to the compiler instead.
export CPP=$CXX

# helpful while developing from local sources that may be partially built
for s in lunar jpl_eph sat_code find_orb; do
	(cd sources/$s && make clean)
done

# build all
( cd sources/lunar    && make                          && make install )
( cd sources/jpl_eph  && make libjpl.a                 && make install )
( cd sources/lunar    && make integrat                 && make install ) # must be a separate step as it depends on jpl_eph
( cd sources/sat_code && make sat_id                   && make install )
( cd sources/find_orb && make CURSES_LIB="-lncursesw -ltinfo"  && make install )

# clean up the libraries and headers we won't distribute
rm -f $PREFIX/lib/{libjpl,liblunar,libsatell}.a
rm -f $PREFIX/include/{afuncs,brentmin,cgi_func,comets,date,get_bin,jpleph,lunar,mpc_func,norad,showelem,vislimit,watdefs}.h
