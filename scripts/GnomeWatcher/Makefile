CC = gcc
SRC = src/main.c
OBJ = src/main.o
OUT = gwatch
BINDIR := ${out}/bin
CFLAGS := $(shell pkg-config --cflags glib-2.0 gio-2.0) -lprocps
LDFLAGS := $(shell pkg-config --libs glib-2.0 gio-2.0) -lprocps

build: $(OUT)

install: build
	mkdir -p $(BINDIR)
	install gwatch $(BINDIR)

$(OUT): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	rm -f $(OUT) $(OBJ)

.PHONY: clean install build

