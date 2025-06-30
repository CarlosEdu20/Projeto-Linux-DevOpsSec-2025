# Projeto Linux DevOpsSec 2025 | Monitaramento do servidor Web Nginx com Linux e AWS


## Objetivo: 
Este projeto consiste em um desafio proposto para turma da PB ABR 2025 do Programa de Bolsas DevSecOps. O mesmo fundamenta-se em desensolver e testar habilidades em Linux, AWS e automação de
processos através da configuração de um ambiente de servidor web monitorado.

## Tecnologias Usadas:
- Shell script
- cron
- Amazon EC2
- Nginx
- WebHook

## Pré-requisitos:
- Distribuição Linux (Ubuntu/Debian)
- Servidor Nginx Instalado
- Serviço cron Instalado
- WebHook do discord com URL + token de acesso [Como criar um Webhook no discord](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)

# Etapa 2: Configuração e instalação do servidor Web
### Passo 1: Instalar o Nginx no (Ubuntu/Debian) e o cron
Execute o comando de atualização e instalação sendo **root** ou usando o 'sudo'.
```
sudo apt-get update
sudo apt-get install NGINX
```
Verifique se o Nginx está funcioando:
```
sudo systemctl status nginx
```
A saída desse comando deve mostrar: active (running)

### Passo 2: Criar uma página HTML simples
Crie e personalize a página HTML da forma que preferir:
```
sudo nano /var/www/html/index.html
```
Essa pagina será exibida quando você acessar o IP público da sua instância via navegador.

### Passo 3: Configure o Nginx para servir a página corretamente 
Abra o arquivo de configuração do nginx e certifique-se de que a seção **server** esteja assim:

```
sudo nano /etc/nginx/sites-available/default
server {
  listen 80;
  root /var/www/html;
  index index.html;

```
Logo após, reinicie o Nginx usando o comando:
```sudo systemctl restart nginx```

### Passo 4 (opcional): Conceder permissão para um usuário editar a página HTML
Caso deseje que um usuário do sistema (diferente do root) possa editar os arquivos da página HTML, altere o proprietário da pasta onde ela está localizada com o seguinte comando:
```
chown -R nome_usuario:nome_usuario /var/www/html 
```
### Passo 5: Criar um serviço systemd para o Nginx
Para garantir que o NGINX seja reiniciado automaticamente em caso de falha ou reinicialização do sistema, crie um serviço personalizado usando `systemd`.
```
sudo /etc/systemd/system/nginx-monitorado.service
```
Pode escolher qualquer nome, mas optei por usar esse para ficar bem descritivo. Após criar o serviço, coloque essas devidas configurações:
```
[Unit]
Description=Este serviço garante a reinicialização automática do servidor Nginx em caso de interrupção 
After=network.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStart=/usr/sbin/nginx -g 'daemon on;'
ExecReload=/usr/sbin/nginx -s reload 
ExecStop=/bin/kill -s QUIT $MAINPID
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
```
#### Explicação dos Campos:
- Description: Descreve o funcionamento do serviço.
- after=: Aguarda uma conexão da rede antes do serviço iniciar.
- Type=forking: Indica que o serviço inicia em segundo plano.
- PIDFile: Local onde o PID do Nginx é armazenado no sistema.
- ExecStart, Reload, Stop: Comandos padrão para gerenciar o Nginx
- Restart=always: Reinicia o nginx caso o processo pare.
- RestartSec=120: Aguarda 2 minutos antes de reiniciar o Nginx (esse tempo foi escolhido devido possibilitar a verificão do crontab em 1 minuto).

