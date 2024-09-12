osname="emscripten"
archname="wasm"
osvers="$(perl -e 'print qx(emcc --version)=~/(\d+\.\d+\.\d+)/')"

myhostname='localhost'
mydomain='.local'
cf_email='shogo82148@gmail.com'
perladmin='root@localhost'

cc="emcc"
ld="emcc"

nm="$(which llvm-nm)"  # note from Glossary: 'After Configure runs, the value is reset to a plain "nm" and is not useful.'
ar="$(which llvm-ar)"  # note from Glossary: 'After Configure runs, the value is reset to a plain "ar" and is not useful.'
ranlib="$(which llvm-ranlib)"


# dyanmic libraries don't work in emscripten.
# so we build them as static libraries.
static_ext="attributes B Cwd Data/Dumper Devel/Peek Digest/MD5 Digest/SHA Encode Fcntl File/Glob Hash/Util I18N/Langinfo IO List/Util mro Opcode PerlIO/encoding PerlIO/via re SDBM_File Socket Time/HiRes Time/Piece Unicode/Normalize"
dynamic_ext=''

man1dir="none"
man3dir="none"

usenm='undef'

firstmakefile='GNUmakefile'
