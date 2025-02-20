% function S = setSETP(temp)
%     S = strcat('SETP 1,', string(temp))
% end

function I = RRAM(a)

LSTC336=serialport("COM3",57600);
LSTC336.FlowControl="none";
LSTC336.Parity="odd";
LSTC336.StopBits=1;
LSTC336.DataBits=7;

disp('                            ')
disp('The model of the temperature controller device is:');
disp(writeread(LSTC336,'*IDN?'))

writeline(LSTC336,'RANGE 1,3')
pause(0.1)
writeline(LSTC336,'PID 1,100,50,0')
pause(0.1)
writeline(LSTC336,'RAMP 1,1,60')
pause(0.1)
writeline(LSTC336,'SETP 1,260')
pause(0.1)


% writeline(LSTC336, setSETP(a))
writeline(LSTC336, strcat('SETP 1,', string(a)))


n=1;
i=1;
outputtemptest=0;
realtemptest=0;
outputtemp= zeros(n,1);
realtemp=zeros(i,1);

while (outputtemptest<260) || (outputtemptest>260)

while (outputtemptest~=260)

        outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
        outputtemp(n,1)=str2double(writeread(LSTC336,'SETP?1'));
        pause(1);
        n=n+1;
end


while i<n                        %(realtemptest<250) || (realtemptest>250) fix later, needs cooling

        realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
        realtemp(i,1)=str2double(writeread(LSTC336,'KRDG?1'));
        pause(1);
        i=i+1;
        
end




disp('The values of the supposed temperature in the OUTPUT 1 are:');
disp(outputtemp)
plot(n*ones(size(n)),outputtemp*ones(size(n)));

disp('The values of the real temperature in the INPUT 1  are:');
disp(realtemp)




KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");

disp ('The model of the SourceMeter device is:');
disp(writeread(KLYSM2450,'*IDN?'))


KYST2987=visadev("USB0::0x0957::0x9418::MY54321288::0::INSTR");

disp ('The model of the Electrometer device is:');
disp(writeread(KYST2987,'*IDN?'))
end