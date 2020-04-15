# arpav-valori-aria
fetch.sh esporta i dati dell'ARPAV relativi al PM10 e all'Ozono
I dati [Open Data dell'ARPAV](https://www.arpa.veneto.it/dati-ambientali/open-data/dati-arpav-in-formato-xml) relativi al PM10 e all'Ozono forniti in JSON, vengono elaborati dal file fatch.sh e salvati in un database locale MySQL.

La struttura del database prevede, una tabella "stazioni" contenente le informazioni delle stazioni (codice, localizzazzione, comune e nome) e una tabella per ogni centralina, identificata tramite il suo codice.

Tali tabelle, sono create o aggiunte dinamicamente ad ogni esecuzione dello script, che viene richiamato dal cron alla mezza di ogni ora, con il comando:
```
#ARPAV
30 *    * * *   root    bash /home/ubuntu/arpav/fetch.sh
```

fetch_meteo.sh esporta i dati relativi alla velocità del vento, direzione, temperatura, radiazione solare e umidità di quattro stazioni meteo trevigiane. I dati sono poi salvati in altrettante tabelle. La struttura di tali tabelle è presente nel file tezze.sql
Attualmente questi dati vengono aggiornati quotidianamente verso le 21, come è possibile vedere da [qui](https://www.arpa.veneto.it/bollettini/meteo/h24/img21/Graf_185.htm?sens=TEMP). Eseguendo lo script ogni 3 giorni si perdano le ultime 2 rilevazioni dell'ultimo giorno.
Per gli scopi attuali questo non rappresenta un problema.
