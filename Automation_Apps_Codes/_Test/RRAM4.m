function I = RRAM4 (T0,Tf,V0,Vf)
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
pause(0.1)

% KEITHLEY configuration Parameters
KLYSM2450=visadev("USB0::0x05E6::0x2450::04429200::0::INSTR");
disp ('The model of the SourceMeter device is:')
disp(writeread(KLYSM2450,'*IDN?'))
pause(0.1)


%Voltage is the SOURCE function, Current is measurement: 
writeline(KLYSM2450,'smu.measure.func = smu.FUNC_DC_CURRENT')
writeline(KLYSM2450,'smu.source.func = smu.FUNC_DC_VOLTAGE')
%Settings for KEITHLEY that need to be set before start of measurements
%Measurement Settings for KEITHLEY:
writeline(KLYSM2450,'smu.measure.terminals = smu.TERMINALS_REAR')
writeline(KLYSM2450,'smu.measure.sense = smu.SENSE_2WIRE')
writeline(KLYSM2450,'smu.measure.autorange = smu.ON')
nplc=5;
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


%Set INITIAL Temperature
disp('The process of stabilizing initial temperature has begun:')
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

figure(1)
ax1=subplot(2,2,1);
ax2=subplot(2,2,2);

%initialtemp=[];
initialtemp =zeros(k,1);
initialvolt=zeros(l1,1);
initialcurrent=zeros(l2,1);

%Setup buffer readings to take in values of current and voltage during the
%process of stabilizing temperature
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



disp('                            ')
disp ('The Temperature has stabilized and the measurements will now start:')





%PROCESS for T0 to Tf, Setting the final Voltage, Buffers and readin values
writeline(LSTC336,'RAMP 1,1,10')
pause(0.1)
writeline(LSTC336, strcat('SETP 1,', string(Tf)))  %writeline(LSTC336,'SETP 1,260)')
pause(0.1)
writeline(KLYSM2450, strcat('smu.source.level = ',string(Vf))) %Sets the final voltage  


% Set Initial Variables for the while loops to receive and save data for LSTC336
n=1;
i=1;
i1=1;
outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
outputtemp=zeros(n,1);
realtemp=zeros(i,1);
temperature=zeros(i1,1);
% Set Initial Variables for the while loops and initial plotting
m=1;
j=1;
j1=1;

voltage=zeros(m,1);
current=zeros(j,1);
currenttobeaveraged=zeros(j1,1);

%Initilaize the plots:

ax3=subplot(2,2,3);
ax4=subplot(2,2,4);

% The while loops: 1. The Heating, 2. The Cooling
if outputtemptest<Tf % Means it's heating
    disp ('The regime is heating')
    disp('                            ')

%make buffer and print readings to receive and save data for KETHLEY2450:
writeline(KLYSM2450,'Voltage_Current_Buffer = buffer.make(10),buffer.STYLE_WRITABLE_FULL')


 while (realtemptest<Tf) % Heating
       
        writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
        %writeline(KLYSM2450,'display.activebuffer = Voltage_Current_Buffer')

        outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
        realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
        voltagetest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
        currenttest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
        realtemp(i,1)=str2double(writeread(LSTC336,'KRDG?1'));
        outputtemp(n,1)=str2double(writeread(LSTC336,'SETP?1'));
        
        while length(realtemp)<2
        realtemp(i,1)=str2double(writeread(LSTC336,'KRDG?1'));
        outputtemp(n,1)=str2double(writeread(LSTC336,'SETP?1'));
        i=i+1;
        n=n+1;
        end
        
        %if length(realtemp)>1
        lastTwoValues=realtemp(end-1:end);
        acc2=0.3;
        
        
        %voltage(m,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));     
        %current(j,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
        
       
        if abs(diff(lastTwoValues))>=acc2
%{
            writeline(KLYSM2450,'trigger.model.load("SimpleLoop",10,0.1,Voltage_Current_Buffer2)')
            writeline(KLYSM2450,'trigger.model.initiate()') 
            writeline(KLYSM2450,'waitcomplete()')
%}
            writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
            for j1=1:10
            currenttobeaveraged(j1,1)=str2double(writeread(KLYSM2450,'for i = 1, Voltage_Current_Buffer.n do print(Voltage_Current_Buffer[i]) end'));
            end

            current(j,1)=mean(currenttobeaveraged);
            disp(current)
            voltage(m,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));  
            temperature(i1,1)=str2double(writeread(LSTC336,'KRDG?1'));
            writeline(KLYSM2450,'Voltage_Current_Buffer.clear()')



         plot(ax3,temperature,current)
         xlabel(ax3,'Temperature ; [T]=[Kelvin]')
         ylabel(ax3,'Current linear ; [I]=[Amps]')

         semilogy(ax4,temperature,abs(current))
         xlabel(ax4,'Temperature ; [T]=[Kelvin]')
         ylabel(ax4,'Current Logarithmic ; [I]=[Amps]')
          
        
        m=m+1;
        j=j+1;
        i1=i1+1;

        end
       



         disp('      device temperature:                 real temperature:');
         Y0=['              ',num2str(outputtemptest),'                                ',num2str(realtemptest)];
         disp(Y0)
         disp('             VOLTAGE AT THE MOMENT:                   CURRENT AT THE MOMENT:');
         Y1=['              ',num2str(voltagetest),'                            ',num2str(currenttest)];
         disp(Y1);
         

         writeline(KLYSM2450,'Voltage_Current_Buffer.clear()')

       

            

        n=n+1;
        i=i+1;
        pause(0.5);
       
  if (realtemptest>Tf)
     break
  end
    
 end

elseif outputtemptest>Tf %means it's cooling
    disp ('The regime is cooling')
    disp('                            ')
    while (realtemptest>Tf) %cooling

        %make buffer and print readings to receive and save data for KETHLEY2450:
        writeline(KLYSM2450,'Voltage_Current_Buffer = buffer.make(10),buffer.STYLE_WRITABLE_FULL')
        writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer)')
        writeline(KLYSM2450,'display.activebuffer = Voltage_Current_Buffer')

        outputtemptest=str2double(writeread(LSTC336,'SETP?1'));
        outputtemp(n,1)=str2double(writeread(LSTC336,'SETP?1'));
        realtemptest=str2double(writeread(LSTC336,'KRDG?1'));
        realtemp(i,1)=str2double(writeread(LSTC336,'KRDG?1'));

        voltagetest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
        voltage(m,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.sourcevalues)'));
        currenttest=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
        current(j,1)=str2double(writeread(KLYSM2450,'printbuffer(1,1,Voltage_Current_Buffer.readings)'));
        
        disp('      device temperature:                 real temperature:');
        Y0=['              ',num2str(outputtemptest),'                                ',num2str(realtemptest)];
        disp(Y0)
        disp('             VOLTAGE:                           CURRENT:');
        Y1=['              ',num2str(voltagetest),'                            ',num2str(currenttest)];
        disp(Y1);

        plot(ax3,realtemp,current)
        xlabel(ax3,'Temperature ; [T]=[Kelvin]')
        ylabel(ax3,'Current linear ; [I]=[Amps]')

        semilogy(ax4,realtemp,abs(current))
        xlabel(ax4,'Temperature ; [T]=[Kelvin]')
        ylabel(ax4,'Current Logarithmic ; [I]=[Amps]')

        writeline(KLYSM2450,'Voltage_Current_Buffer.clear()')  

        n=n+1;
        i=i+1;
        m=m+1;
        j=j+1;

        pause(2);

         if (realtemptest<Tf)
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

