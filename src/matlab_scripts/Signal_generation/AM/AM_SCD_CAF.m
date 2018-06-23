[y,Fs] = audioread('AM_IQ.wav');%Fs = 64KHz
aa1 = decimate(y(1:1e5,1),4);

alpha = linspace(-1/10,1/10-1/(100*5),500);tau = -200:1:199;[Rx_alpha] = CAF_datagen_25msps(aa1.',alpha,tau,1);
figure;imagesc(alpha,tau,db(Rx_alpha))
alpha = linspace(-1/10,1/10-1/(100*5),500);tau = -200:1:199;[Sx_alpha] = CAF_datagen_25msps(aa1.',alpha,tau,0);
figure;imagesc(alpha,tau,db(Sx_alpha))

fftplot(aa1,Fs/4,11,'r',1);
