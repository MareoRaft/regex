package VeryKiwiHelpers;

use strict; use warnings;
use Exporter; our @ISA = 'Exporter'; our @EXPORT = qw(trim_scalar   trim   trim_left_scalar   trim_left   read_file   append_to_file);
use File::Basename; use File::Path qw/make_path/; use File::Copy; # for append_to_file

sub trim_scalar{ my $i = shift; $i =~ s/^\s+|\s+$//g; $i }
sub trim{
	if( wantarray ){
		return map { trim_scalar($_) } @_
	}
	else{
		return trim_scalar( join("\n",@_) )
	}
}

sub trim_left_scalar{ my $i = shift; $i =~ s/^\s+//g; $i }
sub trim_left{
	if( wantarray ){
		return map { trim_left_scalar($_) } @_
	}
	else{
		return trim_left_scalar( join("\n",@_) )
	}
}

sub read_file{
	my ($filepath) = @_;
	open( my $FH, '<', $filepath ) or return 0;
		local $/ = undef;
		my $data = <$FH>;
	close( $FH );
	return $data
}

sub append_to_file{
	my ($filepath,$content) = @_;
		make_path(dirname($filepath)); # creates the directory for the file if it doesn't exist
		unless(-e $filepath){ copy( 'VeryKiwiRegexSequencesTemplate.pl', $filepath ) or die 'Failed to copy template.' } # create file if it doesn't exist
	open( my $FH, '>>', $filepath ) or die "Could not open for appending at path '$filepath'.";
		print $FH $content;
	close( $FH );
	return 1
}

1
