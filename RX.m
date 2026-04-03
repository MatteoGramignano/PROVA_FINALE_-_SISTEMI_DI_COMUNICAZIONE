%% INIZIALIZZAZIONE PLUTO

SamplingRate = 1e6;
fc = 2.42e9; % Frequenza portante (carrier)
 
idRX = 'sn:1044730a199700160a001a0037067c7ac4';

rxPluto = sdrrx('Pluto', ...
    'RadioID', idRX, ...
    'CenterFrequency',fc, ...
    'GainSource','AGC Slow Attack', ...
    ... 'GainSource','Manual', ...
    ... 'Gain',65, ...
    'OutputDataType','single', ...
    'BasebandSampleRate',SamplingRate, ...
    'ShowAdvancedProperties', true, ...
    'FrequencyCorrection', 0.8250); 

%% RICEZIONE DATI

[rxWave,rx_meta]=capture(rxPluto,4e6); % Ricezione dati

%% CROSS-CORRELAZIONE E ALLINEAMENTO SEGNAlE RICEVUTO

% Cross-correlazione tra segnale ricevuto e segnale trasmesso
[acor,lag] = xcorr(rxWave,txNorm(1:1e3)); 

[acormax,I] = max(abs(acor)); % Trova il valore del picco massimo (acormax) e la sua posizione (I)
lagDiff = lag(I); % Calcolo ritardo per allineamento segnali

if lagDiff > 0 % Il segnale ricevuto è disallineato rispetto al segnale trasmesso ed è in ritardo di lagDiff campioni
    salign=circshift(rxWave,-lagDiff);
else % Il segnale ricevuto è disallineato rispetto al segnale trasmesso ed è in anticipo di lagDiff campioni
    salign=circshift(rxWave,+lagDiff);
end

%% FILTRAGGIO CON FILTRO ADATTATO A COSENO RIALZATO

span = 80;      % Span del filtro in simboli
rolloff = 0.25; % Fattore di roll-off
sps = 4;        % Campioni per simbolo
% span = lungheza della finestra di lettura dei campioni
% sps = numero di campioni generati per ogni finestra letta

rxfilter = comm.RaisedCosineReceiveFilter( ...
    RolloffFactor = rolloff, ...
    FilterSpanInSymbols = span, ...
    InputSamplesPerSymbol = sps, ...
    DecimationFactor = sps);

rxSig = rxfilter(salign); % Segnale ricevuto filtrato


%% SINCRONIZZAZIONE

M = 16; % Ordine modulazione

% Correzione grezza dell'errore di fase introdotto dalle Pluto
coarseSync = comm.CoarseFrequencyCompensator( ...
    'Modulation','QAM', ...
    'FrequencyResolution',1, ...
    'SampleRate',SamplingRate);

syncCoarse = coarseSync(rxSig);

% Correzione raffinata dell'errore di fase introdotto dalle Pluto
fineSync = comm.CarrierSynchronizer( ...
    'DampingFactor',0.707, ...
    'NormalizedLoopBandwidth',0.01, ...
    'SamplesPerSymbol',sps, ...
    'Modulation','QAM');

rxData = fineSync(syncCoarse); % Dati sincronizzati temporalmente

scatterplot(rxData);

%% EVM

referenceqam = qammod(0:15,16,'UnitAveragePower',true); % Costellazione di reference ideale

referenceqam_norm = normalize(referenceqam); % Normalizzazione della costellazione di reference
rxData_norm = rxData/mean(abs(rxData)); % Normalizazione della costellazione ricevuta

% Visualizzazione costellazione di reference e ricevuta, normalizzate e sovrapposte
figure()
s = scatter(real(rxData_norm),imag(rxData_norm),'r','filled');
hold on
v = scatter(real(referenceqam_norm),imag(referenceqam_norm),'filled','g');
s.SizeData = 10;
v.SizeData = 40;
grid on

a = abs(rxData_norm - referenceqam_norm); % Calcolo il valore assoluto della differenza 
% tra ogni punto ricevuto e ogni punto di reference
evm_all = min(a,[],2); % Per ogni punto ricevuto, seleziona il valore minimo della differenza 
% tra il punto ricevuto e ogni punto della reference
evm = mean(evm_all) % Media le distanze minime


%% BER

rxDatademod=qamdemod(rxData_norm,M,OutputType='bit', ...
    UnitAveragePower='true'); % Demodulazione da simboli ricevuti a bit

[number,ratio] = biterr(rxDatademod,data) % Calcolo del BER

%% POTENZA SEGNALE

[wd,lo,hi,power] = obw(rxData,SamplingRate);
powtot = power/0.99;

pw_db=10*log10(powtot)
