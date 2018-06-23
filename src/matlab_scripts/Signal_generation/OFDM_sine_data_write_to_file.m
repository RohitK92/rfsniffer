ofdm = 0;
BT = 0;
NB_FM =0;
Zigbee = 0;
CDMA2000_3G = 1;
if(ofdm)

wl_example_siso_ofdm_txrx
Ts = 1/20e6;
t = 0:1:5e5;
f=1e6;
% x =1*exp(1i*2*pi*f*Ts*t);
% %
% awgn = 0;
% SNR = 0;
% %rand_tx_vec = sqrt(var(tx_vec))*((rand(1,length(tx_vec))-0.5) + 1i*(rand(1,length(tx_vec))-0.5))/sqrt(2);
% rand_tx_vec = (10^(-1*SNR/20))*sqrt(var(tx_vec))*((randn(1,length(tx_vec))) + 1i*(randn(1,length(tx_vec))))/sqrt(2);
% if(awgn)
%     tx_vec = 1*rand_tx_vec;
% end
% tx_vec1 = tx_vec+1*rand_tx_vec;
% %sqrt(var(tx_Vec)) --> giving SNR 10dB
% TX_SCALE = 1;
% tx_vec1 = TX_SCALE .* tx_vec1 ./ max(abs(tx_vec1));
% 
% %Txvec_300t = repmat(tx_vec,1,300);
% %Wb_sine = [Txvec_300t x];
% %Tx_fin_Wb_sine = repmat(Wb_sine,1,200);
% Tx_fin_Wb_sine = repmat(tx_vec1,1,200);
% %write_complex_binary(Tx_fin_Wb_sine,'Txvec_OFDM_sine_AWGN_0dB_10s.dat')
% write_complex_binary(Tx_fin_Wb_sine,'Txvec_sine_AWGN_0dB_10s.dat')
% 
% %Only OFDM data for wireless data expt
% Wb_sine = [tx_vec*100];
% Tx_fin_Wb_sine = repmat(Wb_sine,1,200);
% write_complex_binary(Tx_fin_Wb_sine,'Txvec_OFDM_5sec.dat')
% %Put Nsym = 6000 in wl_example.
% %Wb_sine = repmat(Tx_vec_300t,1,200) 
% %write_complex_binary(Wb_sine,'Txvec_OFDM_.dat')

%% OFDM
% 
% tx_vec = resample(tx_vec,5,4);%upsampling to 25msps
% 
% % awgn = 0;
%  SNR = 10;
% % %rand_tx_vec = sqrt(var(tx_vec))*((rand(1,length(tx_vec))-0.5) + 1i*(rand(1,length(tx_vec))-0.5))/sqrt(2);
%  rand_tx_vec = (10^(-1*SNR/20))*sqrt(var(tx_vec))*((randn(1,length(tx_vec))) + 1i*(randn(1,length(tx_vec))))/sqrt(2);
%  tx_vec1 = tx_vec+1*rand_tx_vec;
%  TX_SCALE = 1;
%  tx_vec1 = TX_SCALE .* tx_vec1 ./ max(abs(tx_vec1));
%  Tx_fin_Wb_sine = repmat(tx_vec1,1,200);
% % write_complex_binary(Tx_fin_Wb_sine,'Txvec_OFDM_m70dB_10s.dat')
% write_complex_binary(Tx_fin_Wb_sine,'Txvec_OFDM_25msps20dB_10s.dat')
end
%% BT
if(BT)
TX_SCALE =1;
gfsk_simulated_datagen
% SNR=-10;
% tx_vec1 = y_gfsk+1*((10^(-1*SNR/20))*sqrt(var(y_gfsk))*((randn(length(y_gfsk),1)) + 1i*(randn(length(y_gfsk),1)))/sqrt(2));
% tx_vec1 = TX_SCALE .* tx_vec1 ./ max(abs(tx_vec1));
% write_complex_binary(tx_vec1,'Txvec_BT_m10dB_5s.dat')
end
%% NB FM
if(NB_FM)

    %load from SDRSharp_20150804_204012Z_0Hz_IQ.wav
    [y,Fs] = audioread('SDRSharp_20150804_204012Z_0Hz_IQ.wav');%Fs
    z = y(:,1)+1i*y(:,2);
    FM_txvec = resample(z(1:Fs*5),130,1);%5sec data
    FM_txvec = FM_txvec.';
    snr_fm_25e6 = [-10 -5 0 5]; 
    snr_fm_192e3 = snr_zigbee_25e6 + 21;%10*log10(25e6/192e3) ~ 21dB
     TX_SCALE = 1;
    for snr_no = 1:length(snr_zigbee_25e6)
    %
        rand_tx_vec = (10^(-1*snr_fm_25e6(snr_no)/20))*sqrt(var(FM_txvec))*((randn(1,length(FM_txvec))) + 1i*(randn(1,length(FM_txvec))))/sqrt(2);
        FM_txvec_noisy = FM_txvec+rand_tx_vec;
        FM_txvec_noisy_scaled = TX_SCALE .* FM_txvec_noisy ./ max(abs(FM_txvec_noisy));
        
       %Check CAF,SCD for diff SNRs  
