# -*- Mode: Perl -*-

#############################################################################
#
# File: Getopt::Gen::cmdline_c.pm
# Author: Bryan Jurish <moocow@ling.uni-potsdam.de>
# Description: template for gengetopt-style c source files
#
#############################################################################

package Getopt::Gen::cmdline_c;
use Getopt::Gen qw(:utils);

# fill_in(%args)
#   + provides 'SOURCE', 'TYPE', and 'PREPEND'
sub fill_in {
  my ($og,%args) = @_;
  my $datapos = tell(DATA);  # save the DATA handle

  my $prepend = 'use Getopt::Gen qw(:utils);';
  if (exists($args{PREPEND})) {
    $prepend .= $args{PREPEND};
    delete($args{PREPEND});
  }

  my $rc = Getopt::Gen::fill_in($og,
				TYPE=>'FILEHANDLE',
				SOURCE=>\*DATA,
				PREPEND=>$prepend,
				BROKEN_ARG=>{SOURCE=>__PACKAGE__."::DATA"},
				%args);

  seek(DATA,$datapos,0); # reset DATA handle
  return $rc;
}

1;

###############################################################
# POD docs
###############################################################
=pod

=head1 NAME

Getopt::Gen::cmdline_c.pm - built-in template for generating C source files.

=head1 SYNOPSIS

 use Getopt::Gen;

 $og = Getopt::Gen::cmdline_c->new(%args);
 $og->parse($options_file);
 $og->fill_in(%extra_text_template_fill_in_args);

=cut

###############################################################
# DESCRIPTION
###############################################################
=pod

=head1 DESCRIPTION

Generate C source files
from option specifications.

###############################################################
# METHODS
###############################################################
=pod

=head1 METHODS

Most are inherited from L<Getopt::Gen>.

=over 4

=item * C<fill_in(%args)>

Just like the Getopt::Gen method, except you do
not need to specify 'TYPE' or 'SOURCE' parameters.

=back

=cut

###############################################################
# Bugs
###############################################################
=pod

=head1 BUGS

Probably many.

=cut

###############################################################
# Footer
###############################################################
=pod

=head1 ACKNOWLEDGEMENTS

perl by Larry Wall.

'gengetopt' was originally written by Roberto Arturo Tena Sanchez,
and it is currently maintained by Lorenzo Bettini.

=head1 AUTHOR

Bryan Jurish E<lt>moocow@ling.uni-potsdam.deE<gt>

=head1 SEE ALSO

perl(1).
Getopt::Gen(3pm).
Getopt::Gen::cmdline_h(3pm).
Getopt::Gen::cmdline_pod(3pm).
Text::Template(3pm).

=cut


###############################################################
# TEMPLATE DATA
###############################################################
__DATA__
/* -*- Mode: C -*-
 *
 * File: [@$og{filename}@].c
 * Description: Code for command-line parser struct [@$og{structname}@].
 *
 * File autogenerated by [@$og{name}@] version [@$OptGenVersion@]
 * generated with the following command:
 * [@$CMDLINE@]
 *
 * The developers of [@$og{name}@] consider the fixed text that goes in all
 * [@$og{name}@] output files to be in the public domain:
 * we make no copyright claims on it.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <pwd.h>
#include <ctype.h>

/* If we use autoconf/autoheader.  */
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

/* Allow user-overrides for PACKAGE and VERSION */
[@
  if (defined($og{package})) {
   $OUT .=
"#ifdef PACKAGE
#  undef PACKAGE
#endif
#define PACKAGE \"$og{package}\"
";
 } else {
   $OUT .=
'#ifndef PACKAGE
#  define PACKAGE "PACKAGE"
#endif
';
 }

 if (defined($og{version})) {
   $OUT .= "
#ifdef VERSION
#  undef VERSION
#endif
#define VERSION \"$og{version}\"
";
 } else {
   $OUT .= '
#ifndef VERSION
#  define VERSION "VERSION"
#endif
';
 }
@]

#ifndef PROGRAM
[@
  "# define PROGRAM " .(defined($og{USER}{program})
			? ('"'.$og{USER}{program}.'"')
			: PACKAGE);
@]
#endif

/* #define [@$og{funcname}@]_DEBUG */

/* Check for "configure's" getopt check result.  */
#ifndef HAVE_GETOPT_LONG
# include "getopt.h"
#else
# include <getopt.h>
#endif

