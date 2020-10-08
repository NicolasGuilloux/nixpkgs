{ stdenv, lib, fetchurl, autoPatchelfHook, makeWrapper, unzip,

# Unpack libs
boost172, curl, libX11, libpng12, libxml2, libxslt, openssl, postgresql, qt5
, zlib }:

with lib;

stdenv.mkDerivation rec {
  pname = "skipper";
  version = "3.2.25.1701";
  src = fetchurl {
    url =
      "https://downloads.skipper18.com/${version}/Skipper-${version}-Linux-all-64bit.zip";
    sha256 = "130wfn20mj0nrp66grk7fj8xr6m4l1cp7741w40ixp8gdhih57zc";
  };

  nativeBuildInputs = [ unzip autoPatchelfHook qt5.wrapQtAppsHook makeWrapper ];

  buildInputs = [
    boost172
    curl
    libX11
    libxml2
    libxslt
    openssl
    postgresql
    qt5.qtbase
    qt5.qtscript
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = [ libpng12 ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/lib
    mv ./libs/libmysqlclient.so* $out/lib
    mv ./libs/libQtitan*.so* $out/lib
    rm -r ./libs ./bearer ./platforms

    mkdir -p $out/opt
    chmod +x ./Skipper
    mv ./* $out/opt

    makeWrapper $out/opt/Skipper $out/bin/skipper \
      --prefix LD_LIBRARY_PATH : ${makeLibraryPath runtimeDependencies}
  '';

  postFixup = ''
    wrapQtApp $out/opt/Skipper
  '';

  meta = with stdenv.lib; {
    description =
      "An ORM framework editor for Doctrine, Symfony, Laravel, etc.";
    homepage = "https://www.skipper18.com/";
    license = [ licenses.unfree ];
    maintainers = with maintainers; [ nover ];
    platforms = platforms.linux;
  };
}
