

[filename, pathname] = uiputfile('*.xlsx', 'Save as');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   %define your sheets names
   sheet1 = 'Settings';
   sheet2 = 'Stabilization';
   sheet3 = 'Measurements';

   initialtemperature=81;
   SampleInfo='SiN';
   Comments='Comm';

   % define measurement parameters and data
   settings = {'Sample Info' , SampleInfo ; 'Comments' , Comments ; 'Starting Temperature' , 'stmp' ;'Initial Temperature', initialtemperature; 'Final Temperature','s' ; 'Parameter_3', 'Value_3'}; % replace with your settings
   Stabilization = rand(50,1); % replace this with your Stabilization data
   Measurements = rand(50,1); % replace this with your Measurements data

   % Define variable names for measurements tables
   stablization_var_names = {'Temperature', 'Current'};
   measurement_var_names = {'Temperature', 'Current'};

   % Create time vector
   time = (1:length(Stabilization))';

   % Create tables for measurements
   stablization_table = table(time, Stabilization, 'VariableNames', stablization_var_names);
   measurement_table = table(time, Measurements, 'VariableNames', measurement_var_names);

   %write settings, temperature data and current data to the Excel file
   writecell(settings, fullfile(pathname, filename), 'Sheet', sheet1);
   writetable(stablization_table, fullfile(pathname, filename), 'Sheet', sheet2);
   writetable(measurement_table, fullfile(pathname, filename), 'Sheet', sheet3);
   % Add your writematrix, writecell, writetable code here, using fullfile(pathname, filename) as the filename
   
end


