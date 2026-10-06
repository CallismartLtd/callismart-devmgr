PKG      := callismart-devmgr
VERSION  ?= 0.1.0
PREFIX   ?= /usr/local
DESTDIR  ?=

BINDIR   := $(DESTDIR)$(PREFIX)/bin
APPDIR   := $(DESTDIR)$(PREFIX)/share/applications
BINS     := callismart-devmgr sitemgr phpmgr localssl
SCRIPTS  := sitemgr phpmgr localssl
DEB      := $(PKG)_$(VERSION)_all.deb

.PHONY: install uninstall check deb clean

install:
	install -d $(BINDIR) $(APPDIR)
	for b in $(BINS); do install -m 755 bin/$$b $(BINDIR)/$$b; done
	install -m 644 share/applications/$(PKG).desktop $(APPDIR)/$(PKG).desktop

uninstall:
	for b in $(BINS); do rm -f $(BINDIR)/$$b; done
	rm -f $(APPDIR)/$(PKG).desktop

check:
	for s in $(SCRIPTS); do bash -n bin/$$s || exit 1; done
	python3 -c "import ast; ast.parse(open('bin/callismart-devmgr').read())"

deb: check
	rm -rf build/deb
	$(MAKE) install DESTDIR=build/deb PREFIX=/usr
	install -d build/deb/DEBIAN
	sed 's/@VERSION@/$(VERSION)/' packaging/control > build/deb/DEBIAN/control
	dpkg-deb --root-owner-group --build build/deb $(DEB)

clean:
	rm -rf build $(PKG)_*_all.deb
