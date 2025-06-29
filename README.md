# Projeto Linux DevOpsSec 2025 | Monitaramento do servidor Web Nginx com Linux e AWS


## Objetivo: 
Este projeto consiste em um desafio proposto para turma da PB ABR 2025 do Programa de Bolsas DevSecOps. O mesmo fundamenta-se em desensolver e testar habilidades em Linux, AWS e automação de
processos através da configuração de um ambiente de servidor web monitorado.

## Tecnologias Usadas:
- Shell script
- crontab
- Amazon EC2
- Nginx
- WebHook

## Pré-requisitos:
- Distribuição Linux (Ubuntu/Debian)
- Servidor Nginx Instalado
- Serviço crontab Instalado
- WebHook do discord com URL + token de acesso [Como criar um Webhook no discord](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)

# Etapa 2: Configuração e instalação do servidor Web
### Passo 1: Instalar o Nginx no (Ubuntu/Debian)
OBS: Execute os comandos sendo root ou usando o 'sudo'.
```
sudo apt-get install NGINX
```
### Passo 2: Criar uma página HTML simples
OBS: personalize a página HTML da forma que preferir:
```
sudo nano /var/www/html/index.html
```
### Passo 3: Configure o Nginx para servir a página corretamente 
OBS: Certifique-se de que a seção **server** está assim:

```
sudo nano /etc/nginx/sites-available/default
server {
  listen 80;
  root /var/www/html;
  index index.html;

```
Logo após, reinicie o Nginx usando o comando:
```sudo systemctl restart nginx```

### Passo 4 (opcional): Dar permissão a um usuário para editar a página
OBS: Caso queira que um usuário do sistema possa modificar o arquivo HTML, use o comando:
```
chown -R nome_usuario:nome_usuario /var/www/html 
```
### Passo 5: Criar um serviço systemd para o Nginx
OBS: Para garantir que o NGINX seja reiniciado automaticamente em caso de falha ou reinicialização do sistema, crie um serviço personalizado usando `systemd`.
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
## Passo 6: Teste a conexão do servidor:
Para conecta-se ao servidor verifique primeiro o IP da sua mmáquina host:
```
ip a
```
Após vizualizar o IP digite no navegador o IP mostrado:
```
http://SEU_IP_PUBLICO
```

