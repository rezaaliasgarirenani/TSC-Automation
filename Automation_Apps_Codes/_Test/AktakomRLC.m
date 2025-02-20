Aktakom=visadev("USB0::0x0471::0x2827::QF40900001::0::INSTR");

%Common
writeline(Aktakom,'*RST')
writeline(Aktakom,'FUNCtion:IMPedance CPG')

%{
writeread(Aktakom,'*IDN?')
writeread(Aktakom,'*STB?')
%Set Level parameter
writeline(Aktakom,'VOLT 100mV')
disp(writeread(Aktakom,'VOLTage?'))

%Set Freq Parameter
writeline(Aktakom,'FREQ 20Hz')
disp(writeread(Aktakom,'FREQ?'))

%Set internal Bias State
writeline(Aktakom,'BIAS:STATe 1')
disp(writeread(Aktakom,'BIAS:STATe?'))
%}

clear