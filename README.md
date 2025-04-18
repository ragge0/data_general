nova-as is a 4.2BSD-compatible assembler adapted for Nova, that stores the output in a (possible executable) 2BSD a.out format file.

a2tap converts a Nova a.out file to a Nova bootable tape.

65emu is a 6502 emulator written in Nova assembler.  It starts by booting a tape, and then loads either a test program (from tape) or the Microsoft Basic PET PROMs, also from tape.
The test program can be fetched from 
* https://github.com/Klaus2m5/6502_65C02_functional_tests/blob/master/bin_files/6502_functional_test.bin

The three Basic PROMs need to be concatenated to one file.  Fetch the images from:
* https://www.zimmers.net/anonftp/pub/cbm/firmware/computers/pet/basic-2-c000.901465-01.bin
* https://www.zimmers.net/anonftp/pub/cbm/firmware/computers/pet/basic-2-d000.901465-02.bin
* https://www.zimmers.net/anonftp/pub/cbm/firmware/computers/pet/rom-3-e000.901447-24.bin

Just concat them together to a 10k file.   
See the Simh startup files in the directory.
