CM4_PROJ ?= $(PROJ:%=%.elf)

HARD_FLOAT_FLAGS ?= -mfloat-abi=hard 

LDSCRIPT ?= $(PROJ).ld
BMP_PORT ?= /dev/ttyACM0

CM4_PREFIX = arm-none-eabi

CM4_CC = $(CM4_PREFIX)-gcc
CM4_CXX = $(CM4_PREFIX)-g++
CM4_AR = $(CM4_PREFIX)-ar
CM4_DB = $(CM4_PREFIX)-gdb
CM4_OBJCOPY = $(CM4_PREFIX)-objcopy
CM4_OBJDUMP = $(CM4_PREFIX)-objdump
CM4_SIZE = $(CM4_PREFIX)-size

# the -mcpu flag is commented out because it seems to break linkage
# using the gcc-arm-embedded toolchain when using the hardware
# floating point ABI.
CM4_BOTHFLAGS ?= -DSTM32F4 -mfpu=fpv4-sp-d16 -mthumb -mcpu=cortex-m4
CM4_CFLAGS ?= 
CM4_CXXFLAGS ?= -fno-exceptions

CM4_LDFLAGS ?= --static -lc -lnosys -nostartfiles -T$(LDSCRIPT)

LDOPTFLAGS ?= -Wl,--gc-sections -Wl,-Map=$(PROJ).map,--cref

USERFLAGS += $(CM4_BOTHFLAGS) $(HARD_FLOAT_FLAGS)
USERCFLAGS += $(CM4_CFLAGS)
USERCXXFLAGS += $(CM4_CXXFLAGS)
USERLDFLAGS += $(CM4_LDFLAGS) $(HARD_FLOAT_FLAGS)

CC = $(CM4_CC)
CXX = $(CM4_CXX)
AR = $(CM4_AR)
DB = $(CM4_DB)
OBJCOPY = $(CM4_OBJCOPY)
OBJDUMP = $(CM4_OBJDUMP)
SIZE = $(CM4_SIZE)

flash: $(CM4_PROJ)
	@echo FLASH $(notdir $<) \(BMP\)
	$(Q)$(CM4_DB) --batch \
                      -ex 'target extended-remote $(BMP_PORT)' \
                      -ex 'monitor swdp_scan' \
                      -ex 'attach 1' \
                      -ex 'monitor erase_mass' \
                      -ex 'load' \
                      $(CM4_PROJ)

$(CM4_PROJ:%.elf=%.images) : %.images: %.bin %.hex %.srec %.list %.elf

cm4-all: $(CM4_PROJ:%.elf=%.images)

%.bin: %.elf
	@echo OBJCOPY $(notdir $@)
	$(Q)$(OBJCOPY) -Obinary $(*).elf $(@)

%.hex: %.elf
	@echo OBJCOPY $(notdir $@)
	$(Q)$(OBJCOPY) -Oihex $(*).elf $(@)

%.srec: %.elf
	@echo OBJCOPY $(notdir $@)
	$(Q)$(OBJCOPY) -Osrec $(*).elf $(@)

%.list: %.elf
	@echo OBJDUMP $(notdir $@)
	$(Q)$(OBJDUMP) -S $(*).elf > $(@)

%.size: %.elf
	@printf "\n"
	@printf "  =======================\n"
	@printf "  Section sizes in bytes:\n"
	@printf "\n"
	$(Q)$(SIZE) -A -x $<

CM4_IMAGES ?= $(CM4_PROJ:%.elf=%.hex) $(CM4_PROJ:%.elf=%.srec) $(CM4_PROJ:%.elf=%.bin) $(CM4_PROJ)
CM4_EXT_LISTING ?= $(CM4_PROJ:%.elf=%.list) $(CM4_PROJ:%.elf=%.map)

.PHONY: $(CM4_PROJ:%.elf=%.images) size cm4-all
