# Projeto Linux DevSecOps 2025 | Monitoramento do servidor Web Nginx com Linux e AWS


## Objetivo: 
Este projeto consiste em um desafio proposto para a turma da PB ABR 2025 do Programa de Bolsas DevSecOps. O mesmo fundamenta-se em desenvolver e testar habilidades em Linux, AWS e automação de processos através da configuração de um ambiente de servidor web monitorado.

## Tecnologias Usadas:
- Shell script
- Cron
- Amazon EC2
- Amazon VPC
- Amazon Subnets
- Amazon Security Groups
- Nginx
- Webhook (Discord)

## Pré-requisitos:
- Distribuição Linux (Ubuntu/Debian).
- Servidor Nginx Instalado.
- Serviço cron Instalado.
- WebHook do discord com URL + token de acesso [Como criar um Webhook no discord](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)

# Etapa 1: Configuração de ambiente na AWS
### Passo 1: Criar uma VPC
Uma VPC (Virtual Private Cloud) é uma parte isolada da Nuvem AWS preenchida por objetos da AWS, como instâncias do Amazon EC2. Neste projeto, essa nuvem é usada para subir as instâncias da EC2.

#### Configurações utilizadas para criar a VPC:

- **Recursos a serem criados**: `Somente VPC`
- **Tag de nome**: `VPC_Projeto` *(ou outro nome descritivo)*
- **Bloco CIDR IPv4**: `10.0.0.0/16`  
  *(ou `10.0.0.0/24`, se preferir algo mais limitado)*
- **Bloco CIDR IPv6**: `Nenhum bloco CIDR IPv6`
- **Localização**: `Padrão`

### Observações: 
- O bloco `10.0.0.0/16` permite criar múltiplas sub-redes, como públicas e privadas.

### Passo 2: Configurar duas sub-redes públicas:
Com a VPC criada, configure duas sub-redes públicas — uma em cada zona de disponibilidade — para permitir acesso externo à instância EC2. E caso alguma região der falha, a outra consegue sustentar a rede.

#### Sub-rede pública 1: 
- **Nome**: `Public-Subnet-1`
- **VPC associada**: `VPC_Projeto`
- **Zona de disponibilidade**: `us-east-2a`
- **Bloco CIDR IPv4**: `10.0.1.0/24`
  
#### Sub-rede pública 2:
- **Nome**: `Public-Subnet-2`
- **VPC associada**: `VPC_Projeto`
- **Zona de disponibilidade**: `us-east-2b`
- **Bloco CIDR IPv4**: `10.0.2.0/24`

### Passo 3: Configurar duas sub-redes privadas:
As sub-redes privadas são utilizadas para recursos internos que **não precisam de acesso direto à internet**, como bancos de dados, containers internos, entre outros.

#### Sub-rede privada 1: 
- **Nome**: `Private-Subnet-1`
- **VPC associada**: `VPC_Projeto`
- **Zona de disponibilidade**: `us-east-2a`
- **Bloco CIDR IPv4**: `10.0.3.0/24`

#### Sub-rede privada 2:
- **Nome**: `Private-Subnet-2`
- **VPC associada**: `VPC_Projeto`
- **Zona de disponibilidade**: `us-east-2b`
- **Bloco CIDR IPv4**: `10.0.4.0/24`

### Passo 4: Criar um Internet Gateway e conectá-lo às sub-redes públicas
Para que as instâncias nas sub-redes públicas tenham acesso à internet, é necessário criar e configurar um **Internet Gateway (IGW)** e configurar uma tabela de rotas públicas.

#### Etapas:

- Vá para o serviço **VPC** no console da AWS.
- No menu lateral, clique em **Gateways da Internet > Criar gateway da internet**.
- Preencha:
   - **Nome**: `IGW_Projeto`
- Clique em **Criar**.
- Após criado, clique em **Ações > Anexar à VPC** e selecione a VPC: `VPC_Projeto`

#### Criar e configurar a tabela de rotas públicas:

1. No menu da VPC, vá em **Tabelas de rotas > Criar tabela de rotas**
   - **Nome**: `Public-Route-Table`
   - **VPC**: `VPC_Projeto`
2. Após criada:
   - Vá em **Rotas > Editar rotas**
   - Adicione:
     - **Destino**: `0.0.0.0/0`
     - **Destino**: selecione o Internet Gateway (`IGW_Projeto`)
3. Vá para a aba **Associações de sub-rede**
   - Clique em **Editar associações**
   - Marque:
     - `Public-Subnet-1`
     - `Public-Subnet-2`

### Passo 5: Criação da EC2
Nesta etapa, deve-se criar uma instância EC2 Linux para hospedar o servidor web Nginx e o script de monitoramento.

