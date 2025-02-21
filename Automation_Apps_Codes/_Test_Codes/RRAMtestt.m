function I = RRAM(Tf,a)


% The parameters for configuration of Temperature Controller Lake Shore Model 336.
LSTC336=serialport("COM3",57600);
LSTC336.FlowControl="none";
LSTC336.Parity="odd";
LSTC336.StopBits=1;
LSTC336.DataBits=7;

% Name of the Device, check if conncetion is stablished.
disp('                            ')
disp('The model of the temperature controller device is:');
disp(writeread(LSTC336,'*IDN?'))

% Set Initial Parameters for the device: RANGE,PID,RAMP,SETP
writeline(LSTC336, strcat('RANGE 1,', string(a))) 
%writeline(LSTC336,'RANGE 1,0')
pause(0.1)
writeline(LSTC336,'PID 1,100,50,0')
pause(0.1)
writeline(LSTC336,'RAMP 1,1,60')
pause(0.1)
writeline(LSTC336, strcat('SETP 1,', string(Tf)))  %writeline(LSTC336,'SETP 1,260)')
pause(0.1)
      

% Set Initial Variables for the while loops to receive and save data.
n=1;
i=1;
outputtemptest=0;
realtemptest=0;
outputtemp= zeros(n,1);
realtemp=zeros(i,1);

% The while loops: 1. The OUTPUT Temperature, 2. The INPUT Temperature
while ((outputtemptest<Tf) || (outputtemptest>Tf)) || ((realtemptest<Tf) || (realtemptest>Tf))% fix later, needs cooling

        outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
        outputtemp(n,1)=str2double(writeread(LSTC336,'SETP?1'));
        realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
        realtemp(i,1)=str2double(writeread(LSTC336,'KRDG?1'));
        disp('  device temperature in the OUTPUT 1         real temperature in the INPUT 1');
        Y0=[num2str(outputtemptest),'    ',num2str(realtemptest)];
        disp(Y0)
        pause(1);
        n=n+1;
        i=i+1;

        
end


% Display the obtained values for both while loops
Y1=[num2str(outputtemp),num2str(realtemptest)];
disp('  device temperature in the OUTPUT 1         real temperature in the INPUT 1');
disp(Y1)
%Plotting the 
plot (n ,realtemp,'ro');







KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");

disp ('The model of the SourceMeter device is:');
disp(writeread(KLYSM2450,'*IDN?'))


KYST2987=visadev("USB0::0x0957::0x9418::MY54321288::0::INSTR");

disp ('The model of the Electrometer device is:');
disp(writeread(KYST2987,'*IDN?'))
I=0;
end