%     [Rx_alpha] = CAF_datagen_25msps_test(FM_txvec_noisy_scaled(1:1e5),1);
%     figure;imagesc((-10/(80):1/(10*80):(10/80)-1/800),-200:1:199,db(Rx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay (\tau)');title(['FM CAF', num2str(snr_fm_25e6(snr_no)),'dB SNR @ 25msps']);
%     [Sx_alpha] = CAF_datagen_25msps_test(FM_txvec_noisy_scaled(1:1e5),0);
%     Nfft=400;figure;imagesc((-Nfft/2:1:Nfft/2 - 1)/Nfft,(-Nfft/2:1:Nfft/2 - 1)/Nfft,db(Sx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay Freq(1/\tau)');title(['FM SCD', num2str(snr_fm_25e6(snr_no)),'dB SNR @ 25msps']);
%    [Rx_alpha] = CAF_datagen_25msps(FM_txvec_noisy_scaled(1:1e5),1);
%    figure;imagesc(linspace(-1/10,1/10-1/(100*5),100),-200:1:199,db(Rx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay (\tau)');title(['FM CAF', num2str(snr_fm_25e6(snr_no)),'dB SNR @ 25msps']);
%   [Sx_alpha] = CAF_datagen_25msps(FM_txvec_noisy_scaled(1:1e5),0);
%   Nfft=400;figure;imagesc( linspace(-1/5,1/5-1/(250),100),(-Nfft/2:1:Nfft/2 - 1)/Nfft,db(Sx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay Freq(1/\tau)');title(['FM SCD', num2str(snr_fm_25e6(snr_no)),'dB SNR @ 25msps']);
   

%Writing to a file
        %FM_txvec_noisy_fin = FM_txvec_noisy_scaled; 
        %write_complex_binary(FM_txvec_noisy_fin,['Txvec_fm_25msps',num2str(snr_fm_25e6(snr_no)),'dB_5s.dat']);
    end
end
%% Zigbee
if(Zigbee)
zigbee_PHY_sim_2450
  %received = awgn(waveform, SNR);
  Fs = 2e6;
 % received = waveform;%4msps rate
  Zigbee_txvec = resample(waveform,25,2);%1sec data
  Zigbee_txvec = Zigbee_txvec.';

 %Noise floor for 25msps   
 %Signal BW -4e6 ;Noise BW - 25e6
snr_zigbee_25e6 = [-10]; 
%snr_zigbee_25e6 = [10 15 20]; 
snr_zigbee_2e6 = snr_zigbee_25e6 + 11;%10*log10(25/2) ~ 8dB
 TX_SCALE = 1;
for snr_no = 1:length(snr_zigbee_25e6)
    %Zigbee_txvec = resample(received,25,4);
    rand_tx_vec = (10^(-1*snr_zigbee_25e6(snr_no)/20))*sqrt(var(Zigbee_txvec))*((randn(1,length(Zigbee_txvec))) + 1i*(randn(1,length(Zigbee_txvec))))/sqrt(2);
    Zigbee_txvec_noisy = Zigbee_txvec +1* rand_tx_vec;
   
    Zigbee_txvec_noisy_scaled = TX_SCALE .* Zigbee_txvec_noisy ./ max(abs(Zigbee_txvec_noisy));
    
%Check CAF,SCD for diff SNRs  
   % [Rx_alpha] = CAF_datagen_25msps_test(Zigbee_txvec_noisy_scaled(1:1e5),1);
   % figure;imagesc((-10/(80):1/(10*80):(10/80)-1/800),-200:1:199,db(Rx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay (\tau)');title(['Zigbee CAF', num2str(snr_zigbee_25e6(snr_no)),'dB SNR @ 25msps']);
   % [Sx_alpha] = CAF_datagen_25msps_test(Zigbee_txvec_noisy_scaled(1:1e5),0);
   % Nfft=400;figure;imagesc((-Nfft/2:1:Nfft/2 - 1)/Nfft,(-Nfft/2:1:Nfft/2 - 1)/Nfft,db(Sx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay Freq(1/\tau)');title(['Zigbee SCD', num2str(snr_zigbee_25e6(snr_no)),'dB SNR @ 25msps']);
%    [Rx_alpha] = CAF_datagen_25msps(Zigbee_txvec_noisy_scaled(1:1e5),1);
%    figure;imagesc(linspace(-1/10,1/10-1/(100*5),100),-200:1:199,db(Rx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay (\tau)');title(['Zigbee CAF', num2str(snr_zigbee_25e6(snr_no)),'dB SNR @ 25msps']);
%   [Sx_alpha] = CAF_datagen_25msps(Zigbee_txvec_noisy_scaled(1:1e5),0);
%   Nfft=400;figure;imagesc( linspace(-1/5,1/5-1/(250),100),(-Nfft/2:1:Nfft/2 - 1)/Nfft,db(Sx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay Freq(1/\tau)');title(['Zigbee SCD', num2str(snr_zigbee_25e6(snr_no)),'dB SNR @ 25msps']);

%Writing to a file
     Zigbee_txvec_fin = repmat(Zigbee_txvec_noisy_scaled,1,6.25e2);%5sec data
     write_complex_binary(Zigbee_txvec_fin,['Txvec_zigbee_25msps',num2str(snr_zigbee_25e6(snr_no)),'dB_5s.dat']);
end

end

%%CDMA 2000 - 3G
%1900 MHz
%     len  = 6e6*5;
%     [y,Fs] = audioread('HDSDR_20160920_114213Z_1936562kHz_RF.wav',[1 len]);%6Msps%40sec data    
%     z = y(:,1)+1i*y(:,2);
if(CDMA2000_3G)
    cdma2000WaveformGenerationExample_custom
    cdma_txvec=forwardManualWaveform.';
    Fs =25e6;
    %snr_cdma_25e6 = [-10 -5 0 5]; 
    snr_cdma_25e6 = 25;
    snr_cdma_1p25e6 = snr_cdma_25e6 + 13;%10*log10(25/1.25) ~ 8dB
    TX_SCALE = 1;
for snr_no = 1:length(snr_cdma_25e6)
    %Zigbee_txvec = resample(received,25,4);
    rand_tx_vec = (10^(-1*snr_cdma_25e6(snr_no)/20))*sqrt(var(forwardManualWaveform))*((randn(1,length(forwardManualWaveform))) + 1i*(randn(1,length(forwardManualWaveform))))/sqrt(2);
    cdma_txvec_noisy = cdma_txvec +1* rand_tx_vec;
   
    cdma_txvec_noisy_scaled = TX_SCALE .* cdma_txvec_noisy ./ max(abs(cdma_txvec_noisy));
    
%Check CAF,SCD for diff SNRs  
    [Rx_alpha] = CAF_datagen_25msps_test(cdma_txvec_noisy_scaled(1:2e4),1);
    figure;imagesc((-10/(80):1/(10*80):(10/80)-1/800),-200:1:199,db(Rx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay (\tau)');title(['CDMA CAF', num2str(snr_cdma_25e6(snr_no)),'dB SNR @ 25msps']);
    [Sx_alpha] = CAF_datagen_25msps_test(cdma_txvec_noisy_scaled(1:2e4),0);
    Nfft=400;figure;imagesc((-Nfft/2:1:Nfft/2 - 1)/Nfft,(-Nfft/2:1:Nfft/2 - 1)/Nfft,db(Sx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay Freq(1/\tau)');title(['CDMA SCD', num2str(snr_cdma_25e6(snr_no)),'dB SNR @ 25msps']);
%    [Rx_alpha] = CAF_datagen_25msps(Zigbee_txvec_noisy_scaled(1:1e5),1);
%    figure;imagesc(linspace(-1/10,1/10-1/(100*5),100),-200:1:199,db(Rx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay (\tau)');title(['Zigbee CAF', num2str(snr_zigbee_25e6(snr_no)),'dB SNR @ 25msps']);
%   [Sx_alpha] = CAF_datagen_25msps(Zigbee_txvec_noisy_scaled(1:1e5),0);
%   Nfft=400;figure;imagesc( linspace(-1/5,1/5-1/(250),100),(-Nfft/2:1:Nfft/2 - 1)/Nfft,db(Sx_alpha));xlabel('\alpha (Cyclic Freq)');ylabel('Delay Freq(1/\tau)');title(['Zigbee SCD', num2str(snr_zigbee_25e6(snr_no)),'dB SNR @ 25msps']);

%Writing to a file
    
    write_complex_binary(cdma_txvec_noisy_scaled,['Txvec_cdma_25msps_5s.dat']);
end
end

if(AM)
    [y,Fs] = audioread('AM_IQ.wav');%Fs
    aa = resample(y(2e6:3e6,1),6250,16);
    TX_SCALE =1;
    AM_txvec_noisy_scaled = TX_SCALE .* aa ./ max(abs(aa));
     write_complex_binary(AM_txvec_noisy_scaled,['Txvec_AM_25msps_5s.dat']);
end