#### Escolher uma AMI baseada em Linux
Durante o processo de criação da instância, foi selecionada uma **AMI (Amazon Machine Image)** compatível com o projeto. A AMI escolhida foi o Ubuntu Server 24.04 LTS.

#### Configurar a EC2 na sub-rede pública
A instância foi configurada na sub-rede `Public-Subnet-2`, uma das sub-redes criadas na VPC personalizada (`VPC_DevSecOps_2025`).

Marcar a opção **Atribuir IP público automaticamente** foi habilitada, permitindo o acesso externo via SSH e HTTP.

#### Criar grupo de segurança (Security Group)
Foi configurado um grupo de segurança com as seguintes regras de entrada:

Tipo: SSH, Protocolo: TCP, Porta: 22, Origem: 0.0.0.0/0 (Essa configuração é usada para acesso remoto via terminal).

Tipo: HTTP, Protocolo: TCP, Porta: 80, Origem: 0.0.0.0/0 (Essa configuração é usada para acesso ao servidor web (Nginx)).

###  Par de chaves (Key Pair)
Durante a criação da instância, foi gerado um **par de chaves no formato `.pem`** (exemplo: `meu-par-devsecops.pem`) para acesso seguro via SSH.

A chave foi baixada localmente e é utilizada para autenticação sem senha no terminal. Guarde bem essa chave, sem ela não dá para ter acesso via SSH.

### Acesso à instância via SSH
Após o lançamento da instância, é possível conectar remotamente via SSH com o seguinte comando (executado no terminal local):
```
chmod 400 meu-par-devsecops.pem # Esse comando concede permissão de leitura.
```
```
ssh -i "meu-par-devsecops.pem" ubuntu@SEU_IP_PUBLICO # Esse comando concede acesso via SSH
```

Substitua SEU_IP_PUBLICO pelo IP da instância.


# Etapa 2: Configuração e instalação do servidor Web
### Passo 1: Instalar o Nginx no (Ubuntu/Debian) e o cron
Execute o comando de atualização e instalação sendo **root** ou usando o 'sudo'.
```
sudo apt-get update
sudo apt-get install nginx
```
Verifique se o Nginx está funcionando:
```
sudo systemctl status nginx
```
A saída deste comando deve mostrar: active (running)

### Passo 2: Criar uma página HTML simples
Crie e personalize a página HTML da forma que preferir:
```
sudo nano /var/www/html/index.html
```
Essa página será exibida quando você acessar o IP público da sua instância via navegador web.

### Passo 3: Configure o Nginx para servir a página corretamente 
Abra o arquivo de configuração do Nginx com um editor de texto e certifique-se de que a seção **server** esteja assim:

```
sudo nano /etc/nginx/sites-available/default
server {
  listen 80;
  root /var/www/html;
  index index.html;

```
Logo após, reinicie o serviço do Nginx usando o comando:
```sudo systemctl restart nginx```

### Passo 4 (opcional): Conceder permissão para um usuário editar a página HTML
Caso deseje que um usuário do sistema (diferente do root) possa editar os arquivos da página HTML, altere o proprietário da pasta onde ela está localizada com o seguinte comando:
```
chown -R nome_usuario:nome_usuario /var/www/html 
```
Com isso, o usuário que você concedeu permissão poderá ter livre acesso para editar a página.

### Passo 5: Criar um serviço personalizado no systemd para o Nginx
Para garantir que o Nginx seja reiniciado automaticamente em caso de falha ou reinicialização do sistema, crie um serviço personalizado usando `systemd`.
```
sudo /etc/systemd/system/nginx-monitorado.service
```
Pode escolher qualquer nome, mas optei por usar esse, para ficar bem descritivo. Após criar o serviço, coloque essas devidas configurações:
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
- ExecStart, Reload, Stop: Comandos padrão para gerenciar o Nginx.
- Restart=always: Reinicia o nginx caso o processo pare.
- RestartSec=120: Aguarda 2 minutos antes de reiniciar o Nginx (esse tempo foi escolhido devido possibilitar a verificão do crontab em 1 minuto).

