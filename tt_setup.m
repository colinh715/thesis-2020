function set_tt = tt_setup(CGM,e4_tt)

samplerate5 = duration(0,5,0);
%samplerate1 = duration(0,1,0);

% downsample the e4 data to 5-minutely points to be useful
e4_tt.temp = retime(e4_tt.temp,'regular','mean','TimeStep',samplerate5);
e4_tt.temp.Properties.VariableNames = {'temp'};
e4_tt.hr = retime(e4_tt.hr,'regular','mean','TimeStep',samplerate5);
e4_tt.hr.Properties.VariableNames = {'hr'};
e4_tt.eda = retime(e4_tt.eda,'regular','mean','TimeStep',samplerate5);
e4_tt.eda.Properties.VariableNames = {'eda'};

% extract steps from acc data
e4_tt.mag = get_steps(e4_tt.acc);
e4_tt.mag = retime(e4_tt.mag,'regular','mean','TimeStep',samplerate5);
%e4_tt = removevars(e4_tt,{'Var1','Var2','Var3'})
%e4_tt.acc.Properties.VariableNames = {'acc_x','acc_y','acc_z'};

% mesh the tables together
%pat_tt = [pat_tt;[e4_tt.temp,e4_tt.mag,e4_tt.hr,e4_tt.eda]];



pat_tt = synchronize(CGM,e4_tt.temp);
pat_tt = synchronize(pat_tt,e4_tt.mag);
pat_tt = synchronize(pat_tt,e4_tt.hr);
pat_tt = synchronize(pat_tt,e4_tt.eda);

set_tt = pat_tt;

end