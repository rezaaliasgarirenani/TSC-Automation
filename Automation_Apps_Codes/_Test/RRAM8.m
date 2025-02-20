function I = RRAM8(T0,Tf,tp,Vp,V0,Vf)
I=true;
format longE

% The parameters for configuration of Temperature Controller Lake Shore Model 336.
LSTC336=serialport("COM3",57600);
LSTC336.FlowControl="none";
LSTC336.Parity="odd";
LSTC336.StopBits=1;
LSTC336.DataBits=7;

% Name of the Device, check if conncetion is stablished.
disp('                            ')
disp('The model of the temperature controller device is:')
disp(writeread(LSTC336,'*IDN?'))
%pause(0.1)

% KEITHLEY configuration Parameters, check if connection is stablished
KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");
disp ('The model of the SourceMeter device is:')
disp(writeread(KLYSM2450,'*IDN?'))
%pause(0.1)

%Reset devices:
%writeline(KLYSM2450,'reset()');
writeline(KLYSM2450,'smu.reset()');

%Voltage is the SOURCE function, Current is measurement: 
writeline(KLYSM2450,'smu.measure.func = smu.FUNC_DC_CURRENT')
writeline(KLYSM2450,'smu.source.func = smu.FUNC_DC_VOLTAGE')
%Settings for KEITHLEY that need to be set before start of measurements
%Measurement Settings for KEITHLEY:
writeline(KLYSM2450,'smu.measure.terminals = smu.TERMINALS_REAR')
writeline(KLYSM2450,'smu.measure.sense = smu.SENSE_2WIRE')
writeline(KLYSM2450,'smu.measure.autorange = smu.ON')

nplc=1;
writeline(KLYSM2450, strcat('smu.measure.nplc=', string(nplc))) 
writeline(KLYSM2450,'frequency=localnode.linefreq');
freq=str2double(writeread(KLYSM2450,'print(frequency)'));
disp('the value of frequency, nplc and measurement window respectively are:')
mw=nplc/freq;
disp([freq nplc mw])
%writeline(KLYSM2450, strcat('smu.measure.count = ',string(n)))

% Source Settings for KEITHLEY:
writeline(KLYSM2450,'smu.source.highc = smu.OFF')
writeline(KLYSM2450,'smu.source.autorange = smu.ON')
writeline(KLYSM2450,'smu.source.readback = smu.ON')
writeline(KLYSM2450,'smu.source.output = smu.ON')
%writeline(KLYSM2450,'smu.source.offmode = smu.OFFMODE_NORMAL')
writeline(KLYSM2450,'smu.source.ilimit.level = 0.1')

Ra=3; % Heating is high
% Set Initial Parameters for the device: RANGE,PID,RAMP,SETP
writeline(LSTC336, strcat('RANGE 1,', string(Ra))) 
%writeline(LSTC336,'RANGE 1,0')
pause(0.1)
writeline(LSTC336,'PID 1,100,50,20')
pause(0.1)


%Stabilization Phase:
%Set INITIAL Temperature
disp('                            ')
disp('The process of stabilizing initial temperature phase has begun:')
writeline(LSTC336,'RAMP 1,0,0')
pause(0.1)
writeline(LSTC336, strcat('SETP 1,', string(T0)))  %initial temp
writeline(KLYSM2450, strcat('smu.source.level = ',string(V0)))% Initial Voltage
% Check the initial condition for more than onepoint, compare all values
% to T0 and make sure it falls within the range, waits until temp is stable
acc=0.2;
lowerBound=T0-acc;
upperBound=T0+acc;
k=1;
l1=1;
l2=1;

%Initilaize the plots:
figure(1)
ax1=subplot(2,2,1);
ax2=subplot(2,2,2);
ax3=subplot(2,2,3);
ax4=subplot(2,2,4);
%Initilaizing the initial vectors
initialtemp =zeros(k,1);
initialvolt=zeros(l1,1);
initialcurrent=zeros(l2,1);


