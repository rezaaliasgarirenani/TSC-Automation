KYST2987=visadev("USB0::0x0957::0x9418::MY54321288::0::INSTR");

disp ('The model of the Electrometer device is:');
disp(writeread(KYST2987,'*IDN?'))