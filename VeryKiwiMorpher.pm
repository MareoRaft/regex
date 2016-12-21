package VeryKiwiMorpher; # consider changing name to Morphers !

use strict; use warnings;
use VeryKiwiHelpers;

############################### GLOBALS FOR ALL MORPHERS ###############################
our $prefix = qr/sq?|mq?|tr|y/;
our %opentoclose = ( '('=>')', '{'=>'}', '['=>']', '<'=>'>' );

####################################### MORPHER ########################################
sub new{
	my $packagename = shift;
	my ($raw) = @_; # The input should be a translator string (tr/search/replace/opts)
	$raw = trim($raw);
	my $delim; if( $raw =~ m/^${prefix}([^\s\w])/ ){ $delim = $1 }else{ die 'No delim.' }
	bless { raw=>$raw, delim=>$delim, delim_subregex=>undef } => $packagename
	# anything stored with memoization must be listed here as undef
}

sub is_regex{
	my $morpher = shift;
	return ref($morpher) eq 'VeryKiwiRegex'
}

sub is_translator{
	my $morpher = shift;
	return ref($morpher) eq 'VeryKiwiTranslator'
}

sub raw{
	my $morpher = shift;
	return $$morpher{raw}
}

sub prefix{
	my $morpher = shift;
	if( $morpher->raw =~ m/^${prefix}/ ){ return $& }else{ die 'The morpher has no valid prefix.' }
}

sub qless_prefix{
	my $morpher = shift;
	#return $morpher->prefix =~ s/q$//r; # this, although awesome, will not work on older versions of perl (such as Snow Leopards 5.10.0)
	my $prefix = $morpher->prefix;
	$prefix =~ s/q$//;
	return $prefix;
}

sub delim{
	my $morpher = shift;
	my ($Q) = @_; # Q for quotemeta
	return (defined $Q)? quotemeta($$morpher{delim}): $$morpher{delim};
}

sub escape_the_delim{ # takes any strings and escapes all occurances of $delim
	my $morpher = shift;
	my @strings = @_;
		my $delim = $morpher->delim('Q');
		foreach my $string (@strings){ $string =~ s/$delim/\\$delim/g }
	return @strings
}
*mind_the_delim = \&escape_the_delim;

sub delim_is_paired{
	my $morpher = shift;
	return exists $opentoclose{$morpher->delim}
}

sub open{
	my $morpher = shift;
	my ($Q) = @_;
	return $morpher->delim($Q)
}

sub close{
	my $morpher = shift;
	my ($Q) = @_;
	my $close = $opentoclose{$morpher->open};
	return (defined $Q)? quotemeta($close): $close;
}

sub start_middle_end{
	my $morpher = shift;
	my ($Q) = @_; # Q for quotemeta
	return ($morpher->delim_is_paired)?
		( $morpher->open($Q), $morpher->close($Q).$morpher->open($Q), $morpher->close($Q) ):
		( $morpher->delim($Q) ) x 3;
}

sub end{
	my $morpher = shift;
	my ($Q) = @_;
	return ($morpher->delim_is_paired)? $morpher->close($Q): $morpher->delim($Q);
}

sub is_quoted{
	return 0 # things are not quoted by default in a morpher.  regex will override this with its own is_quoted function
}

sub pair_subregex{
	my $morpher = shift;
	my ($recursenum) = @_;

	my ($open,$close) = ( $morpher->open('Q'), $morpher->close('Q') );
	my $neither   =   ($morpher->is_quoted)?   qr/(?>(?:(?!$open|$close).)*)/:   qr/(?>(?:\\.|(?!\\|$open|$close).)*)/;

	return qr/($neither (?>(?: $open(?$recursenum)$close )?) $neither )*/x;
}

sub delim_subregex{ # behavior is undefined for delims like \,  , and strings of length greater than 1
	my $morpher = shift;
	my ($recursenum) = @_;
	if( !defined $$morpher{delim_subregex} ){
		if( $morpher->delim_is_paired ){
			$$morpher{delim_subregex} = $morpher->pair_subregex($recursenum)
		}
		else{
			my $delim = $morpher->delim('Q');
			$$morpher{delim_subregex}  =  ($morpher->is_quoted)?  qr/(?>(?:(?!$delim).)*)/:  qr/(?>(?:\\.|(?!\\|$delim).)*)/;
			# even though backtracking is disabled, we need the second \\ to avoid a lone \ at the end of the string (above)
		}
	}
	return $$morpher{delim_subregex}
}

sub opts{
	return qr/(?:g?m?o?p?i?s?x?e?c?d?s?)*/ # this will be overriden for the specific regex and tr morphers
}

sub validity_subregex{
	my $morpher = shift;

	my ($start,$middle,$end) = $morpher->start_middle_end('Q');
	my $delim_subregex = $morpher->delim_subregex(1); # the recurse is the 1ST capture group in the following regex.
	my $opts = $morpher->opts;

	return qr/$prefix $start (?'search'$delim_subregex) $middle (?'replace'$delim_subregex) $end(?'options'$opts)/x;
}

sub is_valid{
	my $morpher = shift;

	my $validity_subregex = $morpher->validity_subregex;
	if( $morpher->raw =~ /^$validity_subregex$/ ){
		# populate search, replace, options info for future use:
		( $$morpher{search}, $$morpher{replace}, $$morpher{options} ) = ( $+{search}, $+{replace}, $+{options} );
		return 1
	}
	return 0
}

sub search_replace_options{
	my $morpher = shift;
		my $search  = (shift)? quotemeta($$morpher{search}):  $$morpher{search};
		my $replace = (shift)? quotemeta($$morpher{replace}): $$morpher{replace};
		my $options = (shift)? quotemeta($$morpher{options}): $$morpher{options};
	return ( $search, $replace, $options )
}

sub export{ # assumes the regex is valid
	my $morpher = shift;
	if( !$morpher->is_quoted ){ return $morpher->raw }
	my $prefix = $morpher->qless_prefix;
	my ($start,$middle,$end) = $morpher->start_middle_end;
	my ($search,$replace,$options) = $morpher->search_replace_options('Q','Q', 0 );
	return "$prefix$start$search$middle$replace$end$options"
}

1
