AS = nasm
ASFLAGS = -f elf64
LD = ld

all: infector_bin

infector_bin: src/infector.o
	$(LD) src/infector.o -o infector_bin

src/infector.o: src/infector.s
	$(AS) $(ASFLAGS) src/infector.s -o src/infector.o

clean:
	rm -f src/infector.o infector_bin
