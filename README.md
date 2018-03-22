# Regex
Run and save regexes with Alfred!

You can download regex [directly](http://learnnation.org/regex.alfredworkflow).

Regex is listed on [packal](http://www.packal.org/workflow/regex).

There is an [Alfred Forum page](http://www.alfredforum.com/topic/5100-regex-run-and-save-regular-expressions/) for Regex.

View some [examples of usage](http://matthewlancellotti.com/regex/).

## How to use Regex

For the s/ prefix, the code uses eval to get the full native behavior.  The o and p options are useless but allowed.  The r option is not allowed.

Use case: s/\b pigeon(s?) \b/quail$1/xgi


For sq/ prefix, there is no escaping or interpolation whatsoever.  The regex delimiters may not be escaped either, so you MUST pick a unique character for them (e.g. s%\qquad 2/3%\quad 2/3% ),or in the case of brackets, have proper nesting.  In addition to the above exclusions, the e, x, and s options are not available.  The i option is still available!

Use case: sq|regexstuff|stuff|g


For the tr/ and y/ prefixes, it is again native behavior.
