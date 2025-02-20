LSTC336=serialport("COM3",57600);

LSTC336.FlowControl="none";
LSTC336.Parity="odd";
LSTC336.StopBits=1;
LSTC336.DataBits=7;
writeline(LSTC336,'*RST')