#if !defined(HAVE_STRDUP) && !defined(strdup)
# define strdup gengetopt_strdup
#endif /* HAVE_STRDUP */

#include "[@$og{filename}@].h"


/* user code section */
[@
  defined($og{user_code}) ? $og{user_code} : ''
@]
/* end user  code section */


void
[@$og{funcname}@]_print_version (void)
{
  [@
   ('printf("'
    .(defined($og{USER}{program})
      ? ($og{USER}{program}
	 .(defined($og{USER}{program_version})
	   ? (" $og{USER}{program_version}")
	   : '')
	 .' (')
      : '')
    .'%s %s'
    .(defined($og{USER}{program}) ? ')' : '')
    .(defined($og{USER}{author}) ? " by $og{USER}{author}" : '')
    .'\n", PACKAGE, VERSION);');
  @]
}

void
[@$og{funcname}@]_print_help (void)
{
  [@$og{funcname}@]_print_version ();
  [@
   #//-- intro: purpose
   $OUT .= join("\n  ",
		q{printf("\n");},
		q{printf("Purpose:\n");},
		sprintf("printf(\"  %s\\n\");",
			defined($og{purpose}) ? $og{purpose} : "???"),
		q{printf("\n");},
	       );

  @]
  [@

   #// -- intro: usage
   $OUT .= ("\n  ".'printf("Usage: %s');
   #// -- intro: usage: options?
   if (@{$og{optl}}) {
     $OUT .= ' [OPTIONS]...';
   }
   #// -- intro: usage: argument names
   if ($og{unnamed}) {
     if (@{$og{args}}) {
       $OUT .= join("", map { " $_->{name}" } @{$og{args}});
     } else {
       $OUT .= " [FILES]...";
     }
   }
   $OUT .= ('\n", '
	    .($og{USER}{program}
	      ? ('"'.$og{USER}{program}.'"')
	      : 'PACKAGE')
	    .");");
  @]
  [@

   #// -- summary: argument descriptions
   if ($og{unnamed} && @{$og{args}}) {
     my ($arg,$maxarglen);
     #// -- get argument field-lengths
     foreach $arg (@{$og{args}}) {
      $maxarglen = length($arg->{name})
	if (!defined($maxarglen) || $maxarglen < length($arg));
     }
     $OUT .= ("\n  "
	      .join("\n  ",
		    q{printf("\n");},
		    q{printf(" Arguments:\n");},
		    map {
		    ("printf(\""
		     .sprintf("   %-${maxarglen}s  %s", $_->{name}, $_->{descr})
		     .'\n");'),
		    } @{$og{args}}));
   }
   '';
  @]
  [@

    #// -- summary: option descriptions
    if (@{$og{optl}}) {
      #// -- get option field-lengths
      my ($optid,$opt,$maxshortlen,$maxlonglen,$oshortlen,$olonglen);
      my ($short,$long,$descr);
      foreach $opt (values(%{$og{opth}})) {
	$oshortlen = $opt->{short} ne '-' ? 2 : 0;
	$olonglen = $opt->{long} ne '-' ? 2+length($opt->{long}) : 0;
	if ($opt->{arg}) {
	  $oshortlen += length($opt->{arg});
	  $olonglen += 1+length($opt->{arg});
	}
	$maxshortlen = $oshortlen
	  if (!defined($maxshortlen) || $maxshortlen < $oshortlen);
	$maxlonglen = $olonglen
	  if (!defined($maxlonglen) || $maxlonglen < $olonglen);
      }
      #// -- print option summary
      my $group = '';
      foreach $optid (@{$og{optl}}) {
	$opt = $og{opth}{$optid};
	if ($opt->{group} ne $group) {
          #// -- print group header
	  $group = $opt->{group};
	  $OUT .= ("\n  ".'printf("\n");'
		   ."\n  ".'printf(" '.$group.':\n");');
	}
        #// -- print option
	$short = $long = $descr = '';
	if (defined($opt->{short}) && $opt->{short} ne '-') {
	  $short = "-$opt->{short}";
	  $short .= $opt->{arg} if (defined($opt->{arg}));
	}
	if (defined($opt->{long}) && $opt->{long} ne '-') {
	  $long = $opt->{long};
	  $long = '--'.$long;
	  $long .= '='.$opt->{arg} if (defined($opt->{arg}));
	}
	next if ($short eq '' && !$og{longhelp});
	$OUT .= ("\n  "
		 .'printf("   '
		 .sprintf("%-${maxshortlen}s", $short)
		 .($og{longhelp} ? sprintf("  %-${maxlonglen}s", $long) : '')
		 .'  '.$opt->{descr}
		 .'\n");');
      }
    }
  @]
}

