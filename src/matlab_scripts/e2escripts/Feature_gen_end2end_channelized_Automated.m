
Fs = 25e6;
filenames = [];
dir_capture_path = '~/Desktop/Main_RFsniffer/matlab/chirp_data_multiband/Apr19_CNN_data_gen/May6_microbenchmarks/Rx_end2end/end_end_check/learning_RFcaptures/Jun17_automatedcaptures/';
for i= 1:2
%for i= 1:3%20mhz
    trace_file = strcat(dir_capture_path,'tone',num2str(i),'_band6_25mhz_sep.dat');
    %trace_file = strcat(dir_capture_path,'tone',num2str(i),'_band6_20mhz_sep.dat');
    filenames = [filenames ;trace_file];
end

 sweep_start = 868453;% for 770Hz
 %770Hz
 sweep_time = 36160;% for 770Hz%10th sweep off by 2 samp%100 sweep off by 25samp
 chr_start = 13080;%rise of 2 tone chirp
 chr_stop = 27990;% 
% Calibration data calculation fn
[samples_cal_band6_rate1] = calibration_data_gen_singleband(filenames,sweep_start,sweep_time,chr_start,chr_stop);
%figure;spectrogram(samples_cal_band6_rate1,128,64,1024)

HPF_filt = designfilt('highpassiir', ...
  'FilterOrder',16, ...  
  'PassbandFrequency',0.1e6, ...
  'StopbandAttenuation',50,'PassbandRipple',0.5, ...
  'SampleRate',20e6);

%Test file
dir_tst_file = '~/Desktop/Main_RFsniffer/matlab/chirp_data_multiband/Apr19_CNN_data_gen/May6_microbenchmarks/Rx_end2end/end_end_check/learning_RFcaptures/Jun17_automatedcaptures/';

%Tst_file_names = strcat(dir_tst_file,'Rxvec25msps_OFDM_15dB_2404p1e6.dat');
%Tst_file_names = strcat(dir_tst_file,'Rxvec25msps_BT_2404p1e6.dat');
%Tst_file_names = strcat(dir_tst_file,'Rxvec25msps_LTEfull_wrl_2412e6.dat');
%Tst_file_names = strcat(dir_tst_file,'Rxvec25msps_LTEfull_2404p1e6.dat');
%Tst_file_names = strcat(dir_tst_file,'Rxvec25msps_LTEempty_2404p1e6.dat');
%Tst_file_names = strcat(dir_tst_file,'Rxvec25msps_Zigbee_2404p1e6.dat');
%Tst_file_names = strcat(dir_tst_file,'Rx_WBFM_2404p1e6.dat');
%Tst_file_names = strcat(dir_tst_file,'Rx_AM_8Khz_2404p1e6.dat');
Tst_file_names = strcat(dir_tst_file,'Rxvec_wcdma_2404p1e6.dat');
%snr_ofdm = [-5 0 3 5 10 15 20];
snr_ofdm = [20];
snr_bt = [-20 -15 -10 -5 0 5 10];
%snr_zigbee = [20];
%snr_zigbee = [-10 0 5 10 15 20];
%snr_bt = [10];
for ii=1:length(snr_bt)
%for ii=1:length(snr_zigbee)
%for ii=1:length(snr_ofdm)
    %ofdm_file{ii} = ['Rxvec25msps_OFDM_',num2str(snr_ofdm(ii)),'dB_2412e6.dat'];
    bt_file{ii} = [dir_tst_file,'Rxvec25msps_BT_',num2str(snr_bt(ii)),'dB_2412e6.dat'];
    %zigbee_file{ii} = [dir_tst_file,'Rxvec25msps_zigbee_',num2str(snr_zigbee(ii)),'dB_2412e6.dat'];
end

