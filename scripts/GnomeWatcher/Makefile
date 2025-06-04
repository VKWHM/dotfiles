BINDIR := ${out}/bin


build: gwatch

install: build
	mkdir -p $(BINDIR)
	install gwatch $(BINDIR)

gwatch: src/main.o
	gcc -o gwatch src/main.o

clean:
	rm -f src/*.o gwatch

.PHONY: build gwatch clean