Recarregue as configurações do systemd com o comando:
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
### Passo 6: Testar a conexão com o servidor Nginx:
Para conectar-se ao servidor do Nginx verifique primeiro o IP da sua instância onde está instalado o servidor:
```
ip a
```
Após vizualizar o IP, digite no seu navegador Web o IP mostrado:
```
http://SEU_IP_PUBLICO
```
Aqui está um exemplo do que o Nginx deve retornar:
![image](https://github.com/user-attachments/assets/a40cd174-9206-411a-b118-e0d6ebcc61c1)

# Etapa 3: Monitoramento e Notificações
### Passo 1: Criar um script em Bash ou Python para monitorar a disponibilidade do site.

Para esta etapa do desafio, optei por utilizar **Shell Script (Bash)** por ser uma linguagem leve, nativa em diversas distribuições Linux e ideal para tarefas automatizadas no sistema.

O objetivo do script é verificar periodicamente se o servidor web Nginx está respondendo corretamente às requisições HTTP. Caso o status de resposta não seja **200 (OK)**, o script envia uma notificação para um canal do Discord utilizando um Webhook previamente configurado, além de registrar a ocorrência em log.

### Organização do projeto

Para manter o projeto organizado, crie um diretório na raiz do sistema:
```
mkdir /nome_projeto
```
Depois, navegue até o mesmo usando:
```
cd /nome_projeto
```
Logo após entrar no diretório, crie o arquivo principal do script de monitoramento e o arquivo que que conterá apenas a sua URL do webhook do Discord. Por motivos de segurança, não coloque sua URL gerada pelo discord diretamente no script, ao invés de fazer isso, crie um arquivo fora à parte.
```
touch monitoramento_script.sh
touch URL_Discord 
```
Com os arquivos criados, você pode modificar os mesmos usando algum editor de texto de sua preferência.

### Explicação do funcionamento do script
- O curl verifica se o servidor Nginx está respondendo via localhost:80.
- Se o status HTTP for 200, registra no log e exibe “Serviço Online”.
- Se o status for diferente de 200, considera que o servidor está fora do ar e envia um arquivo json para um sevidor do discord através do Webhook, além de registrar no sistema na pasta **/var/log/monitoramento.log**
- O Webhook é lido a partir do arquivo /nome_projeto/URL_Discord.

### Permissão de execução
Antes de agendar o script usando o cron, primeiro torne-o executável com o seguinte comando:
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

Para agendar a execução do script, adicione a seguinte linha ao final do arquivo para agendar a execução do script:
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
Se ele detecta que o NGINX está fora do ar, o script dispara uma requisição HTTP (usando curl) para a URL do Webhook no Discord. O Discord recebe essa requisição e exibe a mensagem automaticamente no canal configurado.

### Como configurar o Webhook:
- Crie um canal no Discord onde deseja receber as notificações.
- Vá em Editar Canal > Integrações > Webhooks > Novo Webhook.
- Copie a URL gerada. Ela terá o seguinte formato:

```
https://discord.com/api/webhooks/SEU_WEBHOOK_ID/SEU_TOKEN
```
### Segurança
Por motivos de segurança, não é recomendado deixar essa URL visível diretamente dentro do script. Ao invés disso, crie um arquivo separado contendo a URL disponibilizada pelo discord:
```
nano /nome_do_projeto/URL_Discord
```
Agora dentro desse arquivo, cole a URL do webhook gerada no discord.

Com isso, o script pode acessar essa URL através dessa variável
```
URL_DISCORD=$(cat /nome_do_projeto/URL_Discord)
```
Com isso, o sistema estará pronto para enviar alertas em tempo real sempre que o Nginx icar indisponível.

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
Kill <PID> # Substitua "PID" pelo número identificado
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

# Atualizações Futuras:
As próximas etapas do projeto visam expandir suas capacidades de automação, escalabilidade e observabilidade dentro da AWS.

#### Automação com o User data (EC2)
Pode-se usar o User data para automatizar a configuração inicial da instância EC2 no momento em que ela é criada.

Essa funcionalidade permite executar comandos de shell logo no primeiro boot da máquina, como:

- Atualizar os pacotes do sistema;
- Instalar o NGINX automaticamente;
- Criar um arquivo `index.html` dentro de `/var/www/html`;
- Copiar ou gerar o script de monitoramento;
- Configurar permissões e ativar o `cron` ou `systemd` para o script funcionar.

#### Criar um template usando o CloudFormation:
O **AWS CloudFormation** permite definir toda a infraestrutura da nuvem como código (IaC), utilizando arquivos no formato YAML ou JSON. Isso possibilita o provisionamento automático e padronizado dos recursos AWS necessários para o projeto.

Com o CloudFormation, é possível criar de forma automatizada:

- VPC personalizada;
- Sub-redes públicas e privadas;
- Internet Gateway e tabela de rotas;
- Grupo de segurança (Security Group);
- Instância EC2 configurada com User Data.
  
#### Monitoramento avançado usando o CloudWatch:

O **Amazon CloudWatch** é o serviço da AWS para monitoramento e observabilidade de aplicações, recursos e infraestrutura.  
Ele pode ser integrado ao projeto para acompanhar o funcionamento do servidor web e gerar alertas em tempo real.

##### Objetivo:
- Monitorar a **disponibilidade do NGINX**;
- Coletar métricas personalizadas a partir do **script de monitoramento**;
- Gerar **alarmes automáticos** com base no status do servidor;
- (Opcional) Integrar com o **Amazon SNS** para envio de notificações por e-mail, SMS ou outro canal.


























