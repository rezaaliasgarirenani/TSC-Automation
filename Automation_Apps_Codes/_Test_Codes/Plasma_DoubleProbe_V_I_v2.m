% ����� � �������� ����������� Rigol DM3068 (#1),
% ������� ������� � ����� ��������� ����������� ����������,
% ��������� ��������� ��������� � ����� ���� (�������������� �����
% ���������).
RigolDM3068_1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0C94::DM3O214400843::0::INSTR', 'Tag', '');
if isempty(RigolDM3068_1)
    RigolDM3068_1 = visa('NI', 'USB0::0x1AB1::0x0C94::DM3O214400843::0::INSTR');
    fprintf('���������� Rigol DM3068 (#1) ������� ���������������.\n');
else
    fclose(RigolDM3068_1);
    fprintf('���������� Rigol DM3068 (#1) ��� ��������������� � ����� � ������.\n');
    RigolDM3068_1 = RigolDM3068_1(1);
end
fopen(RigolDM3068_1);
fprintf('���������� Rigol DM3068 (#1) ����������� � ����� ��������� ����������� ���������� (DCV), ����������, ���������...\n');
fprintf(RigolDM3068_1,':FUNCtion:VOLTage:DC');
fprintf('���������� Rigol DM3068 (#1), ���������� ����� ���������: %s.\n\n',strtrim(query(RigolDM3068_1,':FUNCtion?')));
fprintf('���������� Rigol DM3068 (#1), ���������� �������� ��������� ����� ���������: %s.\n\n',strtrim(query(RigolDM3068_1,':FUNCtion?')));
fprintf(RigolDM3068_1, ':MEASure AUTO');



% ����� � �������� ����������� Rigol DM3068 (#2),
% ������� ������� � ����� ��������� ����������� ����,
% ��������� ��������� ��������� � ����� ���� (�������������� �����
% ���������).
RigolDM3068_2 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0C94::DM3O214400866::0::INSTR', 'Tag', '');
if isempty(RigolDM3068_2)
    RigolDM3068_2 = visa('NI', 'USB0::0x1AB1::0x0C94::DM3O214400866::0::INSTR');
    fprintf('���������� Rigol DM3068 (#2) ������� ���������������.\n')
else
    fclose(RigolDM3068_2);
    fprintf('���������� Rigol DM3068 (#2) ��� ��������������� � ����� � ������.\n')
    RigolDM3068_2 = RigolDM3068_2(1);
end
fopen(RigolDM3068_2);
fprintf('���������� Rigol DM3068 (#2) ����������� � ����� ��������� ����������� ���� (DCI), ����������, ���������...\n');
fprintf(RigolDM3068_2,':FUNCtion:CURRent:DC');
fprintf('���������� Rigol DM3068 (#2), ���������� ����� ���������: %s.\n',strtrim(query(RigolDM3068_2,':FUNCtion?')));
fprintf(RigolDM3068_2, ':MEASure AUTO');




% ����� � �������� ����������� Rigol DP821A
RigolDP821A = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0E11::DP8E195200156::0::INSTR', 'Tag', '');
if isempty(RigolDP821A)
    RigolDP821A = visa('NI', 'USB0::0x1AB1::0x0E11::DP8E195200156::0::INSTR');
    fprintf('���������� Rigol DP821A ������� ���������������.\n')
else
    fclose(RigolDP821A);
    fprintf('���������� Rigol DP821A ��� ��������������� � ����� � ������.\n')
    RigolDP821A = RigolDP821A(1);
end
fopen(RigolDP821A);
% ��������� ������� ���������� (���������� ���� ������������� �� ��������������, ������ �� ����������
% ����, ����� ������� �������� ���������� � ���� �� 0)
fprintf(RigolDP821A,':OUTP CH1,OFF');
fprintf(RigolDP821A,':OUTP CH2,OFF');
fprintf(RigolDP821A,':OUTP CH3,OFF');

fprintf(RigolDP821A,':INST CH1');
fprintf(RigolDP821A,':VOLT 0');
fprintf(RigolDP821A,':VOLT:PROT 41');
fprintf(RigolDP821A,':VOLT:PROT:STAT ON');
fprintf(RigolDP821A,':CURR 0.001');
fprintf(RigolDP821A,':CURR:PROT 0.002');
fprintf(RigolDP821A,':CURR:PROT:STAT ON');

fprintf(RigolDP821A,':VOLT 0.00');
fprintf(RigolDP821A,':OUTP CH1,ON');


VoltageArraySetMinus = -40:0.5:0;
VoltageArraySetPlus = 0:0.5:40;
VoltageArraySet = cat(2,VoltageArraySetMinus,VoltageArraySetPlus);
[VoltageArrayMeasDP,CurrentArrayMeasDP] = deal(NaN(1,(length(VoltageArraySetMinus)+length(VoltageArraySetPlus))));


fprintf('\n====================\n');
fprintf('��������� ������������� �����.\n');
% ��������� � ������������� ��������� ���������� (-40�..0) � ����� 0.5 �
for i=1:length(VoltageArraySetMinus)
    fprintf(RigolDP821A,':VOLT %f',abs(VoltageArraySet(i)));
    if i==1
        fprintf('����� 20�. ������������ ���������� -40�... ');
        pause(20);
        fprintf('���������� ���������\n');
    end
    fprintf('����������� ����������: %.1f �\n',VoltageArraySet(i));
    pause(1);
    
    VoltageArrayMeasDP(1,i) = (-1)*(str2double(strtrim(query(RigolDM3068_1, ':MEASure:VOLTage:DC?'))));
    CurrentArrayMeasDP(1,i) = (-1)*(str2double(strtrim(query(RigolDM3068_2, ':MEASure:CURRent:DC?'))));
    clf; plot(VoltageArrayMeasDP(1:i),CurrentArrayMeasDP(1:i),'-o','MarkerSize',3); grid on; drawnow;
end
close

fprintf('��������� ������������� ����� ���������. ����������� ���������� �������� ����� � ������� ENTER ��� ����������� ��������� � ������������� ���������...\n');

pause

% ��������� � ������������� ��������� ���������� (0..+40�) � ����� 0.5 �
fprintf('��������� ������������� �����.\n');
for i=(length(VoltageArraySetMinus)+1):(length(VoltageArraySetMinus)+length(VoltageArraySetPlus))
    fprintf(RigolDP821A,':VOLT %f',abs(VoltageArraySet(i)));
    if i==(length(VoltageArraySetMinus)+1)
        fprintf('����� 5�.\n');
        pause(5);
        fprintf('���������� ���������.\n');
    end
    fprintf('����������� ����������: %.1f �\n',VoltageArraySet(i));
    pause(1);
    VoltageArrayMeasDP(1,i) = str2double(strtrim(query(RigolDM3068_1, ':MEASure:VOLTage:DC?')));
    CurrentArrayMeasDP(1,i) = str2double(strtrim(query(RigolDM3068_2, ':MEASure:CURRent:DC?')));
    clf; plot(VoltageArrayMeasDP(1:i),CurrentArrayMeasDP(1:i),'-o','MarkerSize',3); grid on; drawnow;
end
close

path = strcat('PhysMech_Lab02_DP_',string(datetime('now','Format','yyyyMMdd_HHmmss')),'.txt');
writematrix([VoltageArraySet;VoltageArrayMeasDP;CurrentArrayMeasDP]',path,'Delimiter','tab');

fprintf(RigolDP821A,':VOLT 0.00');
fprintf(RigolDP821A,':OUTP CH1,OFF');
fprintf('��������� ���������. ���������� ���������.\n���� � ������� ��������: %s\n', path);

figure
plot(VoltageArrayMeasDP,CurrentArrayMeasDP*1e6,'-o',...
    'MarkerSize',3);
grid on
title('��� �������� �����')
xlabel('V\_Meas (V)')
ylabel('I\_Meas (uA)')

fclose(RigolDM3068_1);
fclose(RigolDM3068_2);
fclose(RigolDP821A);