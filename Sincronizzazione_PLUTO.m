%% SCRIPT SINCRONIZZAZIONE PLUTO
% Frequency Correction for ADALM-PLUTO Radio

% Codice standard per sincronizzazione PLUTO: calcolo del parametro frequencyCorrection

%% DEFINIZIONE DATI E TRASMISSIONE TONI

sampleRate = 200e3;
centerFreq = 2.42e9;
fRef = 80e3;
s1 = exp(1j*2*pi*20e3*[0:10000-1]'/sampleRate); % 20 kHz
s2 = exp(1j*2*pi*40e3*[0:10000-1]'/sampleRate); % 40 kHz
s3 = exp(1j*2*pi*fRef*[0:10000-1]'/sampleRate); % 80 kHz
s = s1 + s2 + s3;
s = 0.6*s/max(abs(s)); % Ridimensionamento del segnale per evitare il clipping nel dominio del tempo

% Imposta il trasmettitore
% Utilizzo del valore predefinito di 0 per FrequencyCorrection, che corrisponde alla condizione calibrata in fabbrica
tx = sdrtx('Pluto', 'RadioID', 'sn:1044730a199700040500230042a17ca7e6', 'CenterFrequency', centerFreq, ...
           'BasebandSampleRate', sampleRate, 'Gain', 0, ...
           'ShowAdvancedProperties', true);
txRadioInfo = info(tx)
% Invio dei segnali
disp('Send 3 tones at 20, 40, and 80 kHz');
transmitRepeat(tx, s);

% Set up del ricevitore
% Utilizzo del valore predefinito di 0 per FrequencyCorrection, che corrisponde alla condizione calibrata in fabbrica
numSamples = 1024*1024;
rx = sdrrx('Pluto', 'RadioID', 'sn:1044730a199700160a001a0037067c7ac4', 'CenterFrequency', centerFreq, ...
           'BasebandSampleRate', sampleRate, 'SamplesPerFrame', numSamples, ...
           'OutputDataType', 'double', 'ShowAdvancedProperties', true);
rxRadioInfo = info(rx)

%% RICEZIONE E VISUALIZZAZIONE TONI SFASATI

disp(['Capture signal and observe the frequency offset' newline])
receivedSig = rx();

% Si trova il tono che corrisponde al tono trasmesso a 80 kHz
y = fftshift(abs(fft(receivedSig)));
[~, idx] = findpeaks(y,'MinPeakProminence',max(0.5*y));
fReceived = (max(idx)-numSamples/2-1)/numSamples*sampleRate;

% Plot dello spettro
sa = spectrumAnalyzer('SampleRate', sampleRate);
sa.Title = sprintf('Tone Expected at 80 kHz, Actually Received at %.3f kHz', ...
                   fReceived/1000);
receivedSig = reshape(receivedSig, [], 16); % Reshaping in 16 colonne
for i = 1:size(receivedSig, 2)
    sa(receivedSig(:,i));
end

%% CALCOLO PARAMETRO FREQUENCY CORRECTION

rx.FrequencyCorrection = (fReceived - fRef) / (centerFreq + fRef) * 1e6;
msg = sprintf(['Based on the tone detected at %.3f kHz, ' ...
               'FrequencyCorrection of the receiver should be set to %.4f'], ...
               fReceived/1000, rx.FrequencyCorrection);
disp(msg);
rxRadioInfo = info(rx)

%% RICEZIONE E VISUALIZZAZIONE TONI ALLINEATI

% Acquisisci 10 frame, ma usa solo l’ultimo frame per evitare gli effetti transitori dovuti 
% alla variazione di FrequencyCorrection
disp(['Capture signal and verify frequency correction' newline])
for i = 1:10
    receivedSig = rx();
end

% Trova il tono che corrisponde al tono trasmesso a 80 kHz
% f_Received2 dovrebbe essere molto vicino a 80 kHz
y = fftshift(abs(fft(receivedSig)));
[~,idx] = findpeaks(y,'MinPeakProminence',max(0.5*y));
fReceived2 = (max(idx)-numSamples/2-1)/numSamples*sampleRate;

% Plot dello spettro
sa = spectrumAnalyzer('SampleRate', sampleRate);
sa.Title = '3 Tones Received at 20, 40, and 80 kHz';
receivedSig = reshape(receivedSig, [], 16); % Reshape into 16 columns
for i = 1:size(receivedSig, 2)
    sa(receivedSig(:,i));
end
msg = sprintf('Tone detected at %.3f kHz\n', fReceived2/1000);
disp(msg);

%% RILASCIO PLUTO

release(tx), release(rx)
