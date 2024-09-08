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
curl("-sSL", "-o", "perl.tar.gz", "https://github.com/shogo82148/emperl5/archive/refs/heads/emperl5-v5.40.0.tar.gz");

mkdir "hostperl";
tar("xf", "perl.tar.gz", "-C", "hostperl", "--strip-components=1");

mkdir "emperl";
tar("xf", "perl.tar.gz", "-C", "emperl", "--strip-components=1");

# build the host perl
chdir File::Spec->catdir($FindBin::Bin, ".working", "hostperl");
run("sh", "Configure", "-des");
make("-j", $jobs, "all");

# build the emperl
chdir File::Spec->catdir($FindBin::Bin, ".working", "emperl");
emconfigure(
  "./Configure",
  "-des",
  "-Dhintfile=emscripten",
  "-Dhostperl=" . File::Spec->catfile($FindBin::Bin, ".working", "hostperl", "miniperl"),
  "-Dhostgenerate=" . File::Spec->catfile($FindBin::Bin, ".working", "hostperl", "generate_uudmap"),
);

emmake("make", "-j", $jobs, "all");

{
  local $ENV{PERL5LIB} = File::Spec->catfile($FindBin::Bin, ".working", "hostperl", "lib");
  run(
    File::Spec->catfile($FindBin::Bin, ".working", "hostperl", "miniperl"),
    'installperl',
    '-p',
    '--destdir=' . File::Spec->catfile($FindBin::Bin, ".working", "output"),
  );
}

1;
