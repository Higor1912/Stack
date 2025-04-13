#!/bin/bash

# Cores
verde="\e[32m"
vermelho="\e[31m"
reset="\e[0m"

# Função para pausar
pausar() {
    echo -e "${verde}Pressione Enter para continuar...${reset}"
    read
}

# SpiderFoot
instalar_spiderfoot() {
    echo -e "${verde}Instalando SpiderFoot...${reset}"
    sudo apt update
    sudo apt install -y python3-pip git
    git clone https://github.com/smicallef/spiderfoot.git
    cd spiderfoot || exit
    pip3 install -r requirements.txt
    echo -e "${verde}SpiderFoot instalado. Para iniciar: python3 sf.py${reset}"
    cd ..
    pausar
}

# theHarvester
instalar_theharvester() {
    echo -e "${verde}Instalando theHarvester...${reset}"
    sudo apt update
    sudo apt install -y theharvester
    echo -e "${verde}theHarvester instalado com sucesso.${reset}"
    pausar
}

# Wazuh
instalar_wazuh() {
    echo -e "${verde}Instalando Wazuh...${reset}"
    curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
    sudo bash ./wazuh-install.sh -a
    echo -e "${verde}Wazuh instalado.${reset}"
    pausar
}

# Grafana (com chave GPG atualizada)
instalar_grafana() {
    echo -e "${verde}Instalando Grafana...${reset}"
    sudo apt install -y software-properties-common gnupg2 curl
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null
    sudo apt update
    sudo apt install -y grafana
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server
    echo -e "${verde}Grafana instalado. Acesse http://localhost:3000${reset}"
    pausar
}

# Zabbix com banco de dados
instalar_zabbix() {
    echo -e "${verde}Instalando Zabbix...${reset}"
    wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu$(lsb_release -rs)_all.deb
    sudo dpkg -i zabbix-release_6.0-4+ubuntu$(lsb_release -rs)_all.deb
    sudo apt update
    sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mysql-server
    echo -e "${verde}Zabbix instalado. Configure o banco de dados manualmente e edite o zabbix_server.conf${reset}"
    pausar
}

# Menu
while true; do
    clear
    echo -e "${verde}"
    echo "========== Stack de Threat Intelligence =========="
    echo -e "${reset}"
    echo "1. Instalar SpiderFoot"
    echo "2. Instalar theHarvester"
    echo "3. Instalar Wazuh"
    echo "4. Instalar Grafana"
    echo "5. Instalar Zabbix com banco"
    echo "6. Sair"
    echo -n "Escolha uma opção: "
    read opcao

    case $opcao in
        1) instalar_spiderfoot ;;
        2) instalar_theharvester ;;
        3) instalar_wazuh ;;
        4) instalar_grafana ;;
        5) instalar_zabbix ;;
        6) exit ;;
        *) echo -e "${vermelho}Opção inválida!${reset}" ; pausar ;;
    esac
done
