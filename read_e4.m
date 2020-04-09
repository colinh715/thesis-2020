function timetable = read_e4(file_name)

data = readmatrix(file_name);
% create time vector
t_start = datetime(data(1), 'convertFrom', 'posixtime');
dt = seconds(1/data(2)); % time between samples
% generate timetable from the imported data
timetable = array2timetable(data(3:end),'TimeStep',dt,'StartTime',t_start);

end