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

man1dir="none"
man3dir="none"

usenm='undef'

firstmakefile='GNUmakefile'