/* gengetopt_strdup(): automatically generated from strdup.c. */
/* strdup.c replacement of strdup, which is not standard */
static char *
gengetopt_strdup (const char *s)
{
  char *result = (char*)malloc(strlen(s) + 1);
  if (result == (char*)0)
    return (char*)0;
  strcpy(result, s);
  return result;
}


/* clear_args(args_info): clears all args & resets to defaults */
static void
clear_args(struct [@$og{structname}@] *args_info)
{[@
 foreach my $optid (@{$og{optl}}) {
   my $opt = $og{opth}{$optid};
   next if (!defined($opt->{cname}));
   next if ($opt->{type} eq 'funct');
   $OUT .= "\n  ".'args_info->'.$opt->{cname}.' = ';
   if ($opt->{type} eq 'string') {
     $OUT .= (defined($opt->{default}) && $opt->{default} ne 'NULL'
	      ? "strdup(\"$opt->{default}\")" : 'NULL');
   } else {
     $OUT .= (defined($opt->{default}) ? $opt->{default} : '0');
   }
   $OUT .= '; ';
 }
@]
}


int
[@$og{funcname}@] (int argc, char * const *argv, struct [@$og{structname}@] *args_info)
{
  int c;	/* Character of the parsed option.  */
  int missing_required_options = 0;	

  [@
   ## -- initialize 'given' flags
   join("\n  ",
	(map {
	  my $opt = $og{opth}{$_};
	  (defined($opt->{cgiven})
	   ? ("args_info-\>".$opt->{cgiven}." = 0;")
	   : qw())
         } @{$og{optl}}));
  @]

  clear_args(args_info);

  /* rcfile handling */
  [@
   if (defined($og{rcfiles}) && scalar(@{$og{rcfiles}})) {
     $OUT .= join("\n  ",
		  (map {
		    $og{funcname}."_read_rcfile(\"$_\", args_info, 0);"
		  } @{$og{rcfiles}}));
   }
   '';
  @]
  /* end rcfile handling */

  optarg = 0;
  optind = 1;
  opterr = 1;
  optopt = '?';

  while (1)
    {
      int option_index = 0;
      static struct option long_options[] = {
	[@
	 join("\n	",
	       map {
		 my $opt = $og{opth}{$_};
		 (defined($opt->{long}) && $opt->{long} ne '-'
		  ? ('{ "'.$opt->{long}.'", '
		     .(defined($opt->{arg}) ? '1' : '0')
		     .', NULL, '
		     .($opt->{short} ne '-' ? "'$opt->{short}'" : 0)
		     .' },')
		  : qw())
	       } @{$og{optl}});
	@]
        { NULL,	0, NULL, 0 }
      };
      static char short_options[] = {
	[@
	 my $oval = 
	 join("\n	",
	       map {
		 my $opt = $og{opth}{$_};
		 (defined($opt->{short}) && $opt->{short} ne '-'
		  ? ("'$opt->{short}',"
		     .(defined($opt->{arg}) ? " ':'," : ''))
		  : qw())
	       } @{$og{optl}});
	@]
	'\0'
      };

      c = getopt_long (argc, argv, short_options, long_options, &option_index);

      if (c == -1) break;	/* Exit from 'while (1)' loop.  */

      if ([@$og{funcname}@]_parse_option(c, long_options[option_index].name, optarg, args_info) != 0) {
	[@ $og{handle_error} ? 'exit' : 'return' @] (EXIT_FAILURE);
      }
    } /* while */

  [@
   #// -- check for missing required options
   foreach my $optid (@{$og{optl}}) {
     my $opt = $og{opth}{$optid};
     next if (!$opt->{required});
     my ($long,$short) = @$opt{qw(long short)};
     $long = undef if ($long && $long eq '-');
     $short = undef if ($short && $short eq '-');
     $OUT .= ('if (!args_info->'.$opt->{cgiven}.') {'."\n"
	      .'    fprintf(stderr, "%s:'
	      .(defined($long) ? (" \`--$long'") : '')
	      .(defined($short) ? " (\`-$short\')" : '')
	      .' option required\n", PACKAGE);'."\n"
	      ."    missing_required_options = 1;\n"
	      ."  }\n  ");
   }
  @]

  if ( missing_required_options )
    [@ $og{handle_error} ? 'exit' : 'return'  @] (EXIT_FAILURE);

  [@
   $og{unnamed} ? '
  if (optind < argc) {
      int i = 0 ;
      args_info->inputs_num = argc - optind ;
      args_info->inputs = (char **)(malloc ((args_info->inputs_num)*sizeof(char *))) ;
      while (optind < argc)
        args_info->inputs[ i++ ] = strdup (argv[optind++]) ; 
  }' : '';
  @]

  return 0;
}


