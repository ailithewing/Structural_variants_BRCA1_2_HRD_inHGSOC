#!/usr/bin/perl -w

use strict;

#<file coverage="21363" id="12" name="/gpfs/igmmfs01/eddie/HGS-OvarianCancerA-SGP-WGS/qc/qsignature/sample/./TP012P02-ready-chr.qsig.vcf"/>
#<comparison calcs="85036" file1="91" file2="92" overlap="21259" score="0.036391691628315306"/>

print "file1\tfile2\tscore\n";

my %comps;
my %file;
while (my $line = <>)
{
    chomp $line;
    if ($line =~ /^\<file cov/)
    {
	my @tokens = split(" ", $line);
	my %hash;
	foreach my $token (@tokens)
	{
	    if ($token =~ /=/)
	    {
		my ($key, $val) = split(/=/, $token);
		$val =~ /\"(.+)\"/;
		$hash{$key} = $1;
	    }
	}
	my @path = split(/\//, $hash{'name'});
	$file{$hash{'id'}} = $path[scalar(@path)-1];
    }
    elsif ($line =~ /^\<comparison calc/)
    {
	my @tokens = split(" ", $line);
	my %hash;
	foreach my $token (@tokens)
	{
	    if ($token =~ /=/)
	    {
		my ($key, $val) = split(/=/, $token);
		$val =~ /\"(.+)\"/;
		$hash{$key} = $1;
	    }
	}
	my $file1 = $file{$hash{'file1'}};
	my $file2 = $file{$hash{'file2'}};
	my $score = $hash{'score'};

	printf "$file1\t$file2\t$score\n";
    }
}
