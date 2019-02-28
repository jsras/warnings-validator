PREFIX?=/usr/local
INSTALL_NAME = xcwarningsvalidator

install: build install_bin

build:
	swift package update
	swift build -c release -Xswiftc -static-stdlib

install_bin:
	mkdir -p $(PREFIX)/bin
	mv .build/Release/WarningsValidator .build/Release/$(INSTALL_NAME)
	install .build/Release/$(INSTALL_NAME) $(PREFIX)/bin

uninstall:
	rm -f $(PREFIX)/bin/$(INSTALL_NAME)