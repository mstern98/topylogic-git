# SPDX-License-Identifier: MIT WITH bison-exception WITH swig-exception
# Copyright © 2020 Matthew Stern, Benjamin Michalowicz

CC=gcc
BIN=topylogic

LDFLAGS= -ltopologic
CFLAGS= -g -Wall -Wextra `pkg-config --cflags python3`

TOPYLOGIC_I=src/topylogic.i
TOPYLOGIC_WRAP=src/topylogic_wrap.c
TOPYLOGIC_SO=src/_topylogic.so
TOPYLOGIC_PY=src/topylogic.py
TOPYLOGIC_O=src/topylogic_wrap.o

$(BIN): 
	swig -python $(TOPYLOGIC_I)
	$(CC) -c -fPIC $(TOPYLOGIC_WRAP) -o $(TOPYLOGIC_O) $(LDFLAGS) $(CFLAGS)
	$(CC) -shared $(TOPYLOGIC_O) -o $(TOPYLOGIC_SO)

all:$(BIN)
.PHONY : clean python

clean:
	rm -rf src/__pycache__
	rm -rf src/build
	-rm $(TOPYLOGIC_PY) 
	-rm $(TOPYLOGIC_SO) 
	-rm $(TOPYLOGIC_O) 
	-rm $(TOPYLOGIC_WRAP)
	-rm -f src/state_*

