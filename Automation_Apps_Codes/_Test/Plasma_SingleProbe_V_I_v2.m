ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');

% Поиск и создание инструмента Rigol DM3068 (#1),
% перевод прибора в режим измерения НАПРЯЖЕНИЯ,
% утсановка диапаразона измерений в режим АВТО (автоматический выбор
% диапазона).
RigolDM3068_1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0C94::DM3O214400843::0::INSTR', 'Tag', '');
if isempty(RigolDM3068_1)
    RigolDM3068_1 = visa('NI', 'USB0::0x1AB1::0x0C94::DM3O214400843::0::INSTR');
    fprintf('Инструмент Rigol DM3068 (#1) успешно инициализирован.\n');
else
    fclose(RigolDM3068_1);
    fprintf('Инструмент Rigol DM3068 (#1) уже инициализирован и готов к работе.\n');
    RigolDM3068_1 = RigolDM3068_1(1);
end
fopen(RigolDM3068_1);
fprintf('Инструмент Rigol DM3068 (#1) переводится в режим измерения ПОСТОЯННОГО НАПРЯЖЕНИЯ (DCV), пожалуйств, подождите...\n');
fprintf(RigolDM3068_1,':FUNCtion:VOLTage:DC');
fprintf('Инструмент Rigol DM3068 (#1), установлен режим измерения: %s.\n\n',strtrim(query(RigolDM3068_1,':FUNCtion?')));
fprintf(RigolDM3068_1, ':MEASure AUTO');



% Поиск и создание инструмента Rigol DM3068 (#2),
% перевод прибора в режим измерения ТОКА,
% утсановка диапаразона измерений в режим АВТО (автоматический выбор
% диапазона).
RigolDM3068_2 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0C94::DM3O214400866::0::INSTR', 'Tag', '');
if isempty(RigolDM3068_2)
    RigolDM3068_2 = visa('NI', 'USB0::0x1AB1::0x0C94::DM3O214400866::0::INSTR');
    fprintf('Инструмент Rigol DM3068 (#2) успешно инициализирован.\n')
else
    fclose(RigolDM3068_2);
    fprintf('Инструмент Rigol DM3068 (#2) уже инициализирован и готов к работе.\n')
    RigolDM3068_2 = RigolDM3068_2(1);
end
fopen(RigolDM3068_2);
fprintf('Инструмент Rigol DM3068 (#2) переводится в режим измерения ПОСТОЯННОГО ТОКА (DCI), пожалуйств, подождите...\n');
fprintf(RigolDM3068_2,':FUNCtion:CURRent:DC');
fprintf('Инструмент Rigol DM3068 (#2), установлен режим измерения: %s.\n\n',strtrim(query(RigolDM3068_1,':FUNCtion?')));
fprintf(RigolDM3068_2, ':MEASure AUTO');


% Измерения
VoltageArrayMeasSP = NaN(1,1000);
CurrentArrayMeasSP = NaN(1,1000);

k = 0;
i = 1;
while true
    if ~ishandle(ButtonHandle)
        disp('Loop stopped by user');
        break;
    end
    tmpVolt = str2double(strtrim(query(RigolDM3068_1, ':MEASure:VOLTage:DC?')));
    tmpCurr = str2double(strtrim(query(RigolDM3068_2, ':MEASure:CURRent:DC?')));
    if i>1
        if tmpVolt> VoltageArrayMeasSP(1,i-1)
            VoltageArrayMeasSP(1,i) = tmpVolt;
            CurrentArrayMeasSP(1,i) = tmpCurr;
            k = i;
            i = i+1;
        end
    else
        VoltageArrayMeasSP(1,i) = tmpVolt;
        CurrentArrayMeasSP(1,i) = tmpCurr;
        i = i+1; 
    end
    plot(VoltageArrayMeasSP(1:i),CurrentArrayMeasSP(1:i)*1000,'-o','MarkerSize',3); grid on; drawnow;
    pause(1);
end

VoltageArrayMeasSP = VoltageArrayMeasSP(1:k);
CurrentArrayMeasSP = CurrentArrayMeasSP(1:k);

path = strcat('PhysMech_Lab02_SP_',string(datetime('now','Format','yyyyMMdd_HHmmss')),'.txt');
writematrix([VoltageArrayMeasSP;CurrentArrayMeasSP]',path,'Delimiter','tab');

figure
plot(VoltageArrayMeasSP,CurrentArrayMeasSP*1000,'-o',...
    'MarkerSize',3);
grid on
title('ВАХ одиночного зонда')
xlabel('V\_Meas (V)')
ylabel('I\_Meas (mA)')

fclose(RigolDM3068_1);
fclose(RigolDM3068_2);