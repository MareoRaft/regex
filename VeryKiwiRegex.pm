package VeryKiwiRegex;

use strict; use warnings;
use VeryKiwiHelpers;
use VeryKiwiMorpher; our @ISA = 'VeryKiwiMorpher';

################################ GLOBALS FOR ALL REGEXS ################################
our $r = qr/sq?|mq?/;

######################################## REGEX #########################################
sub new{
	my $regex = VeryKiwiMorpher::new( @_ );
		unless( $regex->prefix =~ m/^$r$/ ){ die 'Non-regex prefix.' }
	return $regex
}

sub is_quoted{
	my $regex = shift;
	return $regex->prefix =~ m/q$/
}

sub opts{
	my $regex = shift;
	return ($regex->is_quoted)? qr/(?:g?m?o?p?i?)*/: qr/(?:g?m?o?p?i?s?x?e?)*/;
}

sub mind_the_delim{ # takes any strings and escapes all occurances of $delim
	my $regex = shift;
	my @strings = @_;
	if( $regex->is_quoted ){
		my $delim = $regex->delim('Q');
		foreach my $string (@strings){ $string =~ s/$delim//g } # delete the delim
	}
	else{
		@strings = $regex->escape_the_delim(@strings);
	}
	return @strings
}

1
