function y=keithley2(V)
y=true;

KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");
disp ('The model of the SourceMeter device is:');
disp(writeread(KLYSM2450,'*IDN?'))
writeline(KLYSM2450,'beeper.beep(0.2, 2250); delay(0.250) ; beeper.beep(0.2, 2100)')
writeline(KLYSM2450,'smu.source.readback = smu.ON')
writeline(KLYSM2450, strcat('smu.source.level = ',string(V))) 
nplc=0.05;
writeline(KLYSM2450, strcat('smu.measure.nplc=', string(nplc))) 
writeline(KLYSM2450,'Voltage_Current_Initial_Buffer = buffer.make(10),buffer.STYLE_WRITABLE_FULL')
writeline(KLYSM2450,'smu.measure.count = 10')
writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Initial_Buffer)')
i=1;
voltage=zeros(i,1);

for i=1:10
voltage(i,1)=str2double(writeread(KLYSM2450,'for i = 1, Voltage_Current_Initial_Buffer.n do print(Voltage_Current_Initial_Buffer[i]) end'));
disp(voltage)
end

%writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Initial_Buffer)')

%writeline(KLYSM2450,'testData = buffer.make(50)')
%writeline(KLYSM2450,'trigger.model.load("SimpleLoop", 10, 0, Voltage_Current_Initial_Buffer)')
%writeline(KLYSM2450,'trigger.model.initiate()')
%writeline(KLYSM2450,'waitcomplete()')

%disp(writeread(KLYSM2450,'print(Voltage_Current_Initial_Buffer.relativetimestamps[1])'))
%disp(writeread(KLYSM2450,'printbuffer(1, 10, Voltage_Current_Initial_Buffer.relativetimestamps)'))

end