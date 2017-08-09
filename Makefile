SASS=scss
SASSFLAGS=--sourcemap=none
GLIB_COMPILE_RESOURCES=glib-compile-resources
RES_DIR=src/gtk-3.0
SCSS_DIR=$(RES_DIR)/scss
DIST_DIR=$(RES_DIR)/dist
RES_DIR320=src/gtk-3.20
SCSS_DIR320=$(RES_DIR320)/scss
DIST_DIR320=$(RES_DIR320)/dist
INSTALL_DIR=$(DESTDIR)/usr/share/themes/Numix
ROOT_DIR=${PWD}
UTILS=scripts/utils.sh
COLORS=scripts/colors.py
THEME=numix

all: clean gresource

preprocess:
	$(COLORS) theme_colors.$(THEME) src/gtk-2.0/gtkrc.in src/gtk-2.0/gtkrc
	$(COLORS) theme_colors.$(THEME) $(SCSS_DIR320)/_global.scss.in $(SCSS_DIR320)/_global.scss
	$(COLORS) theme_colors.$(THEME) $(SCSS_DIR)/_global.scss.in $(SCSS_DIR)/_global.scss

css: preprocess
	$(SASS) --update $(SASSFLAGS) $(SCSS_DIR):$(DIST_DIR)
	$(SASS) --update $(SASSFLAGS) $(SCSS_DIR320):$(DIST_DIR320)

gresource: css
	$(GLIB_COMPILE_RESOURCES) --sourcedir=$(RES_DIR) $(RES_DIR)/gtk.gresource.xml
	$(GLIB_COMPILE_RESOURCES) --sourcedir=$(RES_DIR320) $(RES_DIR320)/gtk.gresource.xml

watch: clean
	while true; do \
		make gresource; \
		inotifywait @gtk.gresource -qr -e modify -e create -e delete $(RES_DIR); \
	done

clean:
	rm -rf $(DIST_DIR)
	rm -f $(RES_DIR)/gtk.gresource
	rm -rf $(DIST_DIR320)
	rm -f $(RES_DIR320)/gtk.gresource
	rm -rf $(ROOT_DIR)/dist
	rm -f src/gtk-2.0/gtkrc
	rm -f $(SCSS_DIR)/_global.scss
	rm -f $(SCSS_DIR320)/_global.scss

install: all
	$(UTILS) install $(INSTALL_DIR)

uninstall:
	rm -rf $(INSTALL_DIR)

changes:
	$(UTILS) changes

zip: all
	mkdir $(ROOT_DIR)/dist
	$(UTILS) install $(ROOT_DIR)/dist/$$(basename $(INSTALL_DIR))
	cd $(ROOT_DIR)/dist && zip --symlinks -rq $$(basename $(INSTALL_DIR)) $$(basename $(INSTALL_DIR))


.PHONY: all
.PHONY: preprocess
.PHONY: css
.PHONY: watch
.PHONY: gresource
.PHONY: clean
.PHONY: install
.PHONY: uninstall
.PHONY: changes

.DEFAULT_GOAL := all

# vim: set ts=4 sw=4 tw=0 noet :
