#!/usr/local/bin/perl
##---------------------------------------------------------------------------##
##  File:
##      @(#) queryRepeatDatabase.pl
##  Author:
##      Robert M. Hubley   rhubley@systemsbiology.org
##  Description:
##      A utility script to assist in querying the monolithic
##      RM repeat sequence database.
##
#******************************************************************************
#* Copyright (C) Institute for Systems Biology 2003-2004 Developed by
#* Arian Smit and Robert Hubley.
#*
#* This work is licensed under the Open Source License v2.1.  To view a copy
#* of this license, visit http://www.opensource.org/licenses/osl-2.1.php or
#* see the license.txt file contained in this distribution.
#*
#******************************************************************************
#
# ChangeLog
#
#     $Log: queryRepeatDatabase.pl,v $
#     Revision 1.20  2004/09/09 22:43:48  rhubley
#     Cleanup before a distribution
#
#
###############################################################################
#
# To Do:
#

=head1 NAME

queryRepeatDatabase.pl - Query the RepeatMasker repeat database.

=head1 SYNOPSIS

  queryRepeatDatabase.pl [-version] [-species <species> ]
                                    [-stage <stage num> ] 
                                    [-class <class> ]
                                    [-id <id> ]
                                    [-stat]

=head1 DESCRIPTION

  A utility script to query the RepeatMasker repeat database.

The options are:

=over 4

=item -version

Displays the version of the program

=back

=over 4

=item -species "species name"

The full name ( case insensitive ) of the species you would like
to search for in the database.

=item -stage <stage num>

The number of the RepeatMasker stage for which you would like
repeats.  In the past these stages were individual libraries
with the following general names:

  Stage          Library
  -----          -------
  10             is.lib
  15             rodspec.lib
  20             humspec.lib
  25             simple.lib
  30             at.lib
  40             shortcutlib
  45             cutlib
  50             shortlib
  55             longlib
  60             mirs.lib
  65             mir.lib
  70             retrovirus.lib

=item -class <class>

Retrieve all elements of a particular class.  For example:

  DNA
  SINE
  LINE
  LTR
  Other
  RC
  Satellite
  tRNA
  Simple_repeat
  Unknown
  snRNA

=item -id <id>

Retrieve only a single id from the database.

=item -stat

Returns statistics on the sequences

=head1 SEE ALSO

ReapeatMasker

=head1 COPYRIGHT

Copyright 2004 Robert Hubley, Institute for Systems Biology

=head1 AUTHOR

Robert Hubley <rhubley@systemsbiology.org>

=cut

#
# Module Dependence
#
use strict;
use FindBin;
use lib $FindBin::Bin;
use lib "$FindBin::Bin/../";
use Getopt::Long;
use Data::Dumper;
use FastaDB;
use Taxonomy;

#
# Version
#
my $Version = 0.1;

#
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
#
my @getopt_args = (
                    '-version',     # print out the version and exit
                    '-species=s',
                    '-stage=i',
                    '-class=s',
                    '-id=s',
                    '-stat'
);

my %options = ();
Getopt::Long::config( "noignorecase", "bundling_override" );
unless ( GetOptions( \%options, @getopt_args ) ) {
  usage();
}

sub usage {
  print "$0 - $Version\n";
  exec "pod2text $0";
  exit( 1 );
}

if ( $options{'version'} ) {
  print "$Version\n";
  exit;
}

usage()
    if (
         !(
               exists $options{'species'}
            || exists $options{'class'}
            || exists $options{'stage'}
            || exists $options{'id'}
         )
    );

my $RMLib       = "$FindBin::Bin/../Libraries/RepeatMasker.lib";
my $taxDB       = "$FindBin::Bin/../taxonomy.dat";
my $specPattern = "";
$specPattern = $options{'species'} if ( defined $options{'species'} );
my $stagePattern = "";
$stagePattern = $options{'stage'} if ( defined $options{'stage'} );
my $idPattern = "";
$idPattern = $options{'id'} if ( defined $options{'id'} );
my $classPattern = "";
$classPattern = $options{'class'} if ( defined $options{'class'} );

my $db = FastaDB->new( fileName => $RMLib, openMode => SeqDBI::ReadOnly );
my $tax = Taxonomy->new( taxonomyDataFile => $taxDB );

my @ids         = $db->getIDs();
my @descs       = $db->getDescriptors();
my $totalLength = 0;

for ( my $i = 0 ; $i <= $#ids ; $i++ ) {
  my $match = 0;
  if ( $specPattern ne "" ) {
    while ( $descs[ $i ] =~ /@([\w\.]+)/ig ) {
      my $name = $1;
      $name =~ s/_/ /g;
      if (    $tax->isA( $name, $specPattern ) > 0
           || $tax->isA( $specPattern, $name ) > 0 )
      {
        $match = 1;
        last;
      }
    }
  }

  if (
       ( $specPattern eq "" || $match > 0 )
       && (    $stagePattern eq ""
            || ( $stagePattern == 0 && $descs[ $i ] =~ /\[S:\]/ )
            || $descs[ $i ] =~ /\[S:(\d+,)*$stagePattern(,\d+)*\]/ )
       && ( $idPattern eq "" || $ids[ $i ] =~ /$idPattern/i )
       && (    $classPattern eq ""
            || $ids[ $i ] =~ /\#$classPattern/i )
      )
  {
    my $seq = $db->getSequence( $ids[ $i ] );

    if ( defined $options{'stat'} ) {
      print ">" . $ids[ $i ] . "  Length = " . length( $seq ) . " bp\n";
      $totalLength += length( $seq );
    }
    else {
      print ">" . $ids[ $i ];
      if ( $descs[ $i ] ne "" ) {
        print " " . $descs[ $i ];
      }
      print "\n";
      $seq =~ s/(\S{50})/$1\n/g;
      $seq .= "\n"
          unless ( $seq =~ /.*\n+$/s );
      print $seq;
    }
  }
}
if ( defined $options{'stat'} ) {
  print "\nTotal Sequence Length = " . $totalLength . " bp\n";
}

1;
