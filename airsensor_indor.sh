
#!/bin/bash
sleeptime=15

get_info () {
	DATA="$(curl  http://192.168.97.100 -w 0.01 -s)"
    serial=`(echo $DATA | awk -F "MODEL" '{print $1}' | awk -F "open=" '{print $2}' | grep -o '[0-9,A-Z]\+[0-9,A-Z]\+')`
	temp=`(echo $DATA | awk -F '<b>' '{print $2}'  | egrep  -o '[0-9]{1,2}.[0-9]{1,2}')`
	hum=`(echo $DATA | awk -F '<b>' '{print $3}'  | egrep  -o '[0-9]{1,2}.[0-9]{1,2}')`
	co2=`(echo $DATA | awk -F '<b>' '{print $4}'  | awk -F '</b>' '{print $2}' | egrep  -o '[0-9]{1,4}')`
	o3=`(echo $DATA | awk -F '<b>' '{print $5}'  | awk -F "</b>" '{print $2}' | egrep  -o '[0-9]{1,4}')`
	no2=`(echo $DATA | awk -F '<b>' '{print $6}'  | awk -F "</b>" '{print $2}' | egrep  -o '[0-9]{1,4}')`
	ch20=`(echo $DATA | awk -F '<b>' '{print $7}'  | awk -F "</b>" '{print $2}' | egrep  -o '[0-9]{1,4}')`
	co=`(echo $DATA | awk -F '<b>' '{print $8}'  | awk -F "</b>" '{print $2}' | egrep  -o '[0-9]{1,4}.+[0-9]{1,2}')`
	voc=`(echo $DATA | awk -F '<b>' '{print $9}'  | egrep  -o '[0-9]{1,4}')`
	pm1=`(echo $DATA | awk -F '<b>' '{print $10}'  | awk -F "</b>" '{print $2}' | awk -F "m" '{print $1}'| egrep  -o '[0-9]{1,4}')`
	pm2=`(echo $DATA | awk -F '<b>' '{print $11}'  | awk -F "</b>" '{print $2}' | awk -F "m" '{print $1}'| egrep  -o '[0-9]{1,4}')`
	pm10=`(echo $DATA | awk -F '<b>' '{print $12}'  | awk -F "</b>" '{print $2}' | awk -F "m" '{print $1}'| egrep  -o '[0-9]{1,4}')`
	interval=`(echo $DATA | awk -F '<b>' '{print $13}'  | egrep  -o '[0-9]{1,9}+')`

}

write_data () {
     #Write the data to the database
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=temp value=$temp"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=hum value=$hum"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=co2 value=$co2"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=o3 value=$o3"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=no2 value=$no2"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=ch20 value=$ch20"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=co value=$co"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=voc value=$voc"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=pm1 value=$pm1"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=pm2 value=$pm2"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=pm10 value=$pm10"
     curl -s -i -XPOST 'http://127.0.0.1:8086/write?db=air' --data-binary "Indoor,serial=$serial,sensor=interval value=$interval"
     }

while :
do
    #Sleep between readings
    sleep "$sleeptime"

    get_info
    if [[ $serial -le 0 ]];
        then
             echo "Skip this datapoint - something went wrong with the read"
        else
            write_data
    fi
done
