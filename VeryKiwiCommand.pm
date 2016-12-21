package VeryKiwiCommand;

use strict; use warnings;
use VeryKiwiHelpers;
use VeryKiwiMorpher; use VeryKiwiRegex; use VeryKiwiTranslator;

######################################## COMMAND #########################################
sub new{
	my $packagename = shift;
		my ( $raw, $morpher, $suffix ) = ( trim_left($_[0]), undef, undef );
		if( $raw =~ /^${VeryKiwiMorpher::prefix}[^\s\w]/ ){
			my $tempmorpher = VeryKiwiMorpher->new($&); # to get the delim in there and...
			my $end = $tempmorpher->end('Q'); # ...use this end function.
			my $rawmorpher; if( $raw =~ m/^(.+$end\w*)(.*)$/ ){ ($rawmorpher,$suffix)=($1,$2) }else{ ($rawmorpher,$suffix) = ($raw,'') }

			if( $tempmorpher->prefix =~ m/^$VeryKiwiTranslator::y$/ ){ $morpher = VeryKiwiTranslator->new($rawmorpher) }
			elsif( $tempmorpher->prefix =~ m/^$VeryKiwiRegex::r$/ ){ $morpher = VeryKiwiRegex->new($rawmorpher) }
			else{ die 'The morpher is neither a regex nor a translator.' }
		}
	bless { raw=>$raw, morpher=>$morpher, suffix=>$suffix } => $packagename
}

sub raw{
	my $c = shift;
	return $$c{raw}
}

sub morpher{
	my $c = shift;
	return $$c{morpher}
}

sub suffix{
	my $c = shift;
	return $$c{suffix}
}

sub has_morpher{
	my $c = shift;
	return (defined $c->morpher)
}

sub has_save_as{
	my $c = shift;
	return $c->suffix =~ /^\s+save\s*as\s*/
}

sub has_save_as_name{ # '' name is okay.
	my $c = shift;
	return $c->suffix =~ /^\s+save\s*as\s+(?:[\w\d ]*)\s*$/
}

sub save_as_name{
	my $c = shift;
	unless( $c->has_save_as_name ){ die 'Cannot use this function unless we have a save_as name.' }
	if( $c->suffix =~ /^\s+save\s*as\s+([\w\d ]*)/ ){ return trim($1) }
	die 'This code should never run.'
}

sub has_save_as_strict_nonempty_prefix{
	my $c = shift;
	return $c->suffix =~ /^\s+s(?:a(?:v(?:e\s*(?:a)?)?)?)?\s*$/
}

sub in_the_process_of_saving_a_valid_morpher{
	my $c = shift;
	return ( $c->morpher->is_valid and ( $c->has_save_as_strict_nonempty_prefix or $c->has_save_as ) )
}

1
