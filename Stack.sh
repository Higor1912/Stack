#!/bin/bash

# Cores para terminal
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

function banner() {
    echo -e "${GREEN}"
    echo "========================================="
    echo "     Stack de Threat Intelligence        "
    echo "========================================="
    echo -e "${NC}"
}

function install_spiderfoot() {
    echo -e "${GREEN}[*] Instalando SpiderFoot...${NC}"
    sudo apt update
    sudo apt install -y git python3-pip python3-venv
    git clone https://github.com/smicallef/spiderfoot.git
    cd spiderfoot || exit
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    echo -e "${GREEN}[*] Para rodar: cd spiderfoot && source venv/bin/activate && python3 sf.py${NC}"
}

function install_theharvester() {
    echo -e "${GREEN}[*] Instalando theHarvester...${NC}"
    sudo apt update
    sudo apt install -y theharvester
    echo -e "${GREEN}[*] Para usar: theHarvester -d dominio.com -b all${NC}"
}

function install_wazuh() {
    echo -e "${GREEN}[*] Instalando Wazuh (server + dashboard)...${NC}"
    curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
    sudo bash wazuh-install.sh -i
}

function install_grafana() {
    echo -e "${GREEN}[*] Instalando Grafana OSS...${NC}"
    sudo apt install -y apt-transport-https software-properties-common
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
    sudo apt update
    sudo apt install -y grafana
    sudo systemctl enable --now grafana-server
    echo -e "${GREEN}[*] Acesse: http://localhost:3000${NC}"
}

function install_zabbix() {
    echo -e "${GREEN}[*] Instalando Zabbix com MariaDB...${NC}"
    
    sudo apt update
    sudo apt install -y mariadb-server mariadb-client zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

    echo -e "${GREEN}[*] Configurando banco de dados...${NC}"
    mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    mysql -e "CREATE USER zabbix@localhost IDENTIFIED BY 'ZabbixStrongPassword';"
    mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost;"
    mysql -e "FLUSH PRIVILEGES;"
    zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -pZabbixStrongPassword zabbix

    sudo sed -i "s/^# DBPassword=/DBPassword=ZabbixStrongPassword/" /etc/zabbix/zabbix_server.conf

    sudo systemctl restart zabbix-server zabbix-agent apache2
    sudo systemctl enable zabbix-server zabbix-agent apache2

    echo -e "${GREEN}[*] Zabbix instalado! Acesse: http://localhost/zabbix${NC}"
}

while true; do
    banner
    echo "1) Instalar SpiderFoot"
    echo "2) Instalar theHarvester"
    echo "3) Instalar Wazuh"
    echo "4) Instalar Grafana"
    echo "5) Instalar Zabbix com banco"
    echo "6) Sair"
    read -rp "Escolha uma opção: " opcao

    case $opcao in
        1) install_spiderfoot ;;
        2) install_theharvester ;;
        3) install_wazuh ;;
        4) install_grafana ;;
        5) install_zabbix ;;
        6) echo "Saindo..."; exit ;;
        *) echo -e "${RED}[!] Opção inválida.${NC}" ;;
    esac
    read -rp "Pressione Enter para continuar..."
done