%process of stabilizing temperature:
%Setup buffer readings to take in values of current and voltage during the
writeline(KLYSM2450,'Voltage_Current_Initial_Buffer = buffer.make(10),buffer.STYLE_WRITABLE_FULL')
while true
   
    writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Initial_Buffer)')
    %writeline(KLYSM2450,'display.activebuffer = Voltage_Current_Initial_Buffer')
    
    newTemp=str2double(writeread(LSTC336,'KRDG?1'));
    initialvoltagetest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Initial_Buffer.sourcevalues)'));
    initialcurrenttest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Initial_Buffer.readings)'));
        
        
    if isempty(newTemp)
        break;
    end

    disp('Temperature has not yet stabilized, The temperature is: ')
    disp(newTemp);
    disp('Temperature has not yet stabilized, The voltage  is: ')
    disp(initialvoltagetest);
    disp('Temperature has not yet stabilized, The current  is: ')
    disp(initialcurrenttest);

    %initialtemp=[initialtemp, newElement];
    initialtemp(k,1)=str2double(writeread(LSTC336,'KRDG?1'));
    initialvolt(l1,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Initial_Buffer.sourcevalues)'));
    initialcurrent(l2,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Initial_Buffer.readings)'));

    plot(ax1,initialtemp,initialcurrent)
    xlabel(ax1,'Initial Temperature ; [T]=[Kelvin]')
    ylabel(ax1,'Initial Current linear ; [I]=[Amps]')
    semilogy(ax2,initialtemp,abs(initialcurrent))
    xlabel(ax2,'Initial Temperature ; [T]=[Kelvin]')
    ylabel(ax2,'Initial Current Logarithmic ; [I]=[Amps]')
    
    if length(initialtemp)>=10
        last10Elements1=initialtemp(end-9:end);
        last10Elements2=initialvolt(end-9:end);
        last10Elements3=initialcurrent(end-9:end);

        rangeCheck=all(last10Elements1>=lowerBound & last10Elements1<=upperBound);
        if rangeCheck
            break;
        end
    end

    writeline(KLYSM2450,'Voltage_Current_Initial_Buffer.clear()')

    k=k+1;
    l1=l1+1;
    l2=l2+1;
    pause(2)
end

disp ('The last ten elements of the initial temperature within the range are:')
disp (last10Elements1)
disp ('The last ten elements of the initial voltage within the range are:')
disp (last10Elements2)
disp ('The last ten elements of the initial current within the range are:')
disp (last10Elements3)



%Pulse Phase:
disp('                            ')
disp ('The Temperature has stabilized and the Pulse phase will now start:')
writeline(KLYSM2450,'Pulse_Buffer = buffer.make(10),buffer.STYLE_WRITABLE_FULL')
writeline(KLYSM2450, strcat('smu.source.level = ',string(Vp))) %Sets the Pulse voltage
writeline(KLYSM2450,'smu.measure.read(Pulse_Buffer)')

outputtemppulse=str2double(writeread(LSTC336,'SETP?1'));
realtemppulse=str2double(writeread(LSTC336,'KRDG?1'));
voltagepulse=str2double(writeread(KLYSM2450,'printbuffer(1,1,Pulse_Buffer.sourcevalues)'));
currentpulse=str2double(writeread(KLYSM2450,'printbuffer(1,1,Pulse_Buffer.readings)'));
disp('      device temperature at the moment of pulse:   real temperature at the moment of pulse:');
Y0=['              ',num2str(outputtemppulse),'                                ',num2str(realtemppulse)];
disp(Y0)
disp('             VOLTAGE at the moment of pulse:      CURRENT at the moment of pulse:');
Y1=['              ',num2str(voltagepulse),'                            ',num2str(currentpulse)];
writeline(KLYSM2450,'Pulse_Buffer.clear()')
disp(Y1);
pause(tp)



% Measurment Phase:
disp('                            ')
disp ('The Temperature has stabilized and the measurements phase will now start:')


%PROCESS for T0 to Tf, Setting the final Voltage, Buffers and readin values
writeline(LSTC336,'RAMP 1,1,10')
pause(0.1)
writeline(LSTC336, strcat('SETP 1,', string(Tf)))  %writeline(LSTC336,'SETP 1,260)')
%pause(0.1)
writeline(KLYSM2450, strcat('smu.source.level = ',string(Vf))) %Sets the final voltage  


% Set Initial Variables for the while loops to receive and save data for LSTC336
n=1;
i=1;
outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
outputtemp=zeros(n,1);
realtemp=zeros(i,1);
% Set Initial Variables for the while loops and initial plotting
m=1;
j=1;
i1=1;
currentvector=zeros(i1,1);
voltage=zeros(m,1);
current=zeros(j,1);

stepp=0.3;
acc2=0.05;
lasttempforheating=T0;
lasttempforcooling=T0;
writeline(KLYSM2450,'smu.measure.count = 10')

% The while loops: 1. The Heating, 2. The Cooling
if outputtemptest<Tf % Means it's heating
    disp ('The regime is heating')
    disp('                            ')

