#!/usr/bin/env perl

use v5.34;
use utf8;

use IPC::Run3::Shell {show_cmd=>1}, qw/ :FATAL :run curl tar rm make emmake /;
use FindBin;
use File::Spec;

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

1;
