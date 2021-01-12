#!/bin/bash

if [ -e ~/Downloads/planespotter_*.bin ]; then
	mv ~/Downloads/planespotter_*.bin ./planespotter_dev.bin
fi
./stm32loader.py -e -w -v -p /dev/tty.usbserial* -b 57600 planespotter_dev.bin
