function [Signal_samp_cell,RFlin_spec2D]  = Spectrogram_Partition_bdrys_datagen_channelisation(Tstsig_spec2D,Sine_spec2D,Fc_BW_sigs,Sig_duration,tone_start_freq,Fs) 
Nfft = size(Sine_spec2D,1);
paritition_new =1;
%% Getting the Freq axes indices
% While capturing 1.remove DC compoent 2. The random variation at end of cycle - remove

[~,freq_maxindx] = max(abs(Sine_spec2D),[],1);

% find time blks where Sine tone moves from Fs to 0
[Chrpcyc_indx] = find((freq_maxindx(1:end-1)-freq_maxindx(2:end))>(3*Nfft/4));

 
%At each time blk find Fc from sine tone location and until how many time blks(equi to 20MHz) it remains
cycno = 1;
time_indexes = zeros(size(Sine_spec2D,2),2);

% Getting approx location of Fc(t)+20Mhz at each time blk
%time indices = [Fc Nxttimeblk_untilFc]
for i = 1:size(Sine_spec2D,2)
%for i = 1:Chrpcyc_indx(end)
    %find the time indx until which we can see the spectrum observd in this
    %time blk (time equiv to 20MHz delta f)
   if(i>=Chrpcyc_indx(end))
       time_indexes(i,:) = [freq_maxindx(i),size(Sine_spec2D,2)];
   else
       
    if(cycno==length(Chrpcyc_indx))
        bb = freq_maxindx(Chrpcyc_indx(cycno)+1:end);
    else
        bb = freq_maxindx(Chrpcyc_indx(cycno)+1:Chrpcyc_indx(cycno+1));
    end
    aa = bb-freq_maxindx(i);
    signinv_indx = sign(aa(2:end)).*sign(aa(1:end-1));
    kk = find(signinv_indx==0 | signinv_indx==-1 );
    if(isempty(kk))
        indx = prev_indx;
    else
        indx = Chrpcyc_indx(cycno)+kk(1);
    end
    prev_indx =indx;
    %indx = find(max_indx(i+1 :end) == max_indx(i));

    time_indexes(i,:) = [freq_maxindx(i),indx];  %In time Blk i -> [ Tone_Freq_index nxt_timeBlk until which ] 
    if(ismember(i,Chrpcyc_indx(1:end))) 
        cycno = cycno+1;
    end
    
   end
end

%% Linearizing the RF spectrogram from the Freq-time indices each cycle 
if(paritition_new)
    
aa = abs(Sine_spec2D);
[counts,x] = imhist(aa(:,:)./(max(aa(:))),2048);
[t,m] = otsuthresh(counts);
bw = single(imbinarize(aa(:,:)./(max(aa(:))),t*m));
%figure(1), subplot(211),imagesc(aa(:,:)), subplot(212), imagesc(bw);


    

[~,freq_maxindx] = max(abs(Sine_spec2D),[],1);
Nfft = size(Sine_spec2D,1);
% find time blks where Sine tone moves from Fs to 0
[Chrpcyc_indx] = find((freq_maxindx(1:end-1)-freq_maxindx(2:end))>(3*Nfft/4));

 Sig_partitions = zeros(size(Tstsig_spec2D,1),size(Tstsig_spec2D,2),length(Chrpcyc_indx));
 
 indx_part1 =zeros(size(Tstsig_spec2D,1),length(Chrpcyc_indx)+1);
 
 for i=1:size(bw,1)
      indx_tot = find(bw(i,:)~=0);
      
      %first partition indices
      indx_part1_i=find(indx_tot<=Chrpcyc_indx(1));
      if(isempty(indx_part1_i))
          indx_part1(i,1)=1;
      else
          indx_part1(i,1)= indx_tot(indx_part1_i(1));
      end
      indx_part2_i = find((indx_tot>Chrpcyc_indx(1).*(indx_tot<=Chrpcyc_indx(2))));
     % indx_part2_i = find((indx_tot>indx_part1(i,1)+(Chrpcyc_indx(2)-Chrpcyc_indx(1))*3/4).*(indx_tot<Chrpcyc_indx(2)));
      %indx_part2_i=find((indx_tot<Chrpcyc_indx(2))&&(indx_tot>Chrpcyc_indx(1)));
      if(isempty(indx_part2_i))
          if(i~=1)
              indx_part1(i,2)=indx_part1(i-1,2);
          else
              indx_part1(i,2) = Chrpcyc_indx(1);
          end
          %indx_part1(i,2)=indx_part1(i-1,2);
      else
          indxs = indx_tot(indx_part2_i(:));
          k=find(indxs- indx_part1(i,1)>=Chrpcyc_indx(1));
          indx_part1(i,2)=indxs(k(1));
          %indx_part1(i,2)= indx_tot(indx_part2_i(1));
      end
      indx_part3_i = find((indx_tot>Chrpcyc_indx(2)).*(indx_tot<=Chrpcyc_indx(3)));
       %indx_part3_i = find((indx_tot>indx_part1(i,2)+(Chrpcyc_indx(3)-Chrpcyc_indx(2))*3/4).*(indx_tot<Chrpcyc_indx(3)));
       if(isempty(indx_part3_i))
          if(i~=1)
              indx_part1(i,3)=indx_part1(i-1,3);
          else
              indx_part1(i,3) = Chrpcyc_indx(2);
          end
          %indx_part1(i,3)=indx_part1(i-1,3);
       else
          indxs = indx_tot(indx_part3_i(:));
          k=find(indxs- indx_part1(i,2)>=(Chrpcyc_indx(2)-Chrpcyc_indx(1))/2);%Next indx at same band atleast 
          %greater than half of expected
          if(isempty(k))
              if(i~=1)
                  indx_part1(i,3)= indx_part1(i-1,3);
              else
                  indx_part1(i,3) = Chrpcyc_indx(2);
              end              
          else
              indx_part1(i,3)=indxs(k(1));
          end
          
          
          %indx_part1(i,3)= indx_tot(indx_part3_i(1));
          
       end
       indx_part4_i = find((indx_tot>Chrpcyc_indx(3)));
       
       if(isempty(indx_part4_i))
          indx_part1(i,4)=size(Sine_spec2D,2);
      else
          indx_part1(i,4)= indx_tot(indx_part4_i(1));
      end
      Sig_partitions(i,  indx_part1(i,1):indx_part1(i,2),1) = Tstsig_spec2D(i,  indx_part1(i,1):indx_part1(i,2));
      Sig_partitions(i,  indx_part1(i,2)+1:indx_part1(i,3),2) = Tstsig_spec2D(i,   indx_part1(i,2)+1:indx_part1(i,3));
      Sig_partitions(i,  indx_part1(i,3)+1:indx_part1(i,4),3) = Tstsig_spec2D(i,  indx_part1(i,3)+1:indx_part1(i,4));
  end
    
 end