/* Parse a single option */
int
[@$og{funcname}@]_parse_option(char oshort, const char *olong, const char *val,
			       struct [@$og{structname}@] *args_info)
{
  if (!oshort && !(olong && *olong)) return 1;  /* ignore null options */

#ifdef [@$og{funcname}@]_DEBUG
  fprintf(stderr, "parse_option(): oshort='%c', olong='%s', val='%s'\n", oshort, olong, val);*/
#endif

  switch (oshort)
    {
      [@
       #my $error_action = $og{handle_error} ? 'exit' : 'return';
       my $error_action = 'return';
       $og->{error_action} = $error_action;
	 my $indent = "        ";
	 my $zerocase = "case 0:\t /* Long option(s) with no short form */\n$indent";
	 my $gotlongonly = 0;
	 foreach my $optid (@{$og{optl}}) {
	   my $opt = $og{opth}{$optid};
	   my ($short,$long,$descr) = @$opt{qw(short long descr)};
	   $long = undef if ($long && $long eq '-');
	   $short = undef if ($short && $short eq '-');
	   my @ocode = qw();

	   $indent = "        ";
	   if ($og{reparse_action} ne 'clobber') {
	     push(@ocode,
		  '  if (args_info->'.$opt->{cgiven}.') {',
		  ('    fprintf(stderr, "%s:'
		   .(defined($long) ? (" \`--$long'") : '')
		   .(defined($short) ? " (\`-$short\')" : '')
		   .' option given more than once\n", PROGRAM);'),
		 );
	     if ($og{reparse_action} eq 'error') {
	       push(@ocode,
		    '    clear_args(args_info);',
		    "    $error_action (EXIT_FAILURE);",
		   );
	     }
	     push(@ocode, "  }");
	   }

	   if ($opt->{is_help} && $og{handle_help}) {
	     #// -- auto-help
	     push(@ocode,
		  '  clear_args(args_info);',
		  "  $og{funcname}_print_help();",
		  '  exit(EXIT_SUCCESS);',
		  '',
		 );
	   }
	   elsif ($opt->{is_version} && $og{handle_version}) {
	     #// -- auto-version
	     push(@ocode,
		  '  clear_args(args_info);',
		  "  $og{funcname}_print_version();",
		  '  exit(EXIT_SUCCESS);',
		  '',
		 );
	   }
	   elsif ($opt->{is_rcfile} && $og{handle_rcfile}) {
	     #// -- auto-rcfile
	     push(@ocode,
		  "  $og{funcname}_read_rcfile(val,args_info,1);",
		 );
	   }
	   else {  #// -- it's not an auto-handled option
	     #// -- always add to the 'given' flag
	     push(@ocode,
		  '  args_info->'.$opt->{cgiven}.'++;',
		 );

	     if ($opt->{type} eq 'funct') {
               #// -- boolean ("function") options : nothing more here
	       ;
	     }
	     elsif ($opt->{type} eq 'flag') {
               #// -- toggle ("flag") options
	       push(@ocode,
		    ('  args_info->'.$opt->{cname}.' = !(args_info->'.$opt->{cname}.');'),
		   );
	     }
	     elsif ($opt->{type} eq 'flag2') {
               #// -- flag options which don't toggle if given more than once
	       #//    (like 'funct' w/ default value)
	       push(@ocode,
		    ' if (args_info->'.$opt->{cgiven}." <= 1)",
		    ('   args_info->'.$opt->{cname}
		     .' = '
		     .'!(args_info->'.$opt->{cname}.');'),
		   );
	     }
	     elsif ($opt->{type} eq 'string') {
	       #// -- string-argument options
	       push(@ocode,
		    ('  if (args_info->'.$opt->{cname}.') free(args_info->'.$opt->{cname}.');'),
		    ('  args_info->'.$opt->{cname}." = strdup(val);"),
		   );
	     }
	     elsif ($opt->{type} eq 'int'
		    || $opt->{type} eq 'short'
		    || $opt->{type} eq 'long')
	       {
		 push(@ocode,
		      ('  args_info->'.$opt->{cname}." = ($opt->{type})atoi(val);")
		     );
	       }
	     elsif ($opt->{type} eq 'float'
		    || $opt->{type} eq 'double'
		    || $opt->{type} eq 'longdouble')
	       {
		 push(@ocode,
		      ('  args_info->'.$opt->{cname}." = ($opt->{ctype})strtod(val, NULL);"),
		     );
	       }
	   }
	   if (defined($opt->{code})) {
	     #// -- add user code
	     push(@ocode,
		  '  /* user code */',
		  ('  '.(eval $opt->{code})),
		 );
	   }


	   if (defined($short)) {
             #// -- add a case to the short-option switch statement
	     $OUT .= join("\n$indent",
			  "case '$short':\t /* $opt->{descr} */",
			  @ocode,
			  "  break;",
			  '','');
	   }
	   if (defined($long)) {
	     #// -- add a case to the long-option conditional
	     $zerocase .= join("\n$indent  ",
			       "/* $descr */",
			       (($gotlongonly ? 'else ' : '')
				.'if (strcmp(olong, "'.$long.'") == 0) {'),
			       @ocode,
			       "}",
			       '','');
	     $gotlongonly = 1;
	   }
	 }

         #// -- add zero-case (long w/o short)
	 $OUT .= ($zerocase
		  ."else {\n$indent"
		  .'    fprintf(stderr, "%s: unknown long option \'%s\'.\n", PROGRAM, olong);'."\n$indent"
		  .'    '.$error_action.' (EXIT_FAILURE);'."\n$indent"
		  ."  }\n$indent"
		  ."  break;\n\n$indent"
		  .(#//-- add invalid-case (short)
		    "case '?':\t /* Invalid Option */\n$indent"
		    #."  /* \`getopt_long\' already printed an error message. */\n$indent"
		    .'  fprintf(stderr, "%s: unknown option \'%s\'.\n", PROGRAM, olong);'."\n$indent"
		    .'  '.$error_action.' (EXIT_FAILURE);'."\n"));
	@]

        default:	/* bug: options not considered.  */
          fprintf (stderr, "%s: option unknown: %c\n", PROGRAM, oshort);
          abort ();
        } /* switch */
  return 0;
}


