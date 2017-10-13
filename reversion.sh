#!/bin/bash

## + requires perl-reversion from Perl::Version (debian package libperl-version-perl)
## + example call:
##    ./reversion.sh -bump -dryrun

pmfiles=(./Gen.pm Gen/Parser.yp)

exec perl-reversion "$@" "${pmfiles[@]}"
