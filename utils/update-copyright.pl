#!/usr/bin/perl -i
#$Id$
#Update Copyright notice
#
# change $new  before applying.
my $old = "1995 -- 2022, T. V. Raman";
my $new = "1995 -- 2024, T. V. Raman";

while (<>) {
    s/$old/$new/o;
    print;
}
