# Simple makefile for debian packaging system

default: all

install: 
	install -D -m 0644 ich9-ehci-uhci.cfg ${DESTDIR}/usr/share/run-kvm/ich9-ehci-uhci.cfg
	install -D -m 0755 run-kvm ${DESTDIR}/usr/bin/run-kvm

all:

clean:

