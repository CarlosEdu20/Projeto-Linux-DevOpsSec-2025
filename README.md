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

## Como rodar o projeto:
### Passo 1: Instalar o Nginx no (Ubunto/Debian)
```
sudo apt-get install NGINX
```
### Passo 2: Assim que instalar o Nginx crie uma página HTML usando  simples em:
```
sudo touch /var/www/html/index.html
```
### Passo 3: Configure o Nginx para servir a página corretamente: 
```
sudo nano /etc/nginx/sites-available/default
server {
  listen 80;
  root /var/www/html;
  index index.html;

```
