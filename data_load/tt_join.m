function pat_tt = tt_join(study,patient)
%% joins together the CGM data and e4 data at a sampling frequency of 1 min

% open the file with patient data
pat_file = sprintf('raw_data/%s-%s/pat%sdata.mat',study,patient,patient);
pat_data = load(pat_file);

% Extract CGM data and resample down to minutely measurements
pat_tt = pat_data.CGM_save;
%pat_tt.Properties.VariableNames = {'Time','CGM'}
to_drop = ismissing(pat_tt.Time);
pat_tt = pat_tt(~to_drop,:);
CGM_len = height(pat_tt);
%CGM_tt = retime(CGM_tt, 'minutely', 'fillwithmissing');
e4_tts = pat_data.e4_save;

% initialize pat_tt with e4 data
pat_tt = tt_setup(pat_tt, e4_tts{1});
for e = 2:length(e4_tts)
    disp(e)
    % 5 minute timestep between samples
    samplerate5 = duration(0,5,0);
    %samplerate1 = duration(0,1,0);
    
    % downsample the e4 data to 5-minutely points to be useful
    e4_tts{e}.temp = retime(e4_tts{e}.temp,'regular','mean','TimeStep',samplerate5);
    e4_tts{e}.temp.Properties.VariableNames = {'temp'};
    e4_tts{e}.hr = retime(e4_tts{e}.hr,'regular','mean','TimeStep',samplerate5);
    e4_tts{e}.hr.Properties.VariableNames = {'hr'};
    e4_tts{e}.eda = retime(e4_tts{e}.eda,'regular','mean','TimeStep',samplerate5);
    e4_tts{e}.eda.Properties.VariableNames = {'eda'};
    
    % extract steps from acc data
    e4_tts{e}.mag = get_steps(e4_tts{e}.acc);
    e4_tts{e}.mag = retime(e4_tts{e}.mag,'regular','mean','TimeStep',samplerate5);
    %e4_tts{e} = removevars(e4_tts{e},{'Var1','Var2','Var3'})
    %e4_tts{e}.acc.Properties.VariableNames = {'acc_x','acc_y','acc_z'};

    % mesh the tables together
    %pat_tt = [pat_tt;[e4_tts{e}.temp,e4_tts{e}.mag,e4_tts{e}.hr,e4_tts{e}.eda]];
    
    
    
    pat_tt = synchronize(pat_tt,e4_tts{e}.temp);
    pat_tt.temp = nanmean([pat_tt.temp_pat_tt,pat_tt.temp_2],2);
    
    pat_tt = synchronize(pat_tt,e4_tts{e}.mag);
    pat_tt.step_mags = nanmean([pat_tt.step_mags_pat_tt,pat_tt.step_mags_2],2);
    
    pat_tt = synchronize(pat_tt,e4_tts{e}.hr);
    pat_tt.hr = nanmean([pat_tt.hr_pat_tt,pat_tt.hr_2],2);
    
    pat_tt = synchronize(pat_tt,e4_tts{e}.eda);
    pat_tt.eda = nanmean([pat_tt.eda_pat_tt,pat_tt.eda_2],2);

    pat_tt = removevars(pat_tt,{'temp_2','step_mags_2','hr_2','eda_2',
        'temp_pat_tt','step_mags_pat_tt','hr_pat_tt','eda_pat_tt'});
end



end