/* Initialize options not yet given from environmental defaults */
void
[@$og{funcname}@]_envdefaults(struct [@$og{structname}@] *args_info)
{
  [@
   foreach my $optid (@{$og{optl}}) {
     my $opt = $og{opth}{$optid};
     next if (!$opt->{edefault});
     my ($type,$cname,$cgiven,$edefault) =
       @$opt{qw(type cname cgiven edefault)};
     $OUT .= ('if (!args_info->'.$cgiven.") {\n  "
	      .'  char *value = getenv("'.$edefault.'");'
	      ."\n  "
	      ."  if (value != NULL) {\n  ");
     if ($type eq 'string') {
       $OUT .= ('      if (args_info->'.$cname.') free(args_info->'.$cname.");\n  "
		.'      args_info->'.$cname." = strdup(value);\n  "
		."  }\n  "
		."}\n  ");
     }
     elsif ($type eq 'funct' || $type eq 'flag' || $type eq 'flag2'
	 || $type eq 'int' || $type eq 'short' || $type eq 'long')
       {
	 $OUT .= ('      args_info->'.$cname." = ($opt->{ctype})atoi(value);\n  "
		  ."  }\n  "
		  ."}\n  ");
       }
     elsif ($type eq 'float' || $type eq 'double' || $type eq 'longdouble')
       {
	 $OUT .= ('      args_info->'.$cname." = ($opt->{ctype})strtod(value,NULL);\n  "
		  ."  }\n  "
		  ."}\n  ");
       }
   }
  @]

  return;
}