%make buffer and print readings to receive and save data for KETHLEY2450:
writeline(KLYSM2450,'Voltage_Current_Buffer = buffer.make(10),buffer.STYLE_WRITABLE_FULL')

 while (realtemptest<(Tf+stepp)) % Heating
       
        %writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
        %writeline(KLYSM2450,'display.activebuffer = Voltage_Current_Buffer')

        outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
        realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
        %voltagetest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
        %currenttest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
        
       
  
        if abs((realtemptest-lasttempforheating))<(acc2)
        writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
        outputtemp(n,1)=str2double(writeread(LSTC336,'SETP?1'));
        realtemp(i,1)=str2double(writeread(LSTC336,'KRDG?1'));
        for i1=1:10    
        currentvector(i1,1)=str2double(writeread(KLYSM2450,'for i = 1, Voltage_Current_Initial_Buffer.n do print(Voltage_Current_Initial_Buffer[i]) end'));
        end
        current(j,1)=mean(currentvector);
        voltage(m,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));

        %current(j,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
  
        plot(ax3,realtemp,current)
        xlabel(ax3,'Temperature ; [T]=[Kelvin]')
        ylabel(ax3,'Current linear ; [I]=[Amps]')

        semilogy(ax4,realtemp,abs(current))
        xlabel(ax4,'Temperature ; [T]=[Kelvin]')
        ylabel(ax4,'Current Logarithmic ; [I]=[Amps]')

        writeline(KLYSM2450,'Voltage_Current_Buffer.clear()')
        %lasttempforheating=realtemp(i,1);
        lasttempforheating=lasttempforheating+stepp;

        n=n+1;
        i=i+1;
        m=m+1;
        j=j+1;
        
        end

        %writeline(KLYSM2450,'Voltage_Current_Buffer.clear()')

        disp('      Device Temperature at the moment:           Real Temperature at the moment:');
        Y4=['              ',num2str(outputtemptest),'                             ',num2str(realtemptest)];
        disp(Y4)
        %disp('             Voltage at the moment:                Current at the moment:');
        %Y5=['              ',num2str(voltagetest),'                           ',num2str(currenttest)];
        %disp(Y5);
        pause(0.3);
       
  if (realtemptest>(Tf+stepp))
     break
  end
    

 end
 
elseif outputtemptest>Tf %means it's cooling
    disp ('The regime is cooling')
    disp('                            ')

    while (realtemptest>(Tf-stepp)) %cooling

        writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
        %writeline(KLYSM2450,'display.activebuffer = Voltage_Current_Buffer')

        outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
        realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
        %voltagetest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
        %currenttest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
        
       
  
        if abs((realtemptest-lasttempforcooling))<(acc2)
        outputtemp(n,1)=str2double(writeread(LSTC336,'SETP?1'));
        realtemp(i,1)=str2double(writeread(LSTC336,'KRDG?1'));
        voltage(m,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
        for i1=1:10     
        currentvector(i1,1)=str2double(writeread(KLYSM2450,'for i = 1, Voltage_Current_Buffer.n do print(Voltage_Current_Buffer[i]) end'));
        end
        current(j,1)=mean(currentvector);
        
        %current(j,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
  
        plot(ax3,realtemp,current)
        xlabel(ax3,'Temperature ; [T]=[Kelvin]')
        ylabel(ax3,'Current linear ; [I]=[Amps]')

        semilogy(ax4,realtemp,abs(current))
        xlabel(ax4,'Temperature ; [T]=[Kelvin]')
        ylabel(ax4,'Current Logarithmic ; [I]=[Amps]')

        writeline(KLYSM2450,'Voltage_Current_Buffer.clear()')
        lasttempforcooling=lasttempforcooling-stepp;
        
        n=n+1;
        i=i+1;
        m=m+1;
        j=j+1;
        
        end

        writeline(KLYSM2450,'Voltage_Current_Buffer.clear()')

        disp('      Device Temperature at the moment:          Real Temperature at the moment:');
        Y4=['              ',num2str(outputtemptest),'                           ',num2str(realtemptest)];
        disp(Y4)
        %disp('             Voltage at the moment:              Current at the moment:');
        %Y5=['              ',num2str(voltagetest),'                         ',num2str(currenttest)];
        %disp(Y5);
        pause(0.3);
       
   if (realtemptest<(Tf-stepp))
     break
   end 
   
   end 

     
else 
    disp ('The final temperature and Set point temperature are equal!')

 end
    
 

% Display the obtained values for both while loops
disp('                            ')
disp('            Device Temp:              Real Temp:');
disp([outputtemp realtemp]);
disp('                            ')
disp('              Voltage:            Current:');
disp([voltage current]);


writeline(KLYSM2450,'smu.source.output = smu.OFF') %Put outpot off in KEITHLEY
% writeline(LSTC336, strcat('RANGE 1,', string(0))) %Turn off, Heating,shoudld I?

end

