# If you would like to customize this file, here is what you need to know:
# # New regexs are populated at the bottom as elsif statements, so do not add variables or functions at the -
# # - bottom that would disrupt the elsif chain.
# # This file is literally pasted into VeryKiwiFilter and 'eval'ed.
# # If you would like to add functions to this file, do so at the beginning.  If you want to put the functi -
# # - ons in a separate file to prevent clutter, include them with the 'require' statement, not the 'use' s -
# # - tatement.
# # Some regexs are included below as examples of chaining together regex statements / customizing.

# # $c is the 'command' you type into Alfred.
# # $q is the 'query'.  That is, it is the text you copied before invoking Alfred.

# this finds lone numbers and % symbols and wraps them in $ symbols
if( $c =~ /^mathy$/ ){ # <-- this is a plain old regex (two lines down), but I added a variable for organization
	my $num = qr/\d+(?:,\d{3})*(?:\.\d+)?/;
	$q =~ s|($num)(%?)| '$' . $1 . '\\%' x!! $2 . '$' |eg;
}

elsif( $c =~ /^no spaces$/ ){ # <-- this is a typical sequence of regexs (the 3 regexs below).  It is a very useful technique.
	#converting 5\cdot\text{ miles} to 5\cdot\text{miles} for better cancellations:
	$q =~ s/(\\cdot)\s*((?:\\(?:blue|green|pink|red|purple|gray)\{)?\s*(?:\\cancel\{)?\s*\\text\{)\s+/$1$2/g;
	#converting 5\text{ miles} to 5\:\text{miles} for better cancellations:
	$q =~ s/([^\s{])\s*((?:\\(?:blue|green|pink|red|purple|gray)\{)?\s*(?:\\cancel\{)?\s*\\text\{)\s+/$1\\:$2/g;
	#converting \text{5 miles} to 5\:\text{miles}
	$q =~ s/\\text\{(\d+)\s+/$1\\:\\text{/g;
}

# removes things wrapped in a \cancel{} tag
elsif( $c =~ /^cc|cancelcancel$/ ){ # ORDER MATTERS.  THIS GOES BEFORE cancelunits (the next elsif statement).
	$q =~ s|\\cancel(\{[^{}]*(?1)?[^{}]*\})||xg; # uses recursive regex bracket inception (?1)
}

# finds units or variables or numbers and wraps them in a \cancel{} tag
elsif( $c =~ /^(?:cancel|cancel\s*units?)\s*(blue)?\s+(\S+)/ ){ # <-- this is an 'or' chain (4 regexs below).  If one regex matches nothing, it goes on to the next one.
	my ( $blue, $unit, $regex ) = ( $1, quotemeta($2), $2 );
	$q =~  s|\\text\{$unit\}(?:\^\d+)?| '\\blue{' x!! $blue . "\\cancel{$&}" . '}' x!! $blue |eg # for text-wrapped quoted unit
		or
	$q =~            s|$unit(?:\^\d+)?| '\\blue{' x!! $blue . "\\cancel{$&}" . '}' x!! $blue |eg # for non text-wrapped quoted unit
		or
	$q =~ s|\\text\{$regex\}(?:\^\d+)?| '\\blue{' x!! $blue . "\\cancel{$&}" . '}' x!! $blue |eg # for text-wrapped regex unit
		or
	$q =~           s|$regex(?:\^\d+)?| '\\blue{' x!! $blue . "\\cancel{$&}" . '}' x!! $blue |eg # for non text-wrapped regex unit
}

#converting paragraphed equation steps into latex begin{align} steps
elsif( $c =~ /^combine$/ ){ # <-- this is another regex sequence (the 5 regexs below).
	$q =~ s/\s*\$\s*\$\s*/ \\\\\n\\\\\n/g; # $'s separate equations and are replaced with \\ newline \\
	$q =~ s/(?:^|\n)\s*\$\s*/\$\n\\begin{align}\n/g; # the very first dollar is replaced with $\begin{align} newline
	$q =~ s/\s*\$\s*($|\n)\s*(?!\s*\\begin)/\n\\end{align}\n\$\n/g; # last dollar replaced with \end{align}$ newline
	# if there is NO EQUALS or APPROX whatsoever in the first line, then we put the & at the beginning of first line (after quads)
	$q =~ s/  (?<=\$\n\\begin{align}\n)  ((?:\\q?quad)*)  (?=(?:(?!=|\\approx).)*\\\\)  /$1 &/x;
	$q =~ s/=|\\approx/$&&/g; # for all lines w/ = approx, we align to it
}

elsif( $c =~ /^nameofyourregex$/ ){ # <-- This is how a saved regex will be appended to the end of this file.
	$q =~ s/searchforthis/replacewiththisperlstring/gxi; # <-- your regex exactly as you entered it
}
