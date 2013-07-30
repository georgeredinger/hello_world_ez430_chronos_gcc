# MSP430		(Texas Instruments)
CPU	= MSP430
CC  = msp430-gcc
LD  = msp430-ld
PYTHON := $(shell which python2 || which python)

PROJ_DIR	=.
BUILD_DIR = build
CFLAGS_PRODUCTION = -Os -Wall#-Wl,--gc-sections # -ffunction-sections # -fdata-sections  -fno-inline-functions# -O optimizes
# more optimizion flags
CFLAGS_PRODUCTION +=  -fomit-frame-pointer -fno-force-addr -finline-limit=1 -fno-schedule-insns 
CFLAGS_PRODUCTION += -Wl,-Map=output.map
CFLAGS_DEBUG= -g -Os # -g enables debugging symbol table, -O0 for NO optimization

CC_CMACH	= -mmcu=cc430x6137
CC_DMACH	= -D__MSP430_6137__ -DMRFI_CC430 -D__CC430F6137__ #-DCC__MSPGCC didn't need mspgcc defines __GNUC__
CC_DOPT		= -DELIMINATE_BLUEROBIN
CC_INCLUDE = -I$(PROJ_DIR)/ -I$(PROJ_DIR)/include/ -I$(PROJ_DIR)/gcc/ -I$(PROJ_DIR)/driver/ -I$(PROJ_DIR)/logic/ -I$(PROJ_DIR)/bluerobin/ -I$(PROJ_DIR)/simpliciti/ -I$(PROJ_DIR)/simpliciti/Components/bsp -I$(PROJ_DIR)/simpliciti/Components/bsp/drivers -I$(PROJ_DIR)/simpliciti/Components/bsp/boards/CC430EM -I$(PROJ_DIR)/simpliciti/Components/mrfi -I$(PROJ_DIR)/simpliciti/Components/nwk -I$(PROJ_DIR)/simpliciti/Components/nwk_applications

CC_COPT		=  $(CC_CMACH) $(CC_DMACH) $(CC_DOPT)  $(CC_INCLUDE) 

MAIN_O = main.o 

ALL_O = $(LOGIC_O) $(DRIVER_O) $(SIMPLICICTI_O) $(MAIN_O)

ALL_S = $(addsuffix .s,$(basename $(LOGIC_SOURCE))) $(addsuffix .s,$(basename $(DRIVER_SOURCE))) $(addsuffix .s,$(basename $(SIMPLICICTI_SOURCE)))  \
        $(addsuffix .s,$(basename $(MAIN_SOURCE)))  


ALL_C = $(LOGIC_SOURCE) $(DRIVER_SOURCE) $(SIMPLICICTI_SOURCE) $(MAIN_SOURCE)

USE_CFLAGS = $(CFLAGS_PRODUCTION)

CONFIG_FLAGS ?= $(shell cat config.h | grep CONFIG_FREQUENCY | sed 's/.define CONFIG_FREQUENCY //' | sed 's/902/-DISM_US/' | sed 's/433/-DISM_LF/' | sed 's/868/-DISM_EU/')

ifeq (debug,$(findstring debug,$(MAKECMDGOALS)))
USE_CFLAGS = $(CFLAGS_DEBUG)
endif

main: main.o 
	@echo $(findstring debug,$(MAKEFLAGS))
	@echo "Compiling $@ for $(CPU)..."
	$(CC) $(CC_CMACH) $(CFLAGS_PRODUCTION) -o $(BUILD_DIR)/eZChronos.elf $(ALL_O) $(EXTRA_O)
	@echo "Convert to TI Hex file"
	$(PYTHON) tools/memory.py -i build/eZChronos.elf -o build/eZChronos.txt

clean: 
	@echo "Removing files..."
	rm -f $(ALL_O)
	rm -rf build/*

build:
	mkdir -p build

help:
	@echo "Valid targets are"
	@echo "    main"
#rm *.o $(BUILD_DIR)*



