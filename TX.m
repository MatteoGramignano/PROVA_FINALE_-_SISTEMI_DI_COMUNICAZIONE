clear, close all
clc

%% INIZIALIZZAZIONE ADALM PLUTO

SamplingRate = 1e6; 
fc = 2.42e9; % Frequenza portante (carrier)

idTX='sn:1044730a199700040500230042a17ca7e6';

%% GENERAZIONE DATI RANDOM E MODULAZIONE QAM

M = 16; % Ordine della modulazione
nd = 1e6; % Numero di dati da generare
bps = log2(M); % [bits/symbol]

data = randi([0,1], [nd, 1]); % Generazione sequenza di bit

sig = qammod(data, M, InputType = "bit"); % Modulazione dati

%% FILTRO FORMATORE A COSENO RIALZATO

span = 80;      % Span del filtro in simboli
rolloff = 0.25; % Fattore di roll-off
sps = 4;        % Campioni per simbolo
% span = lungheza della finestra di lettura dei campioni
% sps = numero di campioni generati per ogni finestra letta

txfilter = comm.RaisedCosineTransmitFilter( ...
    RolloffFactor = rolloff, ...
    FilterSpanInSymbols = span, ...
    OutputSamplesPerSymbol = sps);

txSig = txfilter(sig); % Segnale filtrato

%% TRASMISSIONE CON LA PLUTO

txNorm = txSig/max(abs(txSig)); % Segnale trasmesso normalizzato

txPluto = sdrtx('Pluto', ...
       'RadioID',idTX, ...
       'CenterFrequency',fc, ...
       'Gain',-10, ... % Da imporre tra -89 and 0
       'BasebandSampleRate',SamplingRate);

transmitRepeat(txPluto,txNorm); % Trasmissione del segnale in ripetizione
