INCLUDE = include/

CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
		 -nostartfiles -nodefaultlibs -Wall -Wextra -c \
		 -I$(INCLUDE)

LDFLAGS = -T link.ld -melf_i386
ASFLAGS = -f elf

OBJECTS = kernel/kernel.o

all: kernel.elf

kernel.elf: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o kernel.elf

os.iso: kernel.elf
	cp kernel.elf iso/boot/kernel.elf
	genisoimage -R                              \
				-b boot/grub/stage2_eltorito    \
				-no-emul-boot                   \
				-boot-load-size 4               \
				-A os                           \
				-input-charset utf8             \
				-quiet                          \
				-boot-info-table                \
				-o os.iso                       \
				iso

run: os.iso
	bochs -f bochsrc.txt -q

%.o: %.c
	gcc $(CFLAGS)  $< -o $@

%.o: %.s
	nasm $(ASFLAGS) $< -o $@

clean:
	rm -rf *.o kernel.elf os.iso *.out kernel/kernel.o iso/boot/kernel.elf bochslog.txt