/* Load option values from an .rc file */
void
[@$og{funcname}@]_read_rcfile(const char *filename,
			      struct [@$og{structname}@] *args_info,
			      int user_specified)
{
  char *fullname;
  FILE *rcfile;

  if (!filename) return; /* ignore NULL filenames */

  if (*filename == '~') {
    /* tilde-expansion hack */
    struct passwd *pwent = getpwuid(getuid());
    if (!pwent) {
      fprintf(stderr, "%s: user-id %d not found!\n", PROGRAM, getuid());
      return;
    }
    if (!pwent->pw_dir) {
      fprintf(stderr, "%s: home directory for user-id %d not found!\n", PROGRAM, getuid());
      return;
    }
    fullname = (char *)malloc(strlen(pwent->pw_dir)+strlen(filename));
    strcpy(fullname, pwent->pw_dir);
    strcat(fullname, filename+1);
  } else {
    fullname = strdup(filename);
  }

  /* try to open */
  rcfile = fopen(fullname,"r");
  if (!rcfile) {
    if (user_specified) {
      fprintf(stderr, "%s: warning: open failed for rc-file '%s': %s\n",
	      PROGRAM, fullname, strerror(errno));
    }
  }
  else {
   [@$og{funcname}@]_read_rc_stream(rcfile, fullname, args_info);
  }

  /* cleanup */
  if (fullname != filename) free(fullname);
  if (rcfile) fclose(rcfile);

  return;
}


/* Parse option values from an .rc file : guts */
#define OPTPARSE_GET 32
void
[@$og{funcname}@]_read_rc_stream(FILE *rcfile,
				 const char *filename,
				 struct [@$og{structname}@] *args_info)
{
  char *optname  = (char *)malloc(OPTPARSE_GET);
  char *optval   = (char *)malloc(OPTPARSE_GET);
  size_t onsize  = OPTPARSE_GET;
  size_t ovsize  = OPTPARSE_GET;
  size_t onlen   = 0;
  size_t ovlen   = 0;
  int    lineno  = 0;
  char c;

#ifdef [@$og{funcname}@]_DEBUG
  fprintf(stderr, "[@$og{funcname}@]_read_rc_stream('%s'):\n", filename);
#endif

  while ((c = fgetc(rcfile)) != EOF) {
    onlen = 0;
    ovlen = 0;
    lineno++;

    /* -- get next option-name */
    /* skip leading space and comments */
    if (isspace(c)) continue;
    if (c == '#') {
      while ((c = fgetc(rcfile)) != EOF) {
	if (c == '\n') break;
      }
      continue;
    }

    /* parse option-name */
    while (c != EOF && c != '=' && !isspace(c)) {
      /* re-allocate if necessary */
      if (onlen >= onsize-1) {
	char *tmp = (char *)malloc(onsize+OPTPARSE_GET);
	strcpy(tmp,optname);
	free(optname);

	onsize += OPTPARSE_GET;
	optname = tmp;
      }
      optname[onlen++] = c;
      c = fgetc(rcfile);
    }
    optname[onlen++] = '\0';

#ifdef [@$og{funcname}@]_DEBUG
    fprintf(stderr, "[@$og{funcname}@]_read_rc_stream('%s'): line %d: optname='%s'\n",
	    filename, lineno, optname);
#endif

    /* -- get next option-value */
    /* skip leading space */
    while ((c = fgetc(rcfile)) != EOF && isspace(c)) {
      ;
    }

    /* parse option-value */
    while (c != EOF && c != '\n') {
      /* re-allocate if necessary */
      if (ovlen >= ovsize-1) {
	char *tmp = (char *)malloc(ovsize+OPTPARSE_GET);
	strcpy(tmp,optval);
	free(optval);
	ovsize += OPTPARSE_GET;
	optval = tmp;
      }
      optval[ovlen++] = c;
      c = fgetc(rcfile);
    }
    optval[ovlen++] = '\0';

    /* now do the action for the option */
    if ([@$og{funcname}@]_parse_option('\0',optname,optval,args_info) != 0) {
      fprintf(stderr, "%s: error in file '%s' at line %d.\n", PROGRAM, filename, lineno);
      [@ $og{handle_errors} ? 'exit (EXIT_FAILURE);' : '' @]
    }
  }

  /* cleanup */
  free(optname);
  free(optval);

  return;
}