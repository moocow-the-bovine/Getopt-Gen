MAIN_TARGETS = test1 test2 
DOC_FORMATS = .man .txt .html
#DOC_FORMATS = .man .txt .html .tex

DOC_TARGETS = \
	$(foreach tgt, $(MAIN_TARGETS), \
	  $(foreach fmt, $(DOC_FORMATS), \
		$(tgt)$(fmt)))

TARGETS = $(MAIN_TARGETS) $(DOC_TARGETS)

CC = gcc
CXX = g++
IFLAGS = -I/usr/local/include/stlport
DFLAGS = -DHAVE_CONFIG_H
OFLAGS = -g
WFLAGS = -Wall

LDFLAGS = -L/usr/local/lib
LDADD   =

all: $(TARGETS)

#----------------------------------------------------------------
# Misc deps

test1.o: test1.c test1_cmdline.h
test1: test1.o test1_cmdline.o
	$(CC)  $(WFLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS) $(LDFLAGS) -o $@ $^ $(LDADD)

test2.o: test2.c test2_cmdline.h
test2: test2.o test2_cmdline.o
	$(CC)  $(WFLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS) $(LDFLAGS) -o $@ $^ $(LDADD)


#cmdline_gog.h: cmdline_gog.gog ../optgen.perl ../Gen.pm ../Gen/Parser.pm ../Gen/cmdline_h.pm
#cmdline_gog.c: cmdline_gog.gog ../optgen.perl ../Gen.pm ../Gen/Parser.pm ../Gen/cmdline_c.pm

#----------------------------------------------------------------
# command-line parser-generation
.SUFFIXES: .gog .ggo .pod .c .h _cmdline.c _cmdline.h

.SECONDARY:

#GOGFLAGS = -u -l --reparse-action=warn --no-handle-error
GOGFLAGS = -l --no-handle-error
GGOFLAGS = -u -l --no-handle-error

.gog_cmdline.h:
	../optgen.perl $(GOGFLAGS) -nopod -F $*_cmdline $<

.gog_cmdline.c:
	../optgen.perl $(GOGFLAGS) -nopod -F $*_cmdline $<


#----------------------------------------------------------------
# POD CONVERSION
.SUFFIXES: .pod .man .txt .1 .html .tex

.gog.pod:
	../optgen.perl $(GOGFLAGS) -nocfile -nohfile -F $* $<

POD2MANARGS = --section=1 --center="Center Text"

doc: $(DOC_TARGETS)

.pod.man:
	pod2man $(POD2MANARGS) $< $@

.man.1:
	cp $< $@

.pod.txt:
	pod2text $< $@

.pod.html:
	pod2html --infile=$< --outfile=$@

.pod.tex:
	pod2latex -full -out $@ $<

#----------------------------------------------------------------
# Compilation Patterns

.c.o:
	$(CC) $(WFLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS) -c -o $@ $<


#----------------------------------------------------------------
# cleanup
clean:
	rm -f *~ *.o *_cmdline.[ch] $(TARGETS)
	rm -f [^a]*.pod *.html *.txt *.man *.1
	rm -f *.tex *.latex *.dvi *.ps *.pdf *.toc *.log *.idx *.aux
