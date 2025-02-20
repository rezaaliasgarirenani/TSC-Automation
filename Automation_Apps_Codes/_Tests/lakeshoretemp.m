function I=lakeshoretemp(Ra)
I=true;
LSTC336=serialport("COM3",57600);

LSTC336.FlowControl="none";
LSTC336.Parity="odd";
LSTC336.StopBits=1;
LSTC336.DataBits=7;

% writeline(LSTC336,'*IDN?');
%disp(readline(LSTC336));

disp ('The model of the temperature controller device is:');
disp(writeread(LSTC336,'*IDN?'))

writeline(LSTC336, strcat('RANGE 1,', string(Ra))) 

x=0:0.1:(360/180)*pi;
y=sin(x);
plot(y);