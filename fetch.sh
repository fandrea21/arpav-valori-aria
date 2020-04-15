#!/bin/bash

#CONTROLLARE CHE L'ORA DELL'ULTIMO VALORE SIA MINORE DI QUELLO RECUPERATO DALLA QUERY

STAZIONI="http://213.217.132.81/aria-json/exported/aria/stats.json"
VALORI="http://213.217.132.81/aria-json/exported/aria/data.json"

#VERIFICARE SE RISROSA ESISTE
ISUP=($(curl  -Is $STAZIONI  | head -n 1 | awk '{print $2}'))
if [ $ISUP == '200' ]
then
echo "Internet ok"
else
	sleep 780
fi

#RECUPERO I DATI JSON
STAZ_DATA=$(curl -s -X GET -G -H 'Accept: application/json' $STAZIONI  | jq '.stazioni')
VAL_DATA=$(curl -s -X GET -G -H 'Accept: application/json' $VALORI  | jq '.stazioni')

#SALVO IL NOME DEI COMUNI IN CUI SONO PRESENTI LE CENTRALINE E I RELATIVI CODICI
STNOME="$(echo -n $STAZ_DATA | jq -a '.[].nome' | tr "\n" "#")"
#STCOMUNE="$(echo -n $STAZ_DATA | jq '.[].comune'| tr "\n" "#")"
STPROV=($(echo $STAZ_DATA | jq '.[].provincia'| tr "\"" "\n"))
STLAT=($(echo -n $STAZ_DATA | jq '.[].lat'| tr "\"" "\n"))
STLON=($(echo $STAZ_DATA | jq '.[].lon'| tr "\"" "\n"))
STKEY=($(echo $STAZ_DATA | jq '.[].codseqst' | tr "\"" "\n"))

VALKEY=($(echo $VAL_DATA | jq '.[].codseqst' | tr "\"" "\n"))


# INSERISCO I VALORI VERIFICANDO NON SIANO GIà PRESENTI
ARRAY=()
ARRCOMUNE=()
IFSORIGIALE=$IFS
IFS="#"
read -r -a ARRAY <<< "$STNOME"
#read -r -a ARRCOMUNE <<< "$STCOMUNE"
IFS=$IFSORIGIALE

#echo ${ARRCOMUNE[@]}

#for ((a=0;a < ${#ARRAY[@]}; ++a)); do
#Manca il comune per via dei caratteri spaeciali(pieve D'alpago Fino Al 22/02/2016)" "San Dona' Di Piave" "Conegliano" "Mansue'"
#/usr/bin/mysql --defaults-file=/home/ubuntu/arpav/my.cnf -Darpav -se "INSERT IGNORE INTO stazioni (nome,provincia,lat,lon,codseqst) VALUES ('${ARRAY[$a]}','${STPROV[$a]}','${STLAT[$a]}','${STLON[$a]}','${STKEY[$a]}');"
#done

#date


 for sk in "${STKEY[@]}"
 do
	 for sv in "${VALKEY[@]}"
	 do
		if [ "$sk" == "$sv" ]
		 then
			#SE I CODICI DELLA CENTRALINA COINCIDONO RECUPERO LA MISURAZIONE DEL ULTIMO GIORNO
			DATA=$(echo $VAL_DATA | jq --arg sk "$sk" '.[] | select(.codseqst==$sk) | .misurazioni[].pm10[-1].data'| tr "\"" "\n" | tr "null \"" "\n")
			PM10=$(echo $VAL_DATA | jq --arg sk "$sk" '.[] | select(.codseqst==$sk) | .misurazioni[].pm10[-1].mis' | tr "\"" "\n" | tr "null \"" "\n")
			OZONO=$(echo $VAL_DATA | jq --arg sk "$sk" '.[] | select(.codseqst==$sk) | .misurazioni[].ozono[-1].mis' | tr "\"" "\n" | tr "null \"" "\n")
			
			#Se il sensore non ha il valori di pm10 non ha la data quindi ricerco nuovamente la data nelle misurazioni dell'ozono
			if [ -z "$DATA" ]
			then
				DATA=$(echo $VAL_DATA | jq --arg sk "$sk" '.[] | select(.codseqst==$sk) | .misurazioni[].ozono[-1].data'| tr "\"" "\n" | tr "null \"" "\n")
			fi
			
			#CREO LE TABELLE CON IL CODICE DELLA CENTRALLINA
				/usr/bin/mysql --defaults-file=/home/ubuntu/arpav/my.cnf -Darpav << MYSQL
CREATE TABLE IF NOT EXISTS \`${sk}\` (id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,datetime DATETIME NULL DEFAULT NULL, pm10 DECIMAL(10,3) NULL DEFAULT NULL,ozono DECIMAL(10,5) NULL DEFAULT NULL );
MYSQL

			# INSERISCO I VALORI
			/usr/bin/mysql --defaults-file=/home/ubuntu/arpav/my.cnf -Darpav -se "INSERT INTO \`${sk}\` (datetime,pm10,ozono) VALUES ('${DATA}','${PM10}','${OZONO}');"
			
		 fi
	 done
 done
