## Process this file with automake to produce Makefile.in

## Created by Anjuta

gladedir = $(datadir)/lifepad3/glade
glade_DATA = lifepad3.glade

AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(LIFEPAD3_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g

bin_PROGRAMS = lifepad3

lifepad3_SOURCES = \
	callbacks.c \
	callbacks.h \
	main.c

lifepad3_LDFLAGS = \
	-Wl,--export-dynamic

lifepad3_LDADD = $(LIFEPAD3_LIBS)

EXTRA_DIST = $(glade_DATA)
