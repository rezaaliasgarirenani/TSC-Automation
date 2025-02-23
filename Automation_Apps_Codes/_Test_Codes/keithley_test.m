function keithley_test()

KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");
disp ('The model of the SourceMeter device is:');
disp(writeread(KLYSM2450,'*IDN?'))