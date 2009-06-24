
TARGET = shotwell

VALAC = valac
INSTALL_PROGRAM = install
INSTALL_DATA = install -m 644

VALAFLAGS = -g --enable-checking
ifdef dev
DEVFLAGS = --save-temps -X -O0
endif

# C99 takes care of a warning message generated by the use of Math.round in image_util.vala
ALL_VALAFLAGS = $(VALAFLAGS) $(DEVFLAGS) --Xcc=-std=c99

PREFIX=/usr/local
-include configure.in

SRC_FILES = \
	main.vala \
	AppWindow.vala \
	CollectionPage.vala \
	Thumbnail.vala \
	DatabaseTables.vala \
	ThumbnailCache.vala \
	image_util.vala \
	CollectionLayout.vala \
	PhotoPage.vala \
	Exif.vala \
	Page.vala \
	ImportPage.vala \
	GPhoto.vala \
	SortedList.vala \
	EventsDirectoryPage.vala \
	Dimensions.vala \
	Box.vala \
	Photo.vala \
	Orientation.vala \
	util.vala \
	BatchImport.vala \
	ExportDialog.vala \
	Resources.vala \
	Debug.vala

VAPI_FILES = \
	libexif.vapi \
	fstream.vapi \
	libgphoto2.vapi

RESOURCE_FILES = \
	photo.ui \
	collection.ui \
	import.ui \
	fullscreen.ui \
	import_queue.ui \
	events_directory.ui \
	event.ui

SRC_HEADER_FILES = \
	gphoto.h

VAPI_DIRS = \
	./src

HEADER_DIRS = \
	./src

LOCAL_PKGS = \
	fstream \

EXT_PKGS = \
	gtk+-2.0 \
	sqlite3 \
	vala-1.0 \
	hal \
	dbus-glib-1 \
	unique-1.0 \
	libexif \
	libgphoto2

EXT_PKG_VERSIONS = \
	gtk+-2.0 >= 2.14.4 \
	sqlite3 >= 3.5.9 \
	vala-1.0 >= 0.7.3 \
	hal >= 0.5.11 \
	dbus-glib-1 >= 0.76 \
	unique-1.0 >= 1.0.0 \
	libexif >= 0.6.16 \
	libgphoto2 >= 2.4.2

EXPANDED_SRC_FILES = $(foreach src,$(SRC_FILES), src/$(src))
EXPANDED_VAPI_FILES = $(foreach vapi,$(VAPI_FILES), src/$(vapi))
EXPANDED_SRC_HEADER_FILES = $(foreach header,$(SRC_HEADER_FILES), src/$(header))

PKGS = $(EXT_PKGS) $(LOCAL_PKGS)

all: $(TARGET)

clean:
	rm -f src/*.c
	rm -f $(CONFIG_IN)
	rm -f $(TARGET)

cleantemps:
	rm -f *.c

install: $(TARGET) misc/shotwell.desktop
	$(INSTALL_PROGRAM) $(TARGET) $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/shotwell/icons
	$(INSTALL_DATA) icons/* $(DESTDIR)$(PREFIX)/share/shotwell/icons
	$(INSTALL_DATA) icons/shotwell.svg $(DESTDIR)/usr/share/icons/hicolor/scalable/apps
	update-icon-caches $(DESTDIR)/usr/share/icons/hicolor
	mkdir -p $(DESTDIR)$(PREFIX)/share/shotwell/ui
	$(INSTALL_DATA) ui/* $(DESTDIR)$(PREFIX)/share/shotwell/ui
	xdg-desktop-menu install --novendor misc/shotwell.desktop
	update-desktop-database

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(TARGET)
	rm -fr $(DESTDIR)$(PREFIX)/share/shotwell
	rm -fr $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/shotwell.svg
	xdg-desktop-menu uninstall shotwell.desktop
	update-desktop-database

$(TARGET): $(EXPANDED_SRC_FILES) $(EXPANDED_VAPI_FILES) $(EXPANDED_SRC_HEADER_FILES) Makefile configure $(CONFIG_IN)
ifndef ASSUME_PKGS
ifdef EXT_PKGS
	pkg-config --print-errors --exists $(EXT_PKGS)
endif
ifdef EXT_PKG_VERSIONS
	pkg-config --print-errors --exists '$(EXT_PKG_VERSIONS)'
endif
endif
	$(VALAC) $(ALL_VALAFLAGS) \
	$(foreach pkg,$(PKGS),--pkg=$(pkg)) \
	$(foreach vapidir,$(VAPI_DIRS), --vapidir=$(vapidir)) \
	$(foreach hdir,$(HEADER_DIRS),-X -I$(hdir)) \
	-X -DPREFIX='"$(PREFIX)"' \
	$(EXPANDED_SRC_FILES) \
	-o $(TARGET)

