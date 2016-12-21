print 'put query. do not include s'; my $query = <STDIN>; print $query; print "\n\n";
############################################################################################


#my $query = q${query}$;

if ( $query =~ m/^q?[^\s\w]/ ) {
	use VeryKiwiFilter;
	my_filter( 's'.$query );
}
else{
	die # a dead filter will not appear as an Alfred option
}
