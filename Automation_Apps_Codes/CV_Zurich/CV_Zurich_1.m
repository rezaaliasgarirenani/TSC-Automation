function device=ZurichCV(~)


clear ziDAQ;
device_id=('dev5478');

% The API level supported by this example.
supported_apilevel = 6;
% Create an API session; connect to the correct Data Server for the device.
[device, ~] = ziCreateAPISession(device_id, supported_apilevel);

ziApiServerVersionCheck();

ziDAQServer('192.168.85.154', 8004, 6)

end