# Planespotter Open ADS-B Receiver
Planespotter is a side project by [Tom Byrne](https://github.com/ersatzavian). The goal is a small, low-cost ADS-B receiver that includes the RF front end and decoder stages. RF comes in, decoded traffic messages come out over USB. 

## Summary
The RF front-end on planespotter is heavily based upon the [miniadsb](http://miniadsb.web99.de/homepage/index.php?way=1&site=READOUT&DERNAME=miniADSB%20Tutorial&dm=miniadsb&USER=miniadsb&goto=1&XURL=web99.de&WB=&EXTRAX=X&PIDX=63606) receiver by jetvision. I'm grateful to them for being willing to sell me just one or two SAW filters. They're the best place to find the TA1090EC and TA0232A required by this design unless you're buying thousands of them. 

Planespotter uses an STM32F030K6 MCU as the decoder. The STM32 family of microprocessors includes a very useful embedded bootloader, so the device can be reprogrammed over UART, elminating the need for an expensive in-system programmer. This design also includes an FT230X USB-to-Serial bridge, so the MCU can be reprogrammed right from a PC with just a binary image file. 

![planespotter](images/planespotter.jpg)

## Programming
To write a new image to the onboard flash on the STM32F030K6:

1. You may need to install [FTDI's Virtual Com Port Driver](http://www.ftdichip.com/Drivers/VCP.htm) if you're not on OS X. 
2. Download and install Python, required for [stm32loader](https://github.com/jsnyder/stm32loader).
3. Download and install [pyserial](https://github.com/pyserial/pyserial), also required for stm32loader. If you have [pip](https://pip.readthedocs.io/en/stable/installing/), you can just `pip install pyserial`.
4. Plug planespotter into your PC over USB. If you're using a VM, make sure to share the FTDI USB-to-Serial Device with the VM from the host machine. 
5. Find the device name for the usb-serial adapter on your planespotter:

    ```
    $ ls /dev/tty.usbserial*
    /dev/tty.usbserial-DB00KYMI
    ```
6. Place the STM32 in Device Firmware Upgrade (DFU) Mode by holding S50 (BOOT0), tapping S20 (RESET_L), and releasing S50.
7. Make sure planespotter and the binary you are flashing are in the same directory (they are, if you're using a binary provided at planespotter/software/).
8. Use stm32loader to load the binary onto Planespotter:

    ```
    $ ./stm32loader.py -e -w -v -p /dev/tty.usbserial-DB00KYMI -b 57600 <image_name>
    Bootloader version 31
    Chip id: 0x444 (Unknown)
    Extended erase (0x44), this can take ten seconds or more
    Writing: 100% Time: 0:00:13 |#################################################|
    Reading: 100%, Time: 0:00:07 |################################################|
    Verification OK
    ```
9. When programming has finished, tap the Reset button (S20). 
10. Planespotter will talk over the same serial port you just used to program it as soon as it comes out of reset. Baud is 115200, no flow control. Fire up your favorite terminal emulator or use screen:

    ```
    screen dev/tty.usbserial-DB00KYMI 115200
    ```

## Firmware

Firmware for this project will be posted here as it is developed. This project doesn't have working ADS-B detector software yet as I wasn't able to located a signal with any of the crappy antennas I already have and I'm trying to get my hands on a signal generator to prove out the detector.

Firmware is probably going to have to be in assembly in order to provide the speed required to decode the 1 Mbps PPM ADS-B signal from the (missing) hardware comparator.

Prior to discovering assembly was likely a requirement, but after much messing around with Keil and STM32Cube, I did initial bringup and some tests with the [mbed platform](https://www.mbed.com/en/). This is a really handy way to work with this processor if you're not trying to shoehorn something into it like I now am. 

To use the mbed online compiler, go to [https://developer.mbed.org/compiler](https://developer.mbed.org/compiler). Planespotter bringup firmware was built using the [NUCLEO-F031K6 target](https://developer.mbed.org/platforms/ST-Nucleo-F031K6/) in the mbed compiler, which is effectively just a breakout board for the STM32F031. This is close enough to write software for Planespotter.

To grab the full mbed project I was using for bringup, use the mbed compiler and pick up the project from its [Mercurial Repository](https://developer.mbed.org/users/tombrew/code/planespotter_adc_logger/).

## Design Files
For the actual files used to produce fabricated boards, see the releases folder. Every release will include a schematic PDF, Bill of Materials (BOM), and set of Gerber files used to fab the PCB. 

## ECOs
### Rev 1.0
| Problem | Fix | Notes |
| ------- | --- | ----- |
| Allow onboard FTDI to toggle BOOT0 for easier target programming | | |
| Add labels to S20 and S50, J50 | | |
| Mark optional matching network more clearly and mark 0Ω resistors as "DNP" | | |
| Analog sampling isn't fast enough for 1 Mbps PPM ADS-B | Add external hardware comparator to generate a logic-level PPM signal, or switch to a micro with a built-in comparator | |

## Breadcrumbs
(I go long periods of time without messing with this thing).
 * The RF Front-End works! Proved out with a Telemakus TEG4000-1 signal generator and some attenuators on 4/2/18.
 * Added a comparator and it works too! Verified 4/2/18. Notes and schematic snippet:
 ![notes_0402](images/notes_20180402.JPG)
 * Added a TinyFPGA A1 to my Rev01 prototype as an option for ADS-B decoding; could just send UART info to the STM. Although at that point there's not much point in not just sending it to the USB Host to be plotted or posted to an online service - if the FPGA decoder works out, probably want to switch to an imp for a standalone receiver.  
 ** Tests with mbed Ticker locked the processor up when run faster than 100 kHz.

## License

All material in this repository (unless otherwise specificed in the file) is licensed under the MIT License.

See LICENSE.md for more information.