rxsx = zeros(400,100,2,272);
tone_start_freq = 2404.1e6;
%for ii =1:length(snr_ofdm)
%for ii =1:length(snr_bt)
%for ii =1:length(snr_zigbee) 
    %Fc_BW_sigs =[2412e6,25e6];%AWGN
    %Fc_BW_sigs =[2412e6,20e6];%OFDM
    Fc_BW_sigs =[2412e6,3e6];%BT %Guardband 2e6+Channel BW 1e6
    %Fc_BW_sigs =[2412e6,4e6];%Zigbee 
    [samples_tst, n_samples] = load_samples(Tst_file_names,'float32',1);
    %[samples_tst, n_samples] = load_samples(ofdm_file{ii},'float32',1);
    %[samples_tst, n_samples] = load_samples(bt_file{ii},'float32',1);
    %[samples_tst, n_samples] = load_samples(zigbee_file{ii},'float32',1);
    samples_tst1 = samples_tst(sweep_start:end);
    Nsweeps  = floor(length(samples_tst1)/sweep_time);
    Rx_alpha_mx = zeros(400,100,(Nsweeps));
    Sx_alpha_mx = zeros(400,100,(Nsweeps));
    samples_tst1 = samples_tst1((1:Nsweeps*sweep_time)); 
    samples_rr = reshape(samples_tst1,[],Nsweeps);
    samples_rr = samples_rr(chr_start:chr_stop,:);
    samples_tst_comp_i = zeros(size(samples_rr));
    for Runcnt = 0:Nsweeps-1
        samples_tst_i = samples_rr(:,Runcnt+1);
        window_len = 80;
        [Tstsig_spec2D,Sine_spec2D,samples_tst_comp] = Spec_compensation(samples_tst_i,samples_cal_band6_rate1,HPF_filt,Fs,window_len);
        samples_tst_comp_i(:,Runcnt+1) = samples_tst_comp;%For FM
        %figure;imagesc(db(Tstsig_spec2D)+db(Sine_spec2D));
        %Send tst tone to figure out actual VCO band start
        %Sine spec 2D start freq 2404.1e6 -> Band indx 76 
        % samples_padded = samples_tst_comp_i;
        %samples_padded(7001:14911,:) = 0;
        %figure;spectrogram(samples_padded(:,1),128,64,1024)
        Sig_duration = [1];%1/2 if taking 1/2 the time duration
        
        %spectrogram(samples_tst_comp(1:14911),128,64,1024,25e6,'centered')
        %title(num2str(Runcnt));
        %pause(0.05);
       
        [Signal_sample_cell,RFlin_spec2D]  = Spectrogram_Partition_bdrys_datagen_channelisation(Tstsig_spec2D,Sine_spec2D,Fc_BW_sigs,Sig_duration,tone_start_freq,Fs) ;
        %CAF ,SCD
        %x_istft  =samples_tst_comp(1:8000);%OFDM
        x_istft  =samples_tst_comp(1:7000);%BT
        %x_istft = Signal_sample_cell{1};
        alpha = linspace(-1/10,1/10-1/(100*5),100);tau = -200:199 ;
        [Rx_alpha] = CAF_datagen_25msps(x_istft.',alpha,tau,1);
        %[Rx_alpha] = CAF_datagen_25msps_mod(x_istft.',1);
        %Rx_alpha(196:203,51)=0;    bb = abs(Rx_alpha);
        Rx_alpha(185:215,51)=0;    bb = abs(Rx_alpha);%CDMA,DSSS
        bb = bb-min(bb(:));bb = bb/max(bb(:));
         Rx_alpha_mx(:,:,Runcnt+1) =  bb;
        
        %figure;imagesc(alpha,tau,bb);xlabel('\alpha -1/10:1/500 :1/10 (Cyclic Freq)');ylabel('\tau (Delay)');
        alpha = linspace(-1/5,1/5-1/(250),100);tau = -200:199 ;  
        [Sx_alpha] = CAF_datagen_25msps(x_istft.',alpha,tau,0);aa = db(Sx_alpha);
        aa = aa-min(aa(:));aa = aa/max(aa(:));aa(:,51)=0;
        Sx_alpha_mx(:,:,Runcnt+1) =  aa;
         %figure;imagesc(alpha,tau,aa);xlabel('\alpha -1/5:1/250 :1/5 (Cyclic Freq)');ylabel('Delay Freq(f) ');
    end
    
    rxsx(:,:,1,1:Nsweeps) = Rx_alpha_mx(:,:,1:Nsweeps);
    rxsx(:,:,2,1:Nsweeps) = Sx_alpha_mx(:,:,1:Nsweeps);
%     op_ofdm_file{ii} = ['OFDM_25msps',num2str(snr_ofdm(ii)),'dB_RxSx_fin.mat'];
%     save(op_ofdm_file{ii},'rxsx','-v7.3');
    %op_ofdm_file{ii} = ['OFDM_25msps',num2str(snr_ofdm(ii)),'dB_RxSx_fin.mat'];
    %save(op_ofdm_file{ii},'rxsx','-v7.3');
    %op_bt_file{ii} = ['BT_25msps',num2str(snr_bt(ii)),'dB_RxSx_fin.mat'];
    %save(op_bt_file{ii},'rxsx','-v7.3');
    %op_zigbee_file{ii} = ['Zigbee_25msps',num2str(snr_zigbee(ii)),'dB_RxSx_fin.mat'];
    %save(op_zigbee_file{ii},'rxsx','-v7.3');
    
    %save('AWGN_25msps_RxSx_fin.mat','rxsx','-v7.3');
%end



