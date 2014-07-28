#!/usr/bin/perl -w

$input = $ARGV[0];

open(INPUT_FILE, $input) || die("error!");

@entry1 = <INPUT_FILE>;
chomp(@entry1);

$count = $ARGV[1];
if($count == 2)
{
	@entry2 = @entry1;
	for($i = 0; $i < @entry1; $i++)
	{
		for($j = 0; $j < @entry2; $j++)
		{
			print "$entry1[$i]---$entry2[$j]\n";
		}
	}
}
elsif($count == 3)
{
	@entry2 = @entry1;
	@entry3 = @entry1;
	for($i = 0; $i < @entry1; $i++)
	{
		for($j = 0; $j < @entry2; $j++)
		{
			for($k = 0; $k < @entry3; $k++)
			{
				print "$entry1[$i]---$entry2[$j]---$entry3[$k]\n";
			}
		}
	}
}

close(INPUT_FILE);
