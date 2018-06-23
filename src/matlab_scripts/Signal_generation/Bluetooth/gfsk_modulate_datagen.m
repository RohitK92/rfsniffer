function [ y ] = gfsk_modulate_datagen(x)

load gfsk_Parameters.mat
%load gf

t = [1:(nsamp*length(x))]*(1/Fs);
gaussFilter = gaussdesign(0.5, 3, nsamp); 
%not compatible with 2012a.


gamma_fsk = zeros(1,length(t));
for i=1:length(x)
    gamma_fsk((((i-1)*nsamp)+1):(i*nsamp)) = ((x(i)*2)-1);
end
gamma_gfsk = filter(gaussFilter, 1, gamma_fsk);
%gamma_gfsk = gamma_fsk;
gfsk_phase = (freqsep/Fs)*pi*cumtrapz(gamma_gfsk);
y = exp(1i*gfsk_phase);
y = y.';

end