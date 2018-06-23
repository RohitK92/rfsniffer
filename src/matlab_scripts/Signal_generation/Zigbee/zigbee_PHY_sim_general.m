EcNo = -25:2.5:17.5;                % Ec/No range of BER curves
spc = 4;                            % samples per chip
msgLen = 8*120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message

% Preallocate vectors to store BER results:
[berOQPSK2450, berOQPSKrest, berBPSK, berASK915, ...
 berASK868, berGFSK] = deal(zeros(1, length(EcNo)));

for idx = 1:length(EcNo) % loop over the EcNo range

  % O-QPSK PHY, 2450 MHz
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '2450 MHz');
  K = 2;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '2450 MHz');
  [~, berOQPSK2450(idx)] = biterr(message, bits);

  % O-QPSK PHY, 780MHz / 868MHz / 915MHz
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '780 MHz'); % or '868 MHz'/'915 MHz'
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '780 MHz'); % or '868 MHz'/'915 MHz'
  [~, berOQPSKrest(idx)] = biterr(message, bits);

  % BPSK PHY, 868/915/950 MHz
  waveform = lrwpan.PHYGeneratorBPSK(message, spc);
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderBPSK(received, spc);
  [~, berBPSK(idx)] = biterr(message, bits);

  % ASK PHY, 915 MHz
  waveform = lrwpan.PHYGeneratorASK(message, spc, '915 MHz');
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderASK(received,  spc, '915 MHz');
  [~, berASK915(idx)] = biterr(message, bits(1:msgLen));

  % ASK PHY, 868 MHz
  waveform = lrwpan.PHYGeneratorASK(message, spc, '868 MHz');
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderASK(received,  spc, '868 MHz');
  [~, berASK868(idx)] = biterr(message, bits(1:msgLen));

  % GFSK PHY, 950 MHz
  waveform = lrwpan.PHYGeneratorGFSK(message, spc);
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderGFSK(received, spc);
  [~, berGFSK(idx)] = biterr(message, bits);
end

% plot BER curve
semilogy(EcNo, berOQPSK2450, '-o', EcNo, berOQPSKrest, '-*', EcNo, berBPSK, '-+', ...
         EcNo, berASK915,    '-x', EcNo, berASK868,    '-s', EcNo, berGFSK, '-v')
legend('OQPSK, 2450 MHz', 'OQPSK, 780/868/950 MHz', 'BPSK, 868/915/950 MHz', 'ASK, 915 MHz', ...
       'ASK, 868 MHz', 'GFSK, 950 MHz', 'Location', 'southwest')
title('IEEE 802.15.4 PHY BER Curves')
xlabel('Chip Energy to Noise Spectral Density, Ec/No (dB)')
ylabel('BER')
axis([min(EcNo) max(EcNo) 10^-2 1])
grid on