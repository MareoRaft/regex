use VeryKiwiFilter;

sub test_command{
  my ($command) = @_;
  print 'put entire query: '; print "$command\n";
  print command_to_output($command), "\n\n";
}

my @testcommands = ( # REMEMBER YOU MUST ESCAPE SLOSHES IN PERL STRINGS THEMSELVES
#TESTS:
#end bracket delim:
  's)\\\\cancel\\{\\d+\\})CANCELED)gx',  # valid
  's)\\\\cancel\\{\\d+\\})CANCELED))gi', # invalid
  'sq>\\cancel{4}>CANCELEDFOUR>g', # valid
  'sq$doo bee doo bee$replace$xg', # invalid (sq x combination)
#open bracket dlim:
  's[\\\\cancel\\{\\d+\\}][CANCELED]gx', # valid
  's(\\\\canc(el\\{\\d+\\})(CANCELED)gi', # invalid
  'sq<\\cancel{4}><CANCELEDFOUR>g', # valid
  'sq{doo bee doo bee}{replace}sg', # invalid (sq s combination)
#nested:
  's{\\\\cancel\\{\\d+\\}}{CANCELED}gxsim', # valid
  's{\\\\can}cel\\{\\d+\\}}{CANCELED}gxsim', # invalid
  's(  ( )  ()  (   )()   )(   )', # valid
  's(  ( )  (\\)  (   )()   )(   )', # invalid
  's<ab(c()d)ef\\\\\\\\<<>>gh<ij<<<>>>k>l><replace<<<>>> <> >o', # valid
  's<ab(c()d)ef\\\\\\<<>>gh<ij<<<>>>k>l><replace<<<>>> <> >o', # invalid
  'sq{\\\\cancel\\{\\d+\\}}{CANCELED}ipom', # valid
  'sq{\\\\can}cel\\{\\d+\\}}{CANCELED}', # invalid
  'sq(  ( )  ()  (   )()   )(   )', # valid
  'sq(  ( )  (\\)  (   )()   )(   )', # valid
  'sq<ab(c()d)ef\\\\\\\\<<>>gh<ij<<<>>>k>l><replace<<<>>> <> >o', # valid
  'sq<ab(c()d)ef\\\\\\<<>>gh<ij<<<>>>k>l><replace<<<>>> <> >o', # valid
  'sq<ab(c()d)ef\\\\\\<<>>gh<ij<<<>>>k>l><replace<<<>>> <> >e', # invalid (sq e combination)
  'sq<ab(c()d)ef\\\\\\<<>>gh<ij<<<>>>k>l><replace<<<>>> <> >r', # invalid (sq r combination)
#create a regex and save it.
#create a quoted regex and save it.  This one:
 #     sq#~!@$%^&*()_+QWERTYUIOP{}|:"NM<>?/.,#MEREPLACE~!@$%^&*()_+QWERTYUIOP{}|:"NM<>?/.,MEREPLCAEEE!:)#gi save as weird
# perform a saved regex on content!
 #     the above one.
);

foreach (@testcommands){ test_command($_) }

=test
use VeryKiwiCommand;

my $c = VeryKiwiCommand->new('s/');
print 'regex is '.$c->regex->regex."\n";
print 'suffix is '.$c->suffix."\n";
=cut