RFlin_spec2D = [];
for kk = 1:size(Sig_partitions,3)
    RFlin_spec2D = [RFlin_spec2D Sig_partitions(:,end:-1:1,kk).'];
end
%RFlin_spec2D = [Sig_partitions(:,end:-1:1,1).' Sig_partitions(:,end:-1:1,2).' Sig_partitions(:,end:-1:1,3).' Sig_partitions(:,end:-1:1,4).'];
%figure;imagesc(db(RFlin_spec2D));
%% Extracting Signals in specific freq band ;Take the signal in all the time or 1/2 the time
%cal energy vs Freq

ener = sum(abs(RFlin_spec2D).^2,1);
% sig_len = [];
% dB_BW = 10;%%HAVE TO CHOOSE A PROPER dB BW VALUE
% Min_ener_threshold = -30;%dB
Signal_samp_cell = {};
Fc_start_indx = freq_maxindx(1);
for i = 1:size(Fc_BW_sigs,1)
    %UNCOMMENT AFTER DEBUG
    Fc_i = Fc_BW_sigs(i,1);
    BW_i = Fc_BW_sigs(i,2);
    Band_start = Fc_i - (BW_i/2);
    Band_stop =  Fc_i + (BW_i/2);
    delta_f_Hz = ([Band_start,Band_stop]-tone_start_freq);
    delta_f_indx  = delta_f_Hz*(Nfft/Fs);
    delta_f_start = floor(delta_f_indx(1)) ; 
    delta_f_stop = ceil(delta_f_indx(2));
    
    Band_start= Fc_start_indx +delta_f_start;
    Band_stop= Fc_start_indx +delta_f_stop;
    
    sig_indx = [Band_start :Band_stop];
    if(length(sig_indx)>80)
        sig_indx = [-40:39]+sig_indx(length(sig_indx)/2);
    end
    %sig_indx = [Band_indx(1) :Band_indx(2)];
    %sig_indx =[90:110];
    %sig_indx = [42 : 121];%set sig-indx < 80

    sig_spec = RFlin_spec2D(:,sig_indx);
    %getting only non zeros time blks
    ener_time = sum(abs(sig_spec).^2,2);
    [time_indx] = find(ener_time~=0);
    sig_spec = sig_spec(time_indx,:) ;
    
    %removing this signal to detect further more
    %RFlin_spec2D(:,sig_indx) =0;
    no_zerocols_left = floor((Nfft-length(sig_indx))/2);
    fin_signal = [zeros(length(time_indx),no_zerocols_left) sig_spec zeros(length(time_indx),Nfft-length(sig_indx)-no_zerocols_left) ];
    
    
    fin_signal_DCcentred = fftshift(fin_signal,2);
    [x_istft, t_istft] = istft(flipud(fin_signal_DCcentred).', Nfft, Nfft, Nfft, 25e6);
    
%      aa2 = invspecgram(fin_signal_DCcentred.',Nfft,25e6,Nfft,Nfft/2);
%      aa1 = aa2(end:-1:1);
     %figure;spectrogram((aa1(:)),rectwin(Nfft),Nfft/2,Nfft);
%      [Rx_alpha] = CAF_datagen_25msps(x_istft,1);
%      Rx_alpha(196:203,51)=0;    bb = abs(Rx_alpha);
%      bb = bb-min(bb(:));bb = bb/max(bb(:));
%     alpha = linspace(-1/10,1/10-1/(100*5),100);tau = -200:199 ;
%      figure;imagesc(alpha,tau,bb);xlabel('\alpha -1/10:1/500 :1/10 (Cyclic Freq)');ylabel('\tau (Delay)');
%      
%      [Sx_alpha] = CAF_datagen_25msps(x_istft,0);aa = db(Sx_alpha);
%      aa = aa-min(aa(:));aa = aa/max(aa(:));aa(:,51)=0;
%      alpha = linspace(-1/5,1/5-1/(250),100);
%      figure;imagesc(alpha,tau,aa);xlabel('\alpha -1/5:1/250 :1/5 (Cyclic Freq)');ylabel('Delay Freq(f) ');
    %sig_overlapped = ifft(fin_signal_DCcentred,Nfft,2);
    
    %sig_overlapped1 = sig_overlapped(1:2:end,:);%since overlapped by half
    %Have to output these signal samples in matrix
    ener = sum(abs(RFlin_spec2D).^2,1);
    Signal_samp_cell = [Signal_samp_cell;x_istft];
    
end




end