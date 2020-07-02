TARGET = template-cmsis

PATH = $(TOOLCHAIN)/gcc-arm-none-eabi
AS = $(PATH)/bin/arm-none-eabi-as
LD = $(PATH)/bin/arm-none-eabi-ld
CC = $(PATH)/bin/arm-none-eabi-gcc
OC = $(PATH)/bin/arm-none-eabi-objcopy
OD = $(PATH)/bin/arm-none-eabi-objdump
OS = $(PATH)/bin/arm-none-eabi-size

ASFLAGS += -mcpu=cortex-m4
ASFLAGS += -mthumb
ASFLAGS += -Wall 
ASFLAGS += -c 
ASFLAGS += -fmessage-length=0 
ASFLAGS += -mfpu=fpv4-sp-d16
ASFLAGS += -mfloat-abi=softfp

CFLAGS += -mcpu=cortex-m4
CFLAGS += -std=gnu11
CFLAGS += -mthumb
CFLAGS += -g3
CFLAGS += -Og
CFLAGS += -ggdb
CFLAGS += -mfpu=fpv4-sp-d16
CFLAGS += -mfloat-abi=softfp
CFLAGS += -Wall
CFLAGS += -fmessage-length=0
CFLAGS += -ffunction-sections 
CFLAGS += -fdata-sections
CFLAGS += -fstack-usage
CFLAGS += --specs=nano.specs
CFLAGS += -DDEBUG
CFLAGS += -MMD
CFLAGS += -MP


LSCRIPT = ./ld/gd32.ld
#LFLAGS += -nostdlib
#LFLAGS += -static
#LFLAGS += --specs=nano.specs
LFLAGS += --specs=nosys.specs -Wl,-Map="template.map" -Wl,--gc-sections -static --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
LFLAGS += -T$(LSCRIPT)

DEFS += -DUSE_STDPERIPH_DRIVER

CMSISSRC += ./lib/CMSIS/GD/GD32F403/Source/system_gd32f403.c

STSRC += ./lib/GD32F403_standard_peripheral/Source/gd32f403_misc.c
STSRC += ./lib/GD32F403_standard_peripheral/Source/gd32f403_rcu.c
STSRC += ./lib/GD32F403_standard_peripheral/Source/gd32f403_gpio.c
STSRC += ./lib/GD32F403_standard_peripheral/Source/gd32f403_exti.c

SRC += ./src/main.c
SRC += ./src/systick.c
SRC += ./src/gd32f403_it.c
SRC += $(CMSISSRC)
SRC += $(STSRC)
		
ASRC = ./lib/CMSIS/GD/GD32F403/Source/GCC/startup_gd32f403.S

INCLUDE += -I./src
INCLUDE += -I./lib/CMSIS/GD/GD32F403/Include
INCLUDE += -I./lib/CMSIS
INCLUDE += -I./lib/GD32F403_standard_peripheral/Include
INCLUDE += -I./utils
INCLUDE += -I$(TOOLCHAIN)/arm-none-eabi/include
INCLUDE += -I$(TOOLCHAIN)/lib/gcc/arm-none-eabi/9.3.1/include
INCLUDE += -I$(TOOLCHAIN)/lib/gcc/arm-none-eabi/9.3.1/include-fixed

OBJS = $(ASRC:.S=.o) $(SRC:.c=.o)

all: $(TARGET).elf

$(TARGET).elf: $(OBJS)
	@echo	
	@echo Linking: $@
	$(CC) $(LFLAGS) -v -o $@ $^
	$(OD) -h -S $(TARGET).elf > $(TARGET).lst
		
flash: $(TARGET).elf size
	@echo
	@echo Creating .hex and .bin flash images:
	$(OC) -O ihex $< $(TARGET)_firmware.hex
	$(OC) -O binary $< $(TARGET)_firmware.bin
	
size: $(TARGET).elf
	@echo
	@echo == Object size ==
	@$(OS) --format=berkeley $<
	
%.o: %.c
	@echo
	@echo Compiling: $<
	$(CC) -c $(CFLAGS) $(DEFS) $(INCLUDE) -I. $< -o $@

%.o: %.S
	@echo
	@echo Assembling: $<
	$(CC) -x assembler-with-cpp -c $(ASFLAGS) $< -o $@	

clean: 
	@echo Cleaning:
	$(RM) $(OBJS)
	$(RM) *.elf
	$(RM) *.lst
	$(RM) *.map
	$(RM) *.bin
	$(RM) *.hex
