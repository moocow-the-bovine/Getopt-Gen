# -*- Mode: CPerl -*-

#############################################################################
#
# File: Getopt::Gen::cmdline_h.pm
# Author: Bryan Jurish <Gen/cmdline_pod.pm>
# Description: template for gengetopt-style c headers
#
#############################################################################

package Getopt::Gen::cmdline_h;
use Getopt::Gen qw(:utils);

# fill_in(%args)
#   + provides 'SOURCE', 'TYPE', and 'PREPEND'
sub fill_in {
  my ($og,%args) = @_;

  ## -- get initial position of DATA
  my $datapos = tell(DATA);

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

  ## -- reset DATA
  seek(DATA,$datapos,0);

  return $rc;
}

1;

###############################################################
# POD docs
###############################################################
=pod

=head1 NAME

Getopt::Gen::cmdline_h.pm - built-in template for generating C header files.

=head1 SYNOPSIS

 use Getopt::Gen;

 $og = Getopt::Gen::cmdline_h->new(%args);
 $og->parse($options_file);
 $og->fill_in(%extra_text_template_fill_in_args);

=cut

###############################################################
# DESCRIPTION
###############################################################
=pod

=head1 DESCRIPTION

Generate C header files
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

Bryan Jurish E<lt>Gen/cmdline_pod.pmE<gt>

=head1 SEE ALSO

perl(1).
Getopt::Gen(3pm).
Getopt::Gen::cmdline_c(3pm).
Getopt::Gen::cmdline_pod(3pm).
Text::Template(3pm).

=cut


###############################################################
# TEMPLATE DATA
###############################################################
__DATA__
/* -*- Mode: C -*-
 *
 * File: [@$og{filename}@].h
 * Description: Headers for command-line parser struct [@$og{structname}@].
 *
 * File autogenerated by [@$og{name}@] version [@$OptGenVersion@].
 *
 */

#ifndef [@ long2cname($og{filename}) @]_h
#define [@ long2cname($og{filename}) @]_h

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/*
 * moocow: Never set PACKAGE and VERSION here.
 */

struct [@$og{structname}@] {
  [@
   ## -- option-value declarations
   $OUT .= join("\n  ",
		map {
		  my $opt = $og{opth}{$_};
		  (defined($opt) && defined($opt->{ctype}) && defined($opt->{cname})
		   ? ("$opt->{ctype} $opt->{cname}\;\t"
		      ." /* $opt->{descr} (default=$opt->{default}). */")
		   : qw())
		} @{$og{optl}});
  @]

  [@
   join("\n  ",
	map {
          my $opt = $og{opth}{$_};
	  my $optname = (defined($opt->{long}) ? $opt->{long} : "'-$opt->{short}'");
	  "int $opt->{cgiven}\;\t /* Whether $optname was given */"
	} @{$og{optl}});

  @]
  [@
   ($og{unnamed} ? '
  char **inputs;         /* unnamed arguments */
  unsigned inputs_num;   /* number of unnamed arguments */'
    : '')
  @]
};

/* read rc files (if any) and parse all command-line options in one swell foop */
int  [@$og{funcname}@] (int argc, char *const *argv, struct [@$og{structname}@] *args_info);

/* instantiate defaults from environment variables: you must call this yourself! */
void [@$og{funcname}@]_envdefaults (struct [@$og{structname}@] *args_info);

/* read a single rc-file */
void [@$og{funcname}@]_read_rcfile (const char *filename,
				    struct [@$og{structname}@] *args_info,
				    int user_specified);

/* read a single rc-file (stream) */
void [@$og{funcname}@]_read_rc_stream (FILE *rcfile,
				       const char *filename,
				       struct [@$og{structname}@] *args_info);

/* parse a single option */
int [@$og{funcname}@]_parse_option (char oshort, const char *olong, const char *val,
				    struct [@$og{structname}@] *args_info);

/* print help message */
void [@$og{funcname}@]_print_help(void);

/* print version */
void [@$og{funcname}@]_print_version(void);

#ifdef __cplusplus
}
#endif /* __cplusplus */
#endif /* [@long2cname($og{filename})@]_h */
