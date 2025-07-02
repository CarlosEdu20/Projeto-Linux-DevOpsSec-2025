!/bin/bash
HTTP_STATUS=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:80)
DATA=$(date '+%Y-%m-%d %H:%M:%S')
LOG_PATH="/var/log/monitoramento.log."
URL_DISCORD=$(cat /projeto_linux/URL_Discord)

if [ "$HTTP_STATUS" == "200" ];
then
        echo "[$DATA] O servidor Nginx está funcionando (HTTP $HTTP_STATUS) " >> $LOG_PATH
        echo "Serviço Online"
else
        echo "[$DATA] O servidor Nginx está fora do ar (HTTP $HTTP_STATUS)  " >> $LOG_PATH
        echo "Serviço indisponível"
        if [ -n "$URL_DISCORD" ]; then
                curl -s -o /dev/null -X POST "$URL_DISCORD"\
                        -H "Content-Type: application/json"\
                        -d '{"content": "O servidor Nginx está fora do ar!"}'
        else
                echo "Webhook do Discord não encontrado. Alerta não enviado." >> $LOG_PATH
        fi


fi
