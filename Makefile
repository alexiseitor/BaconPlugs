
SLUG = BaconMusic
VERSION = 0.6.3
RELEASE_BRANCH = release_0.6.2

# FLAGS will be passed to both the C and C++ compiler
FLAGS +=
CFLAGS +=
CXXFLAGS += -Werror

# Careful about linking to shared libraries, since you can't assume much about the user's environment and library search path.
# Static libraries are fine.
LDFLAGS +=

# Add .cpp and .c files to the build
SOURCES += $(wildcard src/*.cpp)

# Add files to the ZIP package when running `make dist`
# The compiled plugin is automatically added.
DISTRIBUTABLES += $(wildcard LICENSE*) res docs patches README.md

# Include the VCV plugin Makefile framework
RACK_DIR ?= ../..
include $(RACK_DIR)/plugin.mk

shadist:	dist
	openssl sha256 dist/$(SLUG)-$(VERSION)-$(ARCH).zip > dist/$(SLUG)-$(VERSION)-$(ARCH).zip.sha256

COMMUNITY_ISSUE=https://github.com/VCVRack/community/issues/433

community:
	open $(COMMUNITY_ISSUE)

issue_blurb:	dist
	git diff --exit-code
	git diff --cached --exit-code
	@echo
	@echo "Paste this into github issue " $(COMMUNITY_ISSUE)
	@echo
	@echo "* Version: v$(VERSION)"
	@echo "* Transaction: " `git rev-parse HEAD`
	@echo "* Branch: " `git rev-parse --abbrev-ref HEAD`

install_local:	dist
	unzip -o dist/$(SLUG)-$(VERSION)-$(ARCH).zip -d ~/Documents/Rack/plugins

run_local:	install_local
	/Applications/Rack.app/Contents/MacOS/Rack

push_git:
	@echo "Pushing current branch to git and dropbox"
	git push dropbox `git rev-parse --abbrev-ref HEAD`
	git push github `git rev-parse --abbrev-ref HEAD`

win-dist: all
	rm -rf dist
	mkdir -p dist/$(SLUG)
	@# Strip and copy plugin binary
	cp $(TARGET) dist/$(SLUG)/
ifdef ARCH_MAC
	$(STRIP) -S dist/$(SLUG)/$(TARGET)
else
	$(STRIP) -s dist/$(SLUG)/$(TARGET)
endif
	@# Copy distributables
	cp -R $(DISTRIBUTABLES) dist/$(SLUG)/
	@# Create ZIP package
	echo "cd dist && 7z.exe a $(SLUG)-$(VERSION)-$(ARCH).zip -r $(SLUG)"
	cd dist && 7z.exe a $(SLUG)-$(VERSION)-$(ARCH).zip -r $(SLUG)
