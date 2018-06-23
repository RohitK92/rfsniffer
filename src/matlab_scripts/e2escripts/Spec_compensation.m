function[Tstsig_spec2D,Sine_spec2D,samples_tst_comp] = Spec_compensation(samples_tst,samples_cal,HPF_filt,Fs,window_len)   

    samples_sine_DC_blk = filter(HPF_filt,samples_cal);
    
   
   
   %% Compensating Rx test signal

    samples_tst_DC_blk = filter(HPF_filt,samples_tst);  
    
    %figure;spectrogram(samples_tst_DC_blk,Nfft,Nover,Nfft);
    
    samples_tst_comp = samples_tst_DC_blk.*conj(samples_sine_DC_blk./abs(samples_sine_DC_blk));
    %samples_tst_comp = samples_tst_DC_blk.*conj(samples_sine_DC_blk);
    [zero_indx] = find(samples_sine_DC_blk==0);
    samples_tst_comp(zero_indx) = 0;
    
   % figure;spectrogram(samples_tst_comp,Nfft,Nover,
    %% partitioning signals in received data
    %Nfft1=64*1.25;Nover1 =0;
    Nfft1= window_len;Nover1 =0;
    %Tstsig_spec2D = spectrogram(samples_tst_comp,256,128,256);
    
    %Tstsig_spec2D = spectrogram(samples_tst_comp,rectwin(Nfft1),Nover1,Nfft1);
    [Tstsig_spec2D,f1,t1] = stft(samples_tst_comp, Nfft1, Nfft1, Nfft1, 25e6);
    [x_istft_tst, t_istft] = istft(Tstsig_spec2D,Nfft1, Nfft1, Nfft1, 25e6);
    %figure;imagesc(db(Tstsig_spec2D(:,end:-1:1).'));
    %
    time = exp(1i*2*pi*Fs/2*(1:length(samples_cal))/Fs);
    %figure;spectrogram(conj(samples_calib.*time.'),256,128,256);

    %Sine_spec2D = spectrogram(conj(samples_calib.*time.'),256,128,256);
    Sine_spec2D = spectrogram(conj(samples_sine_DC_blk.*time.'),Nfft1,Nover1,Nfft1);
    %figure;spectrogram(conj(samples_sine_DC_blk.*time.'),Nfft1,Nover1,Nfft1,25e6,'centered');
end   
    %[Sine_spec2D,f2,t2] = stft(conj(samples_sine_DC_blk.*time.'),Nfft1,Nfft1,Nfft1,25e6);
    
    %samples_sine_calib = samples_sine_DC_blk./abs(samples_sine_DC_blk);
    %Sine_spec2D = spectrogram(conj(samples_sine_calib.*time.'),Nfft1,Nover1,Nfft1);
    
    %figure;imagesc(db(Tstsig_spec2D(:,end:-1:1).' +Sine_spec2D(:,end:-1:1).'));
    %Tstsig_spec2D = flipud(Tstsig_spec2D.');
    
    %[Signal_sample_cell]  = Spectrogram_Partition_bdrys_datagen(Tstsig_spec2D,Sine_spec2D) ;
%         for i = 1:length(Signal_sample_cell)
%         x_istft = Signal_sample_cell{i};
%         [Rx_alpha] = CAF_datagen_25msps(x_istft,1);
%         Rx_alpha(196:203,51)=0;    bb = abs(Rx_alpha);
%         bb = bb-min(bb(:));bb = bb/max(bb(:));
%         alpha = linspace(-1/10,1/10-1/(100*5),100);tau = -200:199 ;
%         figure;imagesc(alpha,tau,bb);xlabel('\alpha -1/10:1/500 :1/10 (Cyclic Freq)');ylabel('\tau (Delay)');
% 
%         [Sx_alpha] = CAF_datagen_25msps(x_istft,0);aa = db(Sx_alpha);
%         aa = aa-min(aa(:));aa = aa/max(aa(:));aa(:,51)=0;
%         alpha = linspace(-1/5,1/5-1/(250),100);
%         figure;imagesc(alpha,tau,aa);xlabel('\alpha -1/5:1/250 :1/5 (Cyclic Freq)');ylabel('Delay Freq(f) ');
%     end
   