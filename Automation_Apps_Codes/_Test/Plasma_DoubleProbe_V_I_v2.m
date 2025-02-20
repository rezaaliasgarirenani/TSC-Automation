% Поиск и создание инструмента Rigol DM3068 (#1),
% перевод прибора в режим измерения ПОСТОЯННОГО НАПРЯЖЕНИЯ,
% установка диапазона измерений в режим АВТО (автоматический выбор
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
fprintf('Инструмент Rigol DM3068 (#1), установлен диапазон измерений режим измерения: %s.\n\n',strtrim(query(RigolDM3068_1,':FUNCtion?')));
fprintf(RigolDM3068_1, ':MEASure AUTO');



% Поиск и создание инструмента Rigol DM3068 (#2),
% перевод прибора в режим измерения ПОСТОЯННОГО ТОКА,
% установка диапазона измерений в режим АВТО (автоматический выбор
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
fprintf('Инструмент Rigol DM3068 (#2), установлен режим измерения: %s.\n',strtrim(query(RigolDM3068_2,':FUNCtion?')));
fprintf(RigolDM3068_2, ':MEASure AUTO');




% Поиск и создание инструмента Rigol DP821A
RigolDP821A = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0E11::DP8E195200156::0::INSTR', 'Tag', '');
if isempty(RigolDP821A)
    RigolDP821A = visa('NI', 'USB0::0x1AB1::0x0E11::DP8E195200156::0::INSTR');
    fprintf('Инструмент Rigol DP821A успешно инициализирован.\n')
else
    fclose(RigolDP821A);
    fprintf('Инструмент Rigol DP821A уже инициализирован и готов к работе.\n')
    RigolDP821A = RigolDP821A(1);
end
fopen(RigolDP821A);
% Настройка базовых параметров (отключение всех каналовзащита от перенапряжения, защита от превышения
% тока, сброс текущих значений напряжения и тока на 0)
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
fprintf('Измерение отрицательной ветви.\n');
% Измерения в отрицательном диапазоне напряжений (-40В..0) с шагом 0.5 В
for i=1:length(VoltageArraySetMinus)
    fprintf(RigolDP821A,':VOLT %f',abs(VoltageArraySet(i)));
    if i==1
        fprintf('Пауза 20с. Установление напряжения -40В... ');
        pause(20);
        fprintf('Продолжаем измерения\n');
    end
    fprintf('Установлено напряжение: %.1f В\n',VoltageArraySet(i));
    pause(1);
    
    VoltageArrayMeasDP(1,i) = (-1)*(str2double(strtrim(query(RigolDM3068_1, ':MEASure:VOLTage:DC?'))));
    CurrentArrayMeasDP(1,i) = (-1)*(str2double(strtrim(query(RigolDM3068_2, ':MEASure:CURRent:DC?'))));
    clf; plot(VoltageArrayMeasDP(1:i),CurrentArrayMeasDP(1:i),'-o','MarkerSize',3); grid on; drawnow;
end
close

fprintf('Измерение отрицательной ветви закончено. Переключите полярность двойного зонда и нажмите ENTER для продолжения измерений в положительном диапазоне...\n');

pause

% Измерения в положительном диапазоне напряжений (0..+40В) с шагом 0.5 В
fprintf('Измерение положительной ветви.\n');
for i=(length(VoltageArraySetMinus)+1):(length(VoltageArraySetMinus)+length(VoltageArraySetPlus))
    fprintf(RigolDP821A,':VOLT %f',abs(VoltageArraySet(i)));
    if i==(length(VoltageArraySetMinus)+1)
        fprintf('Пауза 5с.\n');
        pause(5);
        fprintf('Продолжаем измерения.\n');
    end
    fprintf('Установлено напряжение: %.1f В\n',VoltageArraySet(i));
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
fprintf('Измерение завершено. Напряжение отключено.\nФайл с данными сохранен: %s\n', path);

figure
plot(VoltageArrayMeasDP,CurrentArrayMeasDP*1e6,'-o',...
    'MarkerSize',3);
grid on
title('ВАХ двойного зонда')
xlabel('V\_Meas (V)')
ylabel('I\_Meas (uA)')

fclose(RigolDM3068_1);
fclose(RigolDM3068_2);
fclose(RigolDP821A);