AS      = as
LD      = ld
OBJDUMP = objdump
GDB     = gdb

TARGET  = main
OBJS    = main.o gpio.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $@ $^

%.o: %.s
	$(AS) -g -o $@ $<

run: $(TARGET)
	./$(TARGET)

debug: $(TARGET)
	$(GDB) ./$(TARGET)

disasm: $(TARGET)
	$(OBJDUMP) -d $(TARGET)

clean:
	rm -f $(OBJS) $(TARGET)
