# SPDX-License-Identifier: MIT WITH bison-exception WITH swig-exception
# Copyright © 2020 Matthew Stern, Benjamin Michalowicz

CC=gcc
BIN=topylogic

SRC=$(wildcard src/*.c)
INCLUDES= $(wildcard include/*.h)
OBJ=$(SRC:.c=.o)

LDFLAGS= -lm -lpthread -L. -ltopologic -pthread 
CFLAGS=  -Wall -Werror -g	-fPIC -O2 `pkg-config --cflags python3`
PYFLAGS= `pkg-config --cflags python3`

TOPYLOGIC_I=pysrc/topylogic.i
TOPYLOGIC_WRAP=pysrc/topylogic_wrap.c
TOPYLOGIC_SO=pysrc/_topylogic.so
TOPYLOGIC_PY=pysrc/topylogic.py
TOPYLOGIC_O=pysrc/topylogic_wrap.o

$(BIN): $(OBJ) $(INCLUDES) 
	swig  -python -keyword $(TOPYLOGIC_I)
	$(CC) -c -fPIC $(TOPYLOGIC_WRAP) -o $(TOPYLOGIC_O) $(PYFLAGS)
	$(CC) -shared $(TOPYLOGIC_O) $(OBJ) -o $(TOPYLOGIC_SO) 

all:$(BIN)
.PHONY : clean python

clean:
	rm -rf pysrc/__pycache__
	rm -rf pysrc/build
	-rm $(OBJ)
	-rm $(TOPYLOGIC_PY) 
	-rm $(TOPYLOGIC_SO) 
	-rm $(TOPYLOGIC_O) 
	-rm $(TOPYLOGIC_WRAP)
	-rm -f pysrc/state_*

