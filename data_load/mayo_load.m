%% 
%
% sansum_load.m
% Loads in data for e4 and CGM for the sansum trial
%
%
%
% created by Colin Harvey 9/21/19

%% Unzip and move the e4 data

% patient tags 
patient_list = {'001','002','003','004','005','006','007','008'};

% relevant parent folder to extract from 
parent = 'C:\Users\coh275\Documents\Thesis programs\JDRF_mayo';

for patient = 1:length(patient_list)
    fprintf('PATIENT %d\n',patient)
    % where the data is being moved to
    targetloc = sprintf('raw_data/mayo-%s/e4_data',patient_list{patient});
    % empatica data location
    emp = sprintf('%s/5426-%s/Empatica',parent,patient_list{patient});
    subdirs = dir(emp);
    subdirs = subdirs(3:end); % skip '.' and '..'
    for folder = 1:length(subdirs)
        fprintf('%d/%d\n',folder,length(subdirs))
        fileloc = sprintf('%s/%s',emp,subdirs(folder).name);
        subsubs = dir(fileloc);
        subsubs = subsubs(3:end);
        for subfolder = 1:length(subsubs)
            filename = sprintf('%s/%s',fileloc,subsubs(subfolder).name);
            ziptarget = sprintf('%s/%s',targetloc,subsubs(subfolder).name);
            unzip(filename,ziptarget);
        end
    end
 end



%% load the CGM data

cd 'C:\Users\coh275\Documents\Thesis programs' % changes to the correct folder

% empty cell array to hold CGM data tables
CGM_data = cell(1,length(patient_list));

for patient = 1:length(patient_list)
    disp(patient) % track progress
    
    % determine the file name for the CGM data and read it in
    file_loc = sprintf('raw_data/mayo-%s/CGM_data',patient_list{patient});
    file_name = dir(file_loc);
    file_name = [file_loc, '/', file_name(3).name];
    CGM_table = readtable(file_name);
    
    % patient 9 needs to be treated differently due to csv formatting
    % Convert the data to timetables for union
    if patient==8
        CGM_table = CGM_table(:,{'Var2','Var8'}); % take only useful parts
        %CGM_table = convertvars(CGM_table,'Var2','datetime'); 
        reformatted = char(CGM_table.Var2);
        reformatted(:,11) = ' '; % replace the T with a space for formatting
        reformatted = datetime(reformatted);
        CGM_timetable = table2timetable(CGM_table(:,'Var8'),'RowTimes',reformatted); % convert to timetable
    else        
        CGM_table = CGM_table(11:end,{'Timestamp_YYYY_MM_DDThh_mm_ss_','GlucoseValue_mg_dL_'}); % take only useful parts
        reformatted = char(CGM_table.Timestamp_YYYY_MM_DDThh_mm_ss_);
        reformatted(:,11) = ' '; % replace the T with a space for formatting
        reformatted = datetime(reformatted);
        % convert to timetable
        CGM_timetable = table2timetable(CGM_table(:,'GlucoseValue_mg_dL_'),'RowTimes',reformatted);

   end
    CGM_data{patient} = CGM_timetable;
end

%% Load the watch data

cd 'C:\Users\coh275\Documents\Thesis programs' % changes to the correct folder

e4_data = cell(1,length(patient_list));

for patient = 1:length(patient_list)
    fprintf('PATIENT %d\n',patient) % track progress
    
    % get directories
    file_loc = sprintf('raw_data/mayo-%s/e4_data',patient_list{patient});
    subdirs = dir(file_loc);
    subdirs = subdirs(3:end); % skip '.' and '..'
    
    e4_subdata = cell(1,length(subdirs));
    
    for folder = 1:length(subdirs)
        fprintf('%d/%d\n',folder,length(subdirs))
        % load the temperature data
        file_name =  sprintf('%s/%s/TEMP.csv',file_loc,subdirs(folder).name);
        data.temp = read_e4(file_name);
        
        % load the acceleration data, three channels so needs different
        % handling (slightly)
        file_name =  sprintf('%s/%s/ACC.csv',file_loc,subdirs(folder).name);
        acc_data = readmatrix(file_name);
        t_start = datetime(acc_data(1,1), 'convertFrom', 'posixtime');
        dt = seconds(1/acc_data(2,1));
        % generate timetable from the imported data
        data.acc = array2timetable(acc_data(3:end,:),'TimeStep',dt,'StartTime',t_start);
        
        % load the heart rate data
        file_name =  sprintf('%s/%s/HR.csv',file_loc,subdirs(folder).name);
        data.hr = read_e4(file_name);
        
        % load the skin response data
        file_name =  sprintf('%s/%s/EDA.csv',file_loc,subdirs(folder).name);
        data.eda = read_e4(file_name);
        
        e4_subdata{folder} = data;
    end
    e4_data{patient} = e4_subdata;
end


%% save the output
for ind = 1:10
    filename = sprintf('pat%sdata',patient_list{ind});
    CGM_save = CGM_data{ind};
    e4_save = e4_data{ind};
    save(filename,'CGM_save','e4_save','-v7.3')
end









