CONFIGS := \
		  screenrc \
		  tmux.conf \
		  toprc \
		  conkyrc \
		  xmonad.hs \
		  xinitrc \
		  $(wildcard Xmodmap*) \
		  Xresources \
		  gtkrc-2.0 \
		  vimperatorrc \
		  pentadactylrc \
		  vimrc \
		  gvimrc \
		  stline.vim \
		  zenburn.vim \
		  config.fish

DIRS := \
		.vimbackup \
		.vimswp
PREFIX := $(HOME)
COLLECT_DEST := .

INSTALL.PATH := $(PREFIX)
INSTALL.PATH.xmonad.hs := $(PREFIX)/.xmonad
INSTALL.PATH.stline.vim := $(PREFIX)/.vim/autoload
INSTALL.PATH.zenburn.vim := $(PREFIX)/.vim/colors
INSTALL.PATH.config.fish := $(PREFIX)/.config/fish

BACKUP := numbered
INSTALL.MODE := 644
INSTALL.MODE.xinitrc := 755

SUBPATHS := FISH_FUNCTIONS PENTADACTYL_PLUGINS BIN_FILES
FISH_FUNCTIONS := fish-functions .config/fish/functions
PENTADACTYL_PLUGINS := pentadactyl-plugins .pentadactyl/plugins
BIN_FILES := bin bin

help :
	@ echo "interesting targets: collect and install"
	@ echo "variables:"
	@ echo "	PREFIX          - installation prefix, default is \$$HOME"
	@ echo "	COLLECT_DESTDIR - directory where to collect, default is current directory"
	@ echo " 	BACKUP          - backup strategy, default is numbered. for additional info see man 1 install"
	@ echo "	INSTALL.MODE    - permissions of installed files, default is 644, unless overrided on per-file basis"

all : help

install: dirs $(foreach f, $(CONFIGS), install-$(f) ) $(foreach subpath_mapping_var, $(SUBPATHS), subpaths-install-$(subpath_mapping_var))

collect: $(COLLECT_DEST) $(foreach f, $(CONFIGS), collect-$(f) ) $(foreach subpath_mapping_var, $(SUBPATHS), subpaths-collect-$(subpath_mapping_var))

install-%: %
	install -D --backup=$(BACKUP) -m $(if $(INSTALL.MODE.$*),$(INSTALL.MODE.$*),$(INSTALL.MODE)) $* $(if $(INSTALL.PATH.$*), $(INSTALL.PATH.$*)/$*, $(INSTALL.PATH)/.$*)

collect-%:
	- cp $(if $(INSTALL.PATH.$*), $(INSTALL.PATH.$*)/$*, $(INSTALL.PATH)/.$*) $(COLLECT_DEST)/$*

# subpath helpers
repodir = $(firstword $($*))
installdir = $(lastword $($*))
PREFIX_ := $(addsuffix /, $(PREFIX))

subpaths-install-%:
	install -d $(addprefix $(PREFIX_), $(installdir))
	install --backup=$(BACKUP) -m $(INSTALL.MODE) \
		$(addprefix ./, $(repodir))/* \
		$(addprefix $(PREFIX_), $(installdir))

subpaths-collect-%:
	install -d $(addprefix $(addsuffix /, $(collect_dest)), $(repodir))
	- cp $(addprefix \
			$(addprefix $(PREFIX_), $(installdir)/), \
			$(notdir $(wildcard $(repodir)/*)) \
		 ) $(addprefix $(addsuffix /, $(collect_dest)), $(repodir))

dirs: $(foreach p, $(DIRS), $(PREFIX)/$p)

$(PREFIX)/%/:
	mkdir -p $@

$(COLLECT_DEST):
	mkdir -d $(COLLECT_DEST)

.PHONY: help
