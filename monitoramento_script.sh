#!/bin/bash
HTTP_STATUS=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:80)
if [ "$HTTP_STATUS" == "200" ];
then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] O servidor NGINX está funcionando (HTTP $HTTP_STATUS) " >>  /var/log/monitoramento.log.
        echo "Serviço Online"
else

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] O servidor NGINX está fora do ar (HTTP $HTTP_STATUS)  " >> /var/log/monitoramento.log.
        echo "Serviço indisponível"
        URL_DISCORD=$(cat /projeto_linux/URL_Discord)
        curl -s -o /dev/null -X POST "$URL_DISCORD"\
         -H "Content-Type: application/json"\
         -d '{"content": "O servidor NGINX está fora do ar!"}'


fi
