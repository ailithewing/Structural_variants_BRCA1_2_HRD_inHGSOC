#!/usr/bin/perl -w

use strict;

my %matches;
while (my $line = <>)
{
    next if ($line =~ /file/);

    chomp $line;
    my ($file1, $file2, $score) = split(/\t/, $line);

    $file1 =~ /(.+)(-ready-chr\.qsig\.vcf|-prealign-chr\.qsig\.vcf)/;
    my $id1 = $1;
    $file2 =~ /(.+)(-ready-chr\.qsig\.vcf|-prealign-chr\.qsig\.vcf)/;
    my $id2 = $1;

    push(@{ $matches{$id1}{$score} }, $id2);
    push(@{ $matches{$id2}{$score} }, $id1);
}

my %pairs;
foreach my $file (keys %matches)
{
    my @scores = sort { $a <=> $b }keys %{ $matches{$file }};
    my $min_score = $scores[0];

    my @matched_files = @{ $matches{$file}{$min_score} };
    if (scalar(@matched_files) > 1)
    {
	printf STDERR "More than one file with minimum score for $file: %s\n", join(",", @matched_files);
    }
    else
    {
	my $prefix1;
	my $prefix2;
	if ($file =~ /AOCS/ || $matched_files[0] =~ /AOCS/)
	{
	    $prefix1 = substr($file, 0, 8);
	    $prefix2 = substr($matched_files[0], 0, 8);
	}
	elsif ($file =~ /DO/ || $matched_files[0] =~ /DO/)
	{
	    $prefix1 = substr($file, 0, 5);
	    $prefix2 = substr($matched_files[0], 0, 5);
	}
	elsif ($file =~ /SHGSOC/)
	{
	    $prefix1 = substr($file, 0, 9);
	    $prefix2 = substr($matched_files[0], 0, 9);
	}
	elsif ($file =~ /D[AG]/ || $matched_files[0] =~ /D[AG]/)
	{
	    $prefix1 = substr($file, 0, 6);
	    $prefix2 = substr($matched_files[0], 0, 6);
	}

	my $flag = "match";
	if ($prefix1 ne $prefix2)
	{
	    $flag = "mismatch";
	}

	if ($file lt $matched_files[0])
	{
	    print "$file\t$matched_files[0]\t$min_score\t$flag\n";
	}
	else
	{
	    print "$matched_files[0]\t$file\t$min_score\t$flag\n";
	}
    }
}
