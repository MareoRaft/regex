package VeryKiwiFilter;

use strict; use warnings;
use Exporter; our @ISA = 'Exporter'; our @EXPORT = qw(command_to_output  my_filter);
use VeryKiwiHelpers;
use VeryKiwiAlfred;
use VeryKiwiCommand;

our $q; # q for query
our $c; # c for command
our $RegexSequencesPath = $ENV{HOME}.'/Library/Application Support/Alfred 2/Workflow Data/com.verykiwi.regex/RegexSequences.pl';

sub initialize{
	$ENV{LANG} = 'en_US.UTF-8'; # needed for all inputting and outputting
	$q = `pbpaste`; # q is for query # here we may need to do something to get it in UTF-8!  See deanishe comment on alfredforum
		if( !defined $q ){ return 'The query is empty or undefined.' }
	$c = VeryKiwiCommand->new(shift);
}

sub transform_query{

	if( $c->has_morpher and $c->morpher->is_valid ){
		my $code = '$q =~ '.$c->morpher->export; eval $code;
	}
	else{
		my $c = $c->raw; # the local $c is the raw command text. # this file uses '$c' as the input
		if( my $regexsequencescode = read_file($RegexSequencesPath) ){
			$regexsequencescode .= "\n" . 'else{ $q = "Regex invalid or name not found." }' . "\n";
			eval $regexsequencescode;
		}
		else{ $q = 'Could not open your RegexSequences.pl file.' }
	}

	return $q
}

sub command_to_output{
	initialize(shift);
	if( $c->has_morpher and $c->morpher->is_valid and $c->has_save_as_name ){
		my $name = $c->save_as_name; my $morpherstring = $c->morpher->export;
		append_to_file( $RegexSequencesPath, "\nelsif( \$c =~ /^$name\$/ ){\n\t\$q =~ $morpherstring;\n}\n" );
		return '' # can we NOT do the paste thing??
	}
	return transform_query();
}

sub show_title{
	unless( $c->in_the_process_of_saving_a_valid_morpher ){ # don't show title when saving valid morpher
		my $prefix = $c->morpher->prefix; # this includes the 'q' if there is one.
		my ($start,$middle,$end) = $c->morpher->start_middle_end;
		my ($search,$replace) = $c->morpher->mind_the_delim('search,',' and replace!'); # deletes delim if quoted, escapes it if regular
		my $options = ($c->morpher->is_regex)? 'g': 's';
		my $title = "$prefix${start}$search${middle}$replace${end}$options";
		my $subtitle =	($c->morpher->is_translator)?
							'Perform a Perl tr substitution on the content you just copied.':
						($c->morpher->is_quoted)?
							'Perform a quoted substitution. No escaping or interpolation whatsover.':
							'Perform a Perl regex substitution on the content you just copied.';
		my $icon = ($c->morpher->is_valid)? 'icon_check.png': undef;
		my $arg = ($c->morpher->is_valid)? $c->morpher->raw: undef; # Refuses to execute if the syntax is incorrect.
		my $autocomplete = ($c->morpher->is_valid)? undef: substr( $c->morpher->raw, length($c->morpher->prefix) ); # see above

		entry({ title => $title, subtitle => $subtitle, arg => $arg, autocomplete => $autocomplete, icon => $icon });
	}
}

sub show_save_as{
	if( $c->morpher->is_valid ){
		if( $c->has_save_as_name ){
			my $name = $c->save_as_name;
			if( $name eq '' ){
				entry({
					title => "save as ''",
					subtitle => 'Word characters, digits, and spaces only.  Your choice is CASE-SENSITIVE.',
					autocomplete => substr( $c->morpher->raw, length($c->morpher->prefix) ).' save as '
				});
			}
			else{
				entry({
					title => "save as '$name'",
					subtitle => 'Word characters, digits, and spaces only.  Your choice is CASE-SENSITIVE.',
					arg => $c->raw,
					icon => 'icon_check.png'
				})
			}
		}
		elsif( $c->suffix ne '' ){
			entry({
				title => 'save as...',
				subtitle => 'Save this pattern for future use!',
				autocomplete => substr( $c->morpher->raw, length($c->morpher->prefix) ).' save as '
			});
		}
	}
}

sub display_matches{
	my @matches;

	#get the matches somehow

	#if( $c =~ /^ mq $start (.*?) (?:$end($qopts))? $/ ){
	#	my ( $this, $options ) = ( quotemeta($1), $+ );
	#	my $code = 'if( $q =~ m/$this/'.$options.' ){ @matches = ($&,$1,$2,$3,$4,$5,$6,$7,$8,$9) }'; eval $code;
	#}

	$matches[0] //= 'No matches.';
	for my $num (0..$#matches){
		entry({ title => $matches[$num], subtitle => 'Entire Match $&' x !$num . "Match Group \$$num" x !!$num }) if defined $matches[$num];
	}
}

sub my_filter{
	initialize(shift);

	print q(<?xml version="1.0" encoding="utf-8"?><items>); #specifying the encoding is probably not necessary, because utf-8 is the default...
		show_title();
		show_save_as();
		#display_matches(); # this should be optional / configurable
	print q(</items>);
}

1
