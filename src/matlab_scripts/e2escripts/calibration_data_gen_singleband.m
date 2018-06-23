function[samples_cal_band6_rate1] = calibration_data_gen_singleband(filenames,sweep_start,sweep_time,chr_start,chr_stop)

Fs = 25e6;

% %sweep_start = 253730;% for 770Hz
% sweep_start = 868453;% for 770Hz
% %sweep_start = 259363;% for 1.563KHz
% %sweep_start = 259685;% for 3.165KHz
% 
% %770Hz
% sweep_time = 36160;% for 770Hz%10th sweep off by 2 samp%100 sweep off by 25samp
% chr_start = 13080;%rise of 2 tone chirp
% chr_stop = 27990;% 
samples_cal_band6_rate1 = zeros(sweep_time,1);
for i = 1:size(filenames,1)%three tones calibration data acro
    [samples_sine, n_samples] = load_samples(filenames(i,:),'float32',1);

    %samp_start =0.01038*Fs;%fixed offset %207600;%

    samples_cal = samples_sine(sweep_start:end);%Orig HW chirp
    %samples_cal = samples_sine(sweep_start1:end);%Orig HW chirp

    samples_wb = samples_cal(1:sweep_time);
    samples_cal_band6_rate1 =samples_cal_band6_rate1+samples_wb;
    %figure;spectrogram(samples_cal_band6_rate1,128,64,1024)
    %save('calibration_data_tone1_band6.mat','samples_wb','data');
end
    samples_cal_band6_rate1 = samples_cal_band6_rate1(chr_start:chr_stop);
end