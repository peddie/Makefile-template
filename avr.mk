#### AVR support.  Currently you'll have to copy some of these flags
#### into the normal C values to get it to work.  

# What micro is it?
AVR_MCU ?= atxmega128a1
AVR_MCU_SHORT ?= x128a1

# Some useful flags for microcontroller development
AVR_BOTHFLAGS ?= -fshort-enums -funsigned-char -funsigned-bitfields -DF_CPU=32000000UL -mmcu=$(AVR_MCU) -O0
AVR_CFLAGS ?= -std=gnu99
AVR_CXXFLAGS ?= -fno-exceptions -std=gnu++11

# New targets.
AVRPROJ ?= $(PROJ:%=%.elf)
AVR_EXT_LISTING ?= $(AVRPROJ:%.elf=%.lss)
AVR_HEX ?= $(AVRPROJ:%.elf=%.hex)
AVR_EEPROM ?= $(AVRPROJ:%.elf=%.eep)

# Compiler setup
AVR_PREFIX = avr
AVR_CC = $(AVR_PREFIX)-gcc
AVR_CXX = $(AVR_PREFIX)-g++
AVR_AR = $(AVR_PREFIX)-ar

.PHONY: avr-lss avr-hex avr-ihex avr-eeprom avr-eep avr-sizedummy avr-subs avr-all flash

$(AVR_EXT_LISTING): $(AVRPROJ)
	@echo OBJDUMP $(notdir $<)
	$(Q)avr-objdump -h -S $(AVRPROJ) > $(AVR_EXT_LISTING)

$(AVR_HEX): $(AVRPROJ)
	@echo OBJCOPY $(notdir $<)
	$(Q)avr-objcopy -R .eeprom -O ihex $(AVRPROJ) $(AVR_HEX)

$(AVR_EEPROM): $(AVRPROJ)
	@echo OBJCOPY $(notdir $<)
	$(Q)avr-objcopy -j .eeprom --change-section-lma .eeprom=0 -O ihex $(AVRPROJ) $(AVR_EEPROM)

avr-sizedummy: $(AVRPROJ)
	@echo AVR-SIZE $(notdir $<)
	$(Q)avr-size --format=avr --mcu=$(AVR_MCU) $(AVRPROJ)

avr-all: $(AVRPROJ) avr-subs
avr-subs: avr-lss avr-hex avr-eep avr-sizedummy
avr-lss: $(AVR_EXT_LISTING)
avr-hex: $(AVR_HEX)
avr-ihex: $(AVR_HEX)
avr-eeprom: $(AVR_EEPROM)
avr-eep: $(AVR_EEPROM)

# The default here is to use the AVRISP mkII.  Be sure to change the
# settings for other programmers.
flash: $(AVR_HEX)
	@echo FLASH $(notdir $<) \(AVRISP mkII\)
	$(Q)avrdude -p$(AVR_MCU_SHORT) -cavrisp2 -Pusb -Uflash:w:$<:a

flash-eeprom: $(AVR_EEPROM)
	@echo FLASH-EEPROM $(notdir $<) \(AVRISP mkII\)
	$(Q)avrdude -p$(AVR_MCU_SHORT) -cavrisp2 -Pusb -Ueeprom:w:$<:a

LDOPTFLAGS ?= -Wl,--gc-sections -O0 -Wl,-Map=$(PROJ).map,--cref

USERFLAGS += $(AVR_BOTHFLAGS)
USERCFLAGS += $(AVR_CFLAGS)
USERCXXFLAGS += $(AVR_CXXFLAGS)

CC = $(AVR_CC)
CXX = $(AVR_CXX)
AR = $(AVR_AR)