Recarregue as configurações do systemd:
```
sudo systemctl daemon-reload
```
Habilite o serviço para iniciar automaticamente com o sistema:
```
sudo systemctl enable nginx-monitorado.service
```
Inicie o serviço manualmente:
```
sudo systemctl start nginx-monitorado.service
```
### Passo 6: Teste a conexão do servidor:
Para conecta-se ao servidor verifique primeiro o IP da sua mmáquina host:
```
ip a
```
Após vizualizar o IP digite no navegador o IP mostrado:
```
http://SEU_IP_PUBLICO
```
Aqui está um exemplo do que o Nginx deve retornar:
![image](https://github.com/user-attachments/assets/a40cd174-9206-411a-b118-e0d6ebcc61c1)

# Etapa 3: Monitoramento e Notificações
### Passo 1: Criar um script em Bash ou Python para monitorar a disponibilidade do site.

Para esta etapa do desafio, optei por utilizar **Shell Script (Bash)** por ser uma linguagem leve, nativa em distribuições Linux e ideal para tarefas automatizadas no sistema.
O objetivo do script é verificar periodicamente se o servidor web Nginx está respondendo corretamente às requisições HTTP. Caso o status de resposta não seja **200 (OK)**, o script envia uma notificação para um canal do Discord utilizando um Webhook previamente configurado, além de registrar a ocorrência em log.

### Organização do projeto

Para manter o projeto organizado, crie uma pasta na raiz do sistema:
```
mkdir /nome_projeto
```
Depois, navegue até a pasta usando:
```
cd /nome_projeto
```
Logo após entrar na pasta, crie o arquivo principal do script de monitoramento e o arquivo que que conterá apenas a URL do webhook do Discord
```
nano monitoramento_script.sh
nano URL_Discord 
```
### Explicação do funcionamento do script
- O curl verifica se o servidor NGINX está respondendo via localhost:80.
- Se o status HTTP for 200, registra no log e exibe “Serviço Online”.
- Se o status for diferente de 200, considera que o servidor está fora do ar e envia um arquivo json para um sevidor do discord através do WEbhook, além de registrar no sistema na pasta **/var/log/monitoramento.log**
- O Webhook é lido a partir do arquivo /nome_projeto/URL_Discord.

### Permissão de execução
Antes de agendar o script usando o cron, priemiro torne-o executável com o seguinte comando:
```
chmod +x monitoramento_script.sh
```

### Passo 2: Arquivo de log de monitoramento
O script registra todas as verificações (sucesso ou falha) no arquivo de log:
O arquivo vai ser gerado automaticamente na primeira execução do script e será guardado na pasta:
```
/var/log/monitoramento.log
```

### Passo 3: Criar um cron para agendar a execução do script
Primeiro, verifique se o serviço do cron está instalado corretamente em sua distribuição Linux. Digite:
```crontab ```
Se o terminal exibir as opções disponíveis (Options), significa que o cron já está instalado.

**O que é o cron?**

O cron é um serviço de agendamento nativo presente na maioria das distribuições Linux. Ele permite que comandos ou scripts sejam executados automaticamente em intervalos regulares definidos pelo usuário, como minutos, horas, dias ou semanas. No contexto desse projeto, vamos utilizá-lo para agendar a execução do script de monitoramento a cada 1 minuto. 

**Agendar o script**
Abra o crontab do usuário atual com o comando:
```crontab -e```
Isso abrirá o editor de texto padrão com o arquivo de configuração do cron.

Para agendar a execução do script, adicione a seguinte linha ao final do arquivo para agendar o script:
```
* * * * * /nome_do_projeto/monitoramento_script.sh >> /var/log/monitoramento.log
```
**Os campos do crontab funcionam da seguinte maneira:**
``` * * * * * → minuto, hora, dia do mês, mês, dia da semana (todos com *)``` 
Ou seja, a cada 1 minuto o script será executado.

Após adicionar a linha, salve e saia do editor. O cron automaticamente aplicará a nova regra.

### Passo 4: Enviar uma notificação de alerta via Discord, Telegram ou Slack se detectar indisponibilidade.
O webhook é uma forma de um sistema notificar outro sistema automaticamente assim que algo acontece. No cenário deste projeto, o webhook é acionado sempre que o script detecta que o servidor está fora do ar.

### Como o script funciona:
Se ele detecta que o NGINX está fora do ar, o script dispara uma requisição HTTP (usando curl) para uma URL de Webhook do Discord. O Discord recebe essa requisição e exibe a mensagem automaticamente no canal configurado.

### Como configurar o Webhook:
- CrieCrie um canal no Discord onde deseja receber as notificações.
- Vá em Editar Canal > Integrações > Webhooks > Novo Webhook.
- Copie a URL gerada. Ela terá o seguinte formato:

```
https://discord.com/api/webhooks/SEU_WEBHOOK_ID/SEU_TOKEN
```
### Segurança
Por motivos de segurança, não é recomendado deixar essa URL visível diretamente dentro do script. Ao vez disso, crie um arquivo separado contendo apenas a URL:
```
nano /nome_do_projeto/URL_Discord
```
Agora dentro desse arquivo, cole a URL do webhook gerada no Discord.

Com isso, o scrip pode acessar essa URL através dessa variável
```
URL_DISCORD=$(cat /nome_do_projeto/URL_Discord)
```
Com isso, o sistema estará pronto para enviar alertas em tempo real sempre que o NGINX ficar indisponível.

# Etapa 4: Automação e Testes
### Passo 1: Como executar o arquivo:
Para executar o script use o comanndo dentro da pasta:
```
./monitoramento_script.sh
```
Após rodar o script, a saida esperada deve ser essa:
```Serviço Online```
Este log é armazenado no arquivo dentro da pasta do sistema ** /var/log/monitoramento.log**
```
[2025-06-30 09:10:01] O servidor NGINX está funcionando (HTTP 200) 
Serviço Online

```


### Passo 2: Parar o Nginx
Para testar se o script está funcionando corretamente, devemos primeiro parar o serviço do nginx, vamos consultar o PID do Nginx usando o comando:
```
 systemctl status nginx-monitorado.service
```
Anote o PID e execute o comando para matar o processo: 
```
Kill PID # Substitua "PID" pelo número identificado
```
Depois dessa execução, a saida mostrada será:
```
Serviço indisponível
```
Este log também é armazenado no arquivo dentro da pasta do sistema ** /var/log/monitoramento.log**
```
[2025-06-30 09:13:02] O servidor NGINX está fora do ar (HTTP 000)  
Serviço indisponível
```

Após isso, aguarde a execução do cron.


### Etapa 3: Alerta emitido no discord
O webhook dispará um processo assim que o cron detectar que o servidor está fora do ar. Como mostra essa imagem:
![image](https://github.com/user-attachments/assets/44c511c2-5e7d-4ad8-a5fa-62218724facc)

Isso significa que o script de monitoramento está funcionando com sucesso.






















