#!/usr/bin/env perl

use v5.34;
use utf8;

use IPC::Run3::Shell {show_cmd=>1}, qw/ :FATAL :run curl tar rm make emconfigure emmake /;
use FindBin;
use File::Spec;
use File::Slurp qw/write_file/;

my $PERL_VERSION = "5.40.0";
my $jobs = `nproc || sysctl -n hw.logicalcpu_max` + 0;

# clean up the working directory
chdir $FindBin::Bin;
rm "-rf", ".working";
mkdir ".working";

# download the perl source code
chdir File::Spec->catdir($FindBin::Bin, ".working");
curl("-sSL", "-O", "https://github.com/Perl/perl5/archive/refs/tags/v$PERL_VERSION.tar.gz");

mkdir "hostperl";
tar("xf", "v$PERL_VERSION.tar.gz", "-C", "hostperl", "--strip-components=1");

mkdir "emperl";
tar("xf", "v$PERL_VERSION.tar.gz", "-C", "emperl", "--strip-components=1");

# build the host perl
chdir File::Spec->catdir($FindBin::Bin, ".working", "hostperl");
run("sh", "Configure", "-des");
make("-j", $jobs, "miniperl", "generate_uudmap");

# build the emperl
chdir File::Spec->catdir($FindBin::Bin, ".working", "emperl");
write_file(
  File::Spec->catfile("hints", "emscripten.sh"),
  +{ binmode => ':utf8' },
  <<'EOF'
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
EOF
);
emconfigure(
  "./Configure",
  "-des",
  "-Dhintfile=emscripten",
  "-Dhostperl=" . File::Spec->catfile($FindBin::Bin, ".working", "hostperl", "miniperl"),
  "-Dhostgenerate=" . File::Spec->catfile($FindBin::Bin, ".working", "hostperl", "generate_uudmap"),
);
emmake("make", "-j", $jobs, "perl");

1;
