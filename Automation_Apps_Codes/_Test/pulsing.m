%make buffer and print readings to receive and save data for KETHLEY2450:
writeline(KLYSM2450,'Voltage_Current_Buffer_Pulse = buffer.make(10),buffer.STYLE_WRITABLE_FULL')
writeline(KLYSM2450,'smu.measure.read(Voltage_Current_Buffer_Pulse)')
writeline(KLYSM2450, strcat('smu.source.level = ',string(Vp))) %Sets the final voltage
pause(tp)