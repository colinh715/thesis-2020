function step_mag = get_steps(acc)
close all

% https://posemethod.com/usain-bolts-running-technique/#targetText=Bolt's%20calculated%20average%20angle%20in,(281%20steps%20per%20minute).

% this processing is taken in part from an ES157 lab exercise

mags = sqrt(acc.Var1.^2 + acc.Var2.^2 + acc.Var3.^2); % get magnitudes
mags = mags-mean(mags); % 0 centering
% figure;
% plot(mags)

mags_f = fft(mags); % take fourier transorm into frequency domain
mags_f = circshift(mags_f, floor(length(mags_f)/2)); % shift it to be 0 centered

fs = 32; % sample freq for acc
freq = linspace(-fs/2,fs/2, length(mags_f)); % frequency vector

%disp(length(mags_f))
%figure;
%plot(freq, abs(mags_f))

clean_mags_f = mags_f;
clean_mags_f(abs(freq)<.75 | abs(freq)>5) = 0;

% figure;
% hold on
% plot(freq,abs(mags_f))
% plot(freq,abs(clean_mags_f))
% hold off

% unshift the fft for ifft
clean_mags_f = circshift(clean_mags_f, -floor(length(clean_mags_f)/2));

% take the inverse transform back to time domain
clean_mags = ifft(clean_mags_f);
% figure;
% hold on
% plot(1:640,abs(clean_mags(321:960)))
% plot(1:640,mags(321:960))

% the final abs magnitudes of acc that could be explained by walking /
% running etc
acc.step_mags = abs(clean_mags); 
step_mag = removevars(acc,{'Var1','Var2','Var3'});



end
