#!/usr/bin/perl -w

=head1 NAME

split_bcbio_config_by_sample.pl

=head1 AUTHOR

Alison Meynert (alison.meynert@igmm.ed.ac.uk)

=head1 DESCRIPTION

Splits a bcbio config file by sample.

=cut

use strict;

# Perl
use IO::File;
use Getopt::Long;

my $usage = qq{USAGE:
$0 [--help]
  --input   Input bcbio multi-sample configuration file
  --output  Output directory
  --upload  Upload dir
  --type    alignment or variant
  --fc_date Date to use for fc_date, yyyymmdd
  --fc_name Name to use for fc_name
};

my $help = 0;
my $input_file;
my $output_dir;
my $upload_dir;
my $type;
my $fc_date;
my $fc_name;

GetOptions(
    'help'      => \$help,
    'input=s'   => \$input_file,
    'output=s'  => \$output_dir,
    'upload=s'  => \$upload_dir,
    'type=s'    => \$type,
    'fc_date=s' => \$fc_date,
    'fc_name=s' => \$fc_name,
) or die $usage;

if ($help || !$input_file || !$output_dir || !$fc_date || !$fc_name || !$upload_dir || !$type)
{
    print $usage;
    exit(0);
}

my $in_fh = new IO::File;
$in_fh->open($input_file, "r") or die "Could not open $input_file";

my $output_lines = "";
my $sample = "";
while (my $line = <$in_fh>)
{
    next if ($line =~ /(details|fc_date|fc_name|upload\:|dir)/);

    if ($line =~ /algorithm/)
    {
	if (length($output_lines) > 0)
	{
	    # print to file
	    my $output_file = sprintf("$output_dir/%s_%s.yaml", $sample, $type);
	    my $out_fh = new IO::File;
	    $out_fh->open($output_file, "w") or die "Could not open $output_file\n$!";
	    print $out_fh $output_lines;
	    print $out_fh "fc_date: \'$fc_date\'\n";
	    print $out_fh "fc_name: \'$fc_name\'\n";
	    print $out_fh "upload:\n";
	    print $out_fh "  dir: $upload_dir/$sample\n";
	    $output_lines = "";
	    $sample = "";
	}
	$output_lines = "details:\n";
    }

    if ($line =~ /description:\s+([^\s]+)/)
    {
	$sample = $1;
    }

    $output_lines .= $line;
}

if (length($output_lines) > 0)
{
    # print to file
    my $output_file = sprintf("$output_dir/%s_%s.yaml", $sample, $type);
    my $out_fh = new IO::File;
    $out_fh->open($output_file, "w") or die "Could not open $output_file\n$!";
    print $out_fh $output_lines;
    print $out_fh "fc_date: \'$fc_date\'\n";
    print $out_fh "fc_name: \'$fc_name\'\n";
    print $out_fh "upload:\n";
    print $out_fh "  dir: $upload_dir/$sample\n";
    $output_lines = "";
    $sample = "";
}
