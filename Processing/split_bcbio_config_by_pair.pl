#!/usr/bin/perl -w

=head1 NAME

split_bcbio_config_by_pair.pl

=head1 AUTHOR

Alison Meynert (alison.meynert@igmm.ed.ac.uk)

=head1 DESCRIPTION

Splits a bcbio config file by pairs of samples

=cut

use strict;

# Perl
use IO::File;
use Getopt::Long;

my $usage = qq{USAGE:
$0 [--help]
  --input  Input bcbio multi-sample configuration file
  --output Output directory
  --prefix Prefix for output files
  --upload Upload dir
  --name   Name to use for fc_name
};

my $help = 0;
my $input_file;
my $output_dir;
my $upload_dir;
my $prefix;
my $name;

GetOptions(
    'help'     => \$help,
    'input=s'  => \$input_file,
    'output=s' => \$output_dir,
    'upload=s' => \$upload_dir,
    'prefix=s' => \$prefix,
    'name=s'   => \$name
) or die $usage;

if ($help || !$input_file || !$output_dir || !$prefix || !$name || !$upload_dir)
{
    print $usage;
    exit(0);
}

my $in_fh = new IO::File;
$in_fh->open($input_file, "r") or die "Could not open $input_file";

my %pairs;

my $output_lines = "";
my $pair_name = "";
while (my $line = <$in_fh>)
{
    next if ($line =~ /(details|fc_date|fc_name|upload|dir):/);

    if ($line =~ /algorithm/)
    {
	if (length($output_lines) > 0)
	{
	    if (!exists($pairs{$pair_name}))
	    {
		$pairs{$pair_name} = "details:\n" . $output_lines;
	    }
	    else
	    {
		$pairs{$pair_name} .= $output_lines;
	    }

	    $output_lines = "";
	    $pair_name = "";
	}
    }

    if ($line =~ /batch:\s+([^\s]+)/)
    {
	$pair_name = $1;
    }

    $output_lines .= $line;
}

if (length($output_lines) > 0)
{
    if (!exists($pairs{$pair_name}))
    {
	$pairs{$pair_name} = "details:\n" . $output_lines;
    }
    else
    {
	$pairs{$pair_name} .= $output_lines;
    }
}

foreach my $pair_name (keys %pairs)
{
    # print to file
    my $output_file = "$output_dir/$prefix.$pair_name.yaml";
    my $out_fh = new IO::File;
    $out_fh->open($output_file, "w") or die "Could not open $output_file\n$!";
    print $out_fh $pairs{$pair_name};
    print $out_fh "fc_date: $name\n";
    print $out_fh "upload:\n";
    print $out_fh "  dir: $upload_dir/$prefix.$pair_name\n";
}
