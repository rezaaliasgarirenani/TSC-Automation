function y=keithley(V)
y=true;

KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");


disp ('The model of the SourceMeter device is:');
disp(writeread(KLYSM2450,'*IDN?'))
writeline(KLYSM2450,'beeper.beep(0.35, 1500); delay(0.35) ; beeper.beep(0.35, 1500)')
writeline(KLYSM2450,'reset()');
%Testing different Codes:

%printing and elementary math:
%writeline(KLYSM2450,'x = math.abs(-100)')
%writeread(KLYSM2450, 'print(x)')

%reset:
writeline(KLYSM2450,'reset()');

%setting up functions:
%writeline(KLYSM2450,'smu.source.func = smu.FUNC_DC_CURRENT ; smu.measure.func = smu.FUNC_DC_VOLTAGE ; smu.measure.range = 15')
%writeline(KLYSM2450,'smu.source.func = smu.FUNC_DC_VOLTAGE ; smu.source.autorange = smu.ON')
%writeline(KLYSM2450,'format.data = format.ASCII')
%Voltage is the SOURCE function: 
writeline(KLYSM2450,'smu.measure.func = smu.FUNC_DC_CURRENT')
writeline(KLYSM2450,'smu.source.func = smu.FUNC_DC_VOLTAGE')≠–≠



%Measurement Settings:
writeline(KLYSM2450,'smu.measure.terminals = smu.TERMINALS_FRONT')
writeline(KLYSM2450,'smu.measure.sense = smu.SENSE_2WIRE')
writeline(KLYSM2450,'smu.measure.autorange = smu.ON')
writeline(KLYSM2450,'smu.measure.nplc=1')
%writeline(KLYSM2450, strcat('smu.measure.count = ',string(n)))
writeline(KLYSM2450,'frequency=localnode.linefreq');
freq=str2double(writeread(KLYSM2450,'print(frequency)'));
disp(freq)

% Measurement Source:
writeline(KLYSM2450,'smu.source.highc = smu.OFF')
writeline(KLYSM2450,'smu.source.autorange = smu.ON')
writeline(KLYSM2450,'smu.source.readback = smu.ON')
writeline(KLYSM2450, strcat('smu.source.level = ',string(V))) %Sets the initial voltage
writeline(KLYSM2450,'smu.source.output = smu.ON')


%make buffer and print readings:
writeline(KLYSM2450,'Voltage_Current_Buffer = buffer.make(10),buffer.STYLE_WRITABLE_FULL')

i=1;
m=1;
j=1;
voltage=zeros(m,1);
current=zeros(i,1);

%while true
%writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')  
%{
%val=(writeread(KLYSM2450,'printbuffer(1, 1, Voltage_Current_Buffer.readings, Voltage_Current_Buffer.units, Voltage_Current_Buffer.sourcevalues, Voltage_Current_Buffer)'));
%values(j,1)=str2double(writeread(KLYSM2450,'printbuffer(1, 1, Voltage_Current_Buffer.sourcevalues)'));
voltagetest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
voltage(m,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
currenttest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
current(j,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
disp('              VOLTAGE:                             CURRENT:');
Y1=['              ',num2str(voltagetest),'                                ',num2str(currenttest)];
disp(Y1);
%}



writeline(KLYSM2450,'trigger.model.load("SimpleLoop",10,0.1,Voltage_Current_Buffer)')
writeline(KLYSM2450,'trigger.model.initiate()') 
writeline(KLYSM2450,'waitcomplete()')
%writeline(KLYSM2450,'format.data = format.ASCII')
%disp(writeread(KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.readings)'));
vector=(writeread(KLYSM2450,'printbuffer(1,Voltage_Current_Buffer.n,Voltage_Current_Buffer.readings)'))
cur=split(vector,',')
disp('all The values of vector are:')
disp(vector);


%disp('all The value of Current are:')
%current=str2double(split(writeread(KLYSM2450,'for i = 1, Voltage_Current_Buffer.n do print(Voltage_Current_Buffer[i]) end')))

%writeread(KLYSM2450,'for i = 1, Voltage_Current_Buffer.n do print(Voltage_Current_Buffer[i]) end')



m=m+1;
j=j+1;
  
pause(0.1);

%if j>1
 %   break
%end

%end
%{
disp('the relative timestamp for the first reading in the buffer:')
disp(writeread(KLYSM2450,'print(Voltage_Current_Buffer.relativetimestamps[1])'));
disp('the relative timestamp for the reading 1 through 10 in the buffer.')
disp(writeread(KLYSM2450,'printbuffer(1, 10, Voltage_Current_Buffer.relativetimestamps)'))
%disp('all The values of Voltage are:')
%disp(voltage)
%disp('all The value of Current are:')
%}

disp(current)
%finalcurrent=mean(current);
%disp(' The averaged value of Current is:')
%disp(finalcurrent)

%print(testData.relativetimestamps[1])
%printbuffer(1, 3, testData.relativetimestamps)

writeline(KLYSM2450,'smu.source.output = smu.OFF')
writeline(KLYSM2450,'trigger.model.abort()')
writeline(KLYSM2450,'reset()');

end
