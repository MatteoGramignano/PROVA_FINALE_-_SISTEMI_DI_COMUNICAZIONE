Questo progetto riguarda la realizzazione di un sistema di comunicazione digitale completo utilizzando due dispositivi ADALM-PLUTO (PlutoSDR) e il software MATLAB. L’obiettivo è trasmettere e ricevere un segnale modulato in 16-QAM, cercando di ricostruire la costellazione nel modo più fedele possibile nonostante la presenza di rumore e distorsioni introdotte dal canale.

Durante lo sviluppo, particolare attenzione è stata posta alla progettazione del ricevitore, che deve compensare effetti indesiderati come rumore, sfasamento tra i dispositivi e disallineamento temporale del segnale. Questi fenomeni sono casuali e indipendenti tra loro, e rappresentano le principali difficoltà nella corretta ricezione del segnale.

Per valutare le prestazioni del sistema sono stati utilizzati due parametri fondamentali: il BER (Bit Error Ratio) e l’EVM (Error Vector Magnitude), che permettono di quantificare rispettivamente gli errori di trasmissione e la distorsione della costellazione ricevuta.

I risultati sperimentali mostrano che le prestazioni del sistema dipendono fortemente dall’ambiente di trasmissione e dalla potenza del segnale. In ambienti chiusi e rumorosi, caratterizzati ad esempio dalla presenza di interferenze Wi-Fi, il segnale risulta maggiormente distorto e i valori di BER ed EVM peggiorano. Al contrario, in spazi aperti il rumore ha un impatto minore e le prestazioni risultano migliori.

In conclusione, il progetto evidenzia come sia possibile implementare un sistema di comunicazione reale con SDR e come l’analisi di BER ed EVM sia essenziale per comprenderne il comportamento in condizioni operative realistiche.
