function y=Keith(~)
y=true;

% Source Settings for KEITHLEY:
KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");
writeline(KLYSM2450,'smu.reset()');

writeline(KLYSM2450,'smu.measure.terminals = smu.TERMINALS_REAR')
writeline(KLYSM2450,'smu.measure.sense = smu.SENSE_2WIRE')
writeline(KLYSM2450,'smu.measure.autorange = smu.ON')
writeline(KLYSM2450,'smu.measure.func = smu.FUNC_DC_CURRENT')

%Voltage is the SOURCE function, Current is measurement:
writeline(KLYSM2450,'smu.source.func = smu.FUNC_DC_VOLTAGE')
writeline(KLYSM2450,'smu.source.highc = smu.OFF')
writeline(KLYSM2450,'smu.source.autorange = smu.ON')
writeline(KLYSM2450,'smu.source.readback = smu.ON')
writeline(KLYSM2450,'smu.source.output = smu.ON')
writeline(KLYSM2450,'smu.source.ilimit.level = 0.1')


NPLC=0.5;
Measurecount=10;
V=0;
writeline(KLYSM2450, strcat('smu.measure.count = ',string(Measurecount)))
writeline(KLYSM2450, strcat('smu.measure.nplc=', string(NPLC)))
writeline(KLYSM2450, strcat('smu.source.level = ',string(V))) 

writeline(KLYSM2450,'Voltage_Current_Initial_Buffer = buffer.make(100),buffer.STYLE_WRITABLE_FULL')
writeline(KLYSM2450,'Voltage_Current_Initial_Buffer.clear()')

writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Initial_Buffer)')
a=writeread(KLYSM2450,'printbuffer(1,Voltage_Current_Initial_Buffer.n,Voltage_Current_Initial_Buffer.readings)')
b=split(a,', ')
c=str2double(b)
f=mean(c)
d=mean(str2double(split(writeread(KLYSM2450,'printbuffer(1,Voltage_Current_Initial_Buffer.n,Voltage_Current_Initial_Buffer.readings)'),', ')))



writeline(KLYSM2450,'smu.source.output = smu.OFF') 