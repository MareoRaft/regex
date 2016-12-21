package VeryKiwiTranslator;

use strict; use warnings;
use VeryKiwiHelpers;
use VeryKiwiMorpher; our @ISA = 'VeryKiwiMorpher';

############################### GLOBALS FOR ALL TRANSLATORS ##############################
our $y = qr/tr|y/;

####################################### TRANSLATOR #######################################
sub new{
	my $tr = VeryKiwiMorpher::new( @_ );
		unless( $tr->prefix =~ m/^$y$/ ){ die 'Non-translator prefix.' }
	return $tr
}

sub opts{
	return qr/(?:c?d?s?)*/
}

1
