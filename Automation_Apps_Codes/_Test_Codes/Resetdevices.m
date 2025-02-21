LSTC336=serialport("COM3",57600);
KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");
KYST2987=visadev("USB0::0x0957::0x9418::MY54321288::0::INSTR");

LSTC336.FlowControl="none";
LSTC336.Parity="odd";
LSTC336.StopBits=1;
LSTC336.DataBits=7;


writeline(LSTC336,'*RST')
writeline(KYST2987,'*RST')
writeline(KLYSM2450,'*RST')