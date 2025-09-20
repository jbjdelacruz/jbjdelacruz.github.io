download_libs() {
# On debian CI we want to test against system libv8
if [ "$USER" = "salsaci" ]; then
  return;
fi

# Detect libcxx
if echo "$CXX" | grep -Fq "clang"; then
if printf "#include <string>\n#ifndef _LIBCPP_VERSION\n#error not libcxx\n#endif" | $CXX -E -xc++ - >/dev/null 2>&1; then
IS_LIBCXX="with libc++"
fi
fi

# Gets the R target architecture in case of qemu-containers, e.g
# https://hub.docker.com/r/i386/debian
# Which reports uname -m: x86_64 (only i386 seems to have this issue)
RARCH=$(${R_HOME}/bin/Rscript -e 'cat(R.Version()$arch)')
case $RARCH in
  x86_64 | arm64 | aarch64)
    echo "Target architecture: $RARCH $IS_LIBCXX"
    ;;
  *)
    echo "Unexpected architecture: $RARCH"
    return;
    ;;
esac

# RHDT compilers are using an older libc++
# https://github.com/jeroen/V8/issues/137
if test -f "/etc/redhat-release" && grep -Fq "release 7" "/etc/redhat-release"; then
IS_CENTOS7=1
fi

IS_MUSL=$(ldd --version 2>&1 | grep musl)
if [ $? -eq 0 ] && [ "$IS_MUSL" ]; then
  if [ "$RARCH" = "arm64" ] || [ "$RARCH" = "aarch64" ]; then
    return; #dont have this binary yet
  else
    URL="https://github.com/jeroen/build-v8-static/releases/download/11.9.169.7/v8-11.9.169.7-alpine.tar.gz"
  fi
elif [ "$RARCH" = "arm64" ] || [ "$RARCH" = "aarch64" ]; then
  URL="https://github.com/jeroen/build-v8-static/releases/download/11.9.169.7/v8-11.9.169.7-debian-11-arm.tar.gz"
else
  IS_GCC4=$($CXX --version | grep -P '^g++.*[^\d.]4(\.\d){2}')
  if [ $? -eq 0 ] && [ "$IS_GCC4" ]; then
    URL="https://github.com/jeroen/build-v8-static/releases/download/11.9.169.7/v8-6.8.275.32-gcc-4.8.tar.gz"
    MORE_V8_CFLAGS="-DNODEJS_LTS_API=16"
  elif [ "$IS_CENTOS7" ]; then
    URL="https://github.com/jeroen/build-v8-static/releases/download/11.9.169.7/v8-6.8.275.32-gcc-4.8.tar.gz"
    MORE_V8_CFLAGS="-DNODEJS_LTS_API=16"
  elif [ "$IS_LIBCXX" ]; then
    URL="https://github.com/jeroen/build-v8-static/releases/download/11.9.169.7/v8-11.9.169.7-debian-12-libcxx.tar.gz"
  else
    URL="https://github.com/jeroen/build-v8-static/releases/download/11.9.169.7/v8-11.9.169.7-centos-8.tar.gz"
  fi
fi
if [ ! -f ".deps/lib/libv8_monolith.a" ]; then
  echo "Getting bundle: $(basename $URL)"
  if ${R_HOME}/bin/R -s -e "curl::curl_download('$URL','libv8.tar.gz')"; then
    tar xf libv8.tar.gz
    rm -f libv8.tar.gz
    mv v8 .deps
  fi
fi
if [ -f ".deps/lib/libv8_monolith.a" ]; then
  PKG_CFLAGS="-I${PWD}/.deps/include $MORE_V8_CFLAGS"
  PKG_LIBS="-L${PWD}/.deps/lib -lv8_monolith"
fi
}

download_libs
