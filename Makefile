.PHONY: all
all:
	rgbasm -L -o object.o source.asm
	rgblink -o output.gb object.o
	rgbfix -v -p 0x00 output.gb
clean:
	rm object.o output.gb
