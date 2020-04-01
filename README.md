# arpav-valori-aria
Esporta i dati dell'ARPAV relativi al PM10 e all'Ozono
I dati [Open Data dell'ARPAV](https://www.arpa.veneto.it/dati-ambientali/open-data/dati-arpav-in-formato-xml) relativi al PM10 e all'Ozono forniti in JSON, vengono elaborati dal file fatch.sh e salvati in un database locale MySQL.

La struttura del database prevede, una tabella "stazioni" contenente le informazioni delle stazioni (codice, localizzazzione, comune e nome) e una tabella per ogni centralina, identificata tramite il suo codice.

Tali tabelle, sono create o aggiunte dinamicamente ad ogni esecuzione dello script, che viene richiamato dal cron alla mezza di ogni ora, con il comando:
```
#ARPAV
30 *    * * *   root    bash /home/ubuntu/arpav/fetch.sh
```
