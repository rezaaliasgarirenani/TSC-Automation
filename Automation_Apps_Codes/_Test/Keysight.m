KYST2987=visadev("USB0::0x0957::0x9418::MY54321288::0::INSTR");
a=3;
format longE
disp ('The model of the Electrometer device is:');

disp(writeread(KYST2987,'*IDN?'))

writeline(KYST2987,'*RST')


writeline(KYST2987,':SYSTem:BEEPer:STAT 1')
writeread(KYST2987,':SYSTem:BEEPer:STATe?')
writeline(KYST2987,':SYSTem:BEEPer 1000,0.5')

%disp(writeread(KYST2987,':SYSTem:HUMidity?'))

%{
writeline(KYST2987,':SYST:COMM:ENAB 1,USB')
%writeline(KYST2987,':SENS:FUNC "VOLT"')
writeline(KYST2987,':SENS:CURR:RANG:AUTO ON')
writeline(KYST2987,':SENS:CURR:LIM:AUTO ON')
writeline(KYST2987,':SENS:CURR:NPLC:AUTO OFF')
writeline(KYST2987,':SOUR:FUNC:MODE VOLT')
writeline(KYST2987,':SOUR:VOLT:RANG:AUTO ON')

%writeline(KYST2987,':SENS:CURR:NPLC 0.1')
writeline(KYST2987,':SYST:LFR:DET:AUTO')
writeline(KYST2987, sprintf(':SENS:CURR:NPLC %f', (a)))
disp(writeread(KYST2987, ':SENSE:CURR:NPLC?'))
b=str2double(writeread(KYST2987, ':SYST:LFR?'));



writeline(KYST2987,':OUTP ON')
writeline(KYST2987,':INP ON')

m=2;


V=0;
writeline(KYST2987, sprintf('SOUR:VOLT %f',(V)))
%disp(writeread(KYST2987, 'MEASure:CURRent:DC?'))
%disp(writeread(KYST2987, 'MEAS:func?'))

writeline(KYST2987, 'trig:sour aint')
writeline(KYST2987, 'trig:acq:del 2e-4')
%writeline(KYST2987, 'trig:coun 6')
writeline(KYST2987, sprintf('trig:coun %f',(m)))

for i=1:20
writeline(KYST2987, 'INIT:acq')
c=writeread(KYST2987,'FETC:arr:CURR?')
d=split(c,',')
e=str2double(d)
f=mean(e)
g=mean(str2double(split(writeread(KYST2987,'FETC:arr:CURR?'),',')))
h=writeread(KYST2987,'FETC:arr:VOLT?')
disp(writeread(KYST2987, 'MEAS:VOLT?'))
%writeline(KYST2987, ':TRAC:CLE')
end
pause(1)
writeline(KYST2987, 'INIT:acq')
k=writeread(KYST2987,'FETC:arr:CURR?')
%writeline(KYST2987, 'trig:tim 4e-3')




%writeline(KYST2987, 'INIT')
%disp(writeread(KYST2987, 'MEAS:CURR?'))
%disp(writeread(KYST2987, 'MEAS:VOLT?'))
%disp(writeread(KYST2987,'FETC:CURR?'))
%disp(writeread(KYST2987, 'TRAC:DATA? CURR'))
%disp(writeread(KYST2987,'FETC:VOLT?'))
%writeline(KYST2987,'*RST')
%}

clear