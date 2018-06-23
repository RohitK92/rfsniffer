%Cyclo stationarity concept - Script for testing CAF for signals in general

 %corr = 1;%1=>CAF 0=> SCF
 function[RX_SX_alpha] = CAF_datagen_25msps(xn,alpha,tau,corr)

 %tau = -256:1:255;%delay
 %tau = -128:1:127;
 %tau = -160:1:159;
 %tau = -200:1:199;
 %tau = -64:1:64;
 %alpha= (-1:1/480:1);
 %corr=1;
if(corr)
    %Nfft =1024;
    %Nfft = 800;
   % alpha = (-10/(80):1/(10*80):(10/80)-1/800);%for OFDM peaks in RX_alpha
    %alpha = linspace(-1/8,1/8-1/(80*4),80);%ORIGINAL with 20MSPS
   %alpha = linspace(-1/10,1/10-1/(100*5),100);%ORIGINAL with 25MSPS
    
    %alpha = (-Nfft/2:1:Nfft/2 - 1)/Nfft;
    Rx_alpha = zeros(length(tau),length(alpha));
   %Rx_alpha = zeros(length(tau),800);
   %xn_mult_mx  = zeros(length(xn),length(tau)) ;
   
   DFT_alphamx = exp(-1i*2*pi*(1:length(xn)).'*alpha);
   xn_tau = zeros(length(tau),length(xn));
 for j = 1:length(tau) 
     if(tau(j)>=1)
          xn_tau(j,:) = [zeros(1,tau(j)) xn(1:end-tau(j))];
     else
         xn_tau(j,:) = [xn(1-tau(j):end) zeros(1,-tau(j))];
     end    
 end
%      xn_mult = xn.*conj(xn_tau);
%xn = xn.*ones(length(tau),1);
xn_mult = xn.*conj(xn_tau);
          
    % Rx_alpha(j,:) = fftshift(fft(xn_mult,Nfft));%get 400+(-30,30)
%          for i = 1:length(alpha)
%               Rx_alpha(j,i) = sum(xn_mult.*exp(-1i*2*pi*alpha(i)*(1:length(xn))));
%          end
     %Rx_alpha(j,:) = xn_mult*DFT_alphamx;
     Rx_alpha = xn_mult*DFT_alphamx;
     %Rx_alpha(j,:) = xn_mult*exp(-1i*2*pi*(1:length(xn)).'*alpha);
    %Rx_alpha(j,:) = fftshift(fft(xn_mult,800));%sum(xn_mult.*exp(-1i*2*pi*alpha(i)*(1:length(xn)));

%  end


% alpha_pks = (abs(Rx_alpha(floor(length(tau)/2)-64+1,101+(-30:10:30))));
% alpha_pks1 = (abs(Rx_alpha(floor(length(tau)/2)+64+1,101+(-30:10:30))));
 Mean_sig_pwr = abs(Rx_alpha(floor(length(tau)/2)+1,(floor(length(alpha)/2)+1)));%gettig Rx_alpha(tau) - alpha,tau =0
% Cycpks_to_meanpwr = -10*log10(Mean_sig_pwr/mean([alpha_pks alpha_pks1]));
Rx_alpha = Rx_alpha/Mean_sig_pwr;
RX_SX_alpha = Rx_alpha;
else
    N_Delay = length(tau);
    %Nfft= length(tau);
    %Nfft =320;
    Nfft =400;%4*100
    %Nfft =128;
    
   %Nfft =800;
    %Nfft =1024;
    Nsample_blk = 512;
    len_rnd = floor((length(xn)/Nsample_blk))*Nsample_blk;
    xn_blk = reshape(xn(1:len_rnd),Nsample_blk,[]);
    %len_rnd = floor((length(xn)/N_Delay))*N_Delay;
    %xn_blk = reshape(xn(1:len_rnd),N_Delay,[]);
    xn_f = fftshift(fft(xn_blk,Nfft,1));
    %N_alpha = N_Delay ;
    %alpha = tau/length(tau);%alpha :  -0.5 to 0.5
     %alpha = (-Nfft/2:1:Nfft/2 - 1)/Nfft;
     
     %alpha = -1/8:1/Nfft:(1/8 -(1/Nfft));
    
      %alpha = linspace(-1/8,1/8-1/(800),800);
      
     %alpha = linspace(-1/8,1/8-1/(160),40);
    %alpha = linspace(-1/4,1/4-1/(160),80);%ORIGINAL with 20MSPS
    %alpha = linspace(-1/5,1/5-1/(250),100);%ORIGINAL with 25MSPS
     N_alpha = length(alpha) ;
     %N_alpha = Nfft;
     Sx_alpha = zeros(Nfft,N_alpha);
    
    %xn_fdeli_1 = zeros([size(xn_f),N_alpha]);
    %xn_fdeli_2 = zeros([size(xn_f),N_alpha]);
    for i = 1:N_alpha%Iter over alpha = 1:1/512(@delay = 1:512)
        %Xn_fdeli=circshift(Xn_f,int16(alpha(i)*Nfft),1);
         %Xn_fmult = Xn_f.*conj(Xn_fdeli);
        
         %xn_fdeli_1=circshift(xn_f,int16(alpha(i)*Nfft/2),1);%Xn(f-alpha/2)
         %xn_fdeli_2=circshift(xn_f,int16(-1*alpha(i)*Nfft/2),1);%Xn(f+alpha/2)'
         
         %xn_fdeli_1(:,:,i) = circshift(xn_f,int16(alpha(i)*Nfft/2),1);%Xn(f-alpha/2)
         %xn_fdeli_2(:,:,i) = circshift(xn_f,int16(-1*alpha(i)*Nfft/2),1);%Xn(f+alpha/2);
         
         xn1 = xn.*exp(1i*pi*alpha(i)*(1:length(xn)));%Xn(f+alpha/2)
         xn2 = xn.*exp(-1i*pi*alpha(i)*(1:length(xn)));
         len_rnd = floor((length(xn)/Nsample_blk))*Nsample_blk;
         
         xn_blk1 = reshape(xn1(1:len_rnd),Nsample_blk,[]);
         xn_blk2 = reshape(xn2(1:len_rnd),Nsample_blk,[]);
         Xnf1 = spectrogram(xn_blk1(1:len_rnd),Nsample_blk,0,Nfft,'centered');
         Xnf2 = spectrogram(xn_blk2(1:len_rnd),Nsample_blk,0,Nfft,'centered');
         %Xnf1 = fftshift(fft(xn_blk1,Nfft,1));
         %Xnf2 = fftshift(fft(xn_blk2,Nfft,1));
         Sx_alpha(:,i) = sum(Xnf2.*conj(Xnf1),2)/size(Xnf1,2);
    end
    
         %Xn_fmult = xn_fdeli_1.*conj(xn_fdeli_2);%S_uv(f)
%         Xn_alpha_1 = xn_fdeli_1.*conj(xn_fdeli_1);%S_u(f)
 %        Xn_alpha_2 = xn_fdeli_2.*conj(xn_fdeli_2);%S_v(f)
         
%          Sx_alpha1 = squeeze(sum(Xn_alpha_1,2)/size(xn_blk,2));
%          Sx_alpha2 = squeeze(sum(Xn_alpha_2,2)/size(xn_blk,2));
%          norm = sqrt(Sx_alpha1.*Sx_alpha2);

        % Sx_alpha = squeeze(sum(Xn_fmult,2)/size(xn_blk,2));
        
         
         %Sx_alpha(:,i) = Sx_alpha(:,i)./norm;
    %end
    Avg_ener_Blk = mean(abs(xn).^2)*Nsample_blk;
    Sx_alpha = Sx_alpha/Avg_ener_Blk;
    RX_SX_alpha = Sx_alpha;
end
%figure;contour(linspace(-0.5,0.5,256),alpha,db(Sx_alpha));ylabel('alpha(pattern Freq)');xlabel('1/\tau (delay freq)')

end




