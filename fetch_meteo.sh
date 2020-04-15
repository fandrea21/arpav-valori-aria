#!/bin/bash
URLTEZZE='https://www.arpa.veneto.it/bollettini/meteo/h24/img21/0185.xml'
URLTREVISO='https://www.arpa.veneto.it/bollettini/meteo/h24/img21/0220.xml'
URLCONEGLIANO='https://www.arpa.veneto.it/bollettini/meteo/h24/img21/0100.xml'
URLCRESPANO='https://www.arpa.veneto.it/bollettini/meteo/h24/img21/0156.xml'
CENTRALINE=()
#L'ordine delle variabili nell'array è importante per l'inserimento dei dati nel DB
CENTRALINE=($URLTEZZE $URLTREVISO $URLCONEGLIANO $URLCRESPANO)


ISUP=($(curl  -Is $URLTEZZE  | head -n 1 | awk '{print $2}'))
if [ $ISUP == '200' ]
then
echo "Internet ok"
else
	sleep 780
fi

#Per ogni Centralina
for ((c=0;c < ${#CENTRALINE[@]}; ++c)); do
TEMPERATURA=()
UMIDITA=()
RADIAZIONE=()
PRECIPITAZIONE=()
VELOCITA=()
DIREZIONE=()
ORA=()

/usr/bin/curl -s -X GET -H 'Content-type: text/xml' ${CENTRALINE[$c]} -o ./$c.xml

#Calcoal il numero di dati presenti
NRDATI="$(/usr/bin/xmllint --xpath "count(/CONTENITORE/STAZIONE/SENSORE[1]/DATI)" $c.xml)"
#Per ogni sensore
for ((s=1;s < 7; ++s)); do
TIPOSENSORE="$(/usr/bin/xmllint --xpath "string(/CONTENITORE/STAZIONE/SENSORE[$s]/PARAMNM)" $c.xml)"
#Per ogni dato
for ((d=1;d <= $NRDATI; ++d)); do
DATO="$(/usr/bin/xmllint --xpath "string(/CONTENITORE/STAZIONE/SENSORE[$s]/DATI[$d])" $c.xml)"
TEMPORA="$(/usr/bin/xmllint --xpath "string(/CONTENITORE/STAZIONE/SENSORE[$s]/DATI[$d]/@ISTANTE)" $c.xml)"
year="${TEMPORA:0:4}"
month="${TEMPORA:4:2}"
day="${TEMPORA:6:2}"
hour="${TEMPORA:8:2}"
minute="${TEMPORA:10:2}"
ORA+=("$year-$month-$day $hour:$minute")

case $TIPOSENSORE in
	"Temperatura aria a 2m")
		TEMPERATURA+=($DATO);;
	"Umidità relativa a 2m")
		UMIDITA+=($DATO);;
	"Precipitazione")
		PRECIPITAZIONE+=($DATO);;
	"Radiazione solare globale")
		RADIAZIONE+=($DATO);;
	"Velocità vento a 10m"|"Velocità vento a 5m")
		VELOCITA+=($DATO);;
	"Direzione vento a 10m"|"Direzione vento a 5m")
		DIREZIONE+=($DATO);;
		*)
		;;
esac
done
done

#SALVO I DATI NEL DB
case $c in
	0)
	#TEZZE
	for ((i=0;i<${#UMIDITA[@]};++i)); do
/usr/bin/mysql --defaults-file=/home/ubuntu/arpav/my.cnf -Darpav -se "INSERT INTO tezze (datetime,temperatura,precipitazione,unidita,velocita,direzione,radiazione) VALUES ('${ORA[$i]}','${TEMPERATURA[$i]}','${PRECIPITAZIONE[$i]}','${UMIDITA[$i]}','${VELOCITA[$i]}','${DIREZIONE[$i]}','${RADIAZIONE[$i]}');"
done
	;;
	1)
	#TREVISO
	for ((i=0;i<${#UMIDITA[@]};++i)); do
/usr/bin/mysql --defaults-file=/home/ubuntu/arpav/my.cnf -Darpav -se "INSERT INTO treviso (datetime,temperatura,precipitazione,unidita,velocita,direzione,radiazione) VALUES ('${ORA[$i]}','${TEMPERATURA[$i]}','${PRECIPITAZIONE[$i]}','${UMIDITA[$i]}','${VELOCITA[$i]}','${DIREZIONE[$i]}','${RADIAZIONE[$i]}');"
done
	;;
	2)
	#CONEGLIANO
	for ((i=0;i<${#UMIDITA[@]};++i)); do
/usr/bin/mysql --defaults-file=/home/ubuntu/arpav/my.cnf -Darpav -se "INSERT INTO conegliano (datetime,temperatura,precipitazione,unidita,velocita,direzione,radiazione) VALUES ('${ORA[$i]}','${TEMPERATURA[$i]}','${PRECIPITAZIONE[$i]}','${UMIDITA[$i]}','${VELOCITA[$i]}','${DIREZIONE[$i]}','${RADIAZIONE[$i]}');"
done
	;;
	3)
	#CRESPANO
	for ((i=0;i<${#UMIDITA[@]};++i)); do
/usr/bin/mysql --defaults-file=/home/ubuntu/arpav/my.cnf -Darpav -se "INSERT INTO crespano (datetime,temperatura,precipitazione,unidita,velocita,direzione,radiazione) VALUES ('${ORA[$i]}','${TEMPERATURA[$i]}','${PRECIPITAZIONE[$i]}','${UMIDITA[$i]}','${VELOCITA[$i]}','${DIREZIONE[$i]}','${RADIAZIONE[$i]}');"
done
	;;
	*)
	;;
esac


rm -f ./$c.xml

done

