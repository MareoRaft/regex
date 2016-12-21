package VeryKiwiAlfred;

use strict; use warnings;
use Exporter; our @ISA = 'Exporter'; our @EXPORT = qw(escape_for_XML  entry);

sub escape_for_XML{
	my @strings = @_; # takes in REFERENCES
	foreach my $string (@strings){ if( defined $$string ){
		$$string =~ s/&/&#38;/g; # & is the ESCAPER of xml characters, and therefore must be escaped itself.
		$$string =~ s/</&#60;/g; # this is the end delimiter for <title> escape it!--> </title>
		$$string =~ s/"/&#34;/g; # this is the end delimiter for arg=" escape it!--> "
	}}
	# no return necessary, items edited by reference.
}
#my $y = 'hi, there <tag>!  &nbspme.  quote me", quote me!!:"'; my $x = $y; escape_for_XML(\$y,\$x); print $x;

sub entry{
	my %input = %{$_[0]};
		my $valid = (defined $input{arg})? 'yes': 'no'; # if something is given an argument, it is valid.  otherwise, it is not.
		my $arg = $input{arg} // '';
		my $autocomplete = $input{autocomplete} // '';
		my $title = $input{title} // '';
		my $subtitle = $input{subtitle} // '';
		my $icon = $input{icon} // '';
	escape_for_XML( \$arg, \$autocomplete, \$title, \$subtitle ); # we need to see if escaped things seem to output ok in arg!
	print qq(
	  <item valid="$valid" arg="$arg" autocomplete="$autocomplete">
		<title>$title</title>
		<subtitle>$subtitle</subtitle>
		<icon>$icon</icon>
	  </item>
	);
}

1
