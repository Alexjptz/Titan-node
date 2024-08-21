#!/bin/bash
tput reset
tput civis

echo -e "\e[40m\e[32m"
echo -e '----------_____--------------------_____----------------_____----------'
echo -e '---------/\----\------------------/\----\--------------/\----\---------'
echo -e '--------/::\____\----------------/::\----\------------/::\----\--------'
echo -e '-------/:::/----/---------------/::::\----\-----------\:::\----\-------'
echo -e '------/:::/----/---------------/::::::\----\-----------\:::\----\------'
echo -e '-----/:::/----/---------------/:::/\:::\----\-----------\:::\----\-----'
echo -e '----/:::/____/---------------/:::/__\:::\----\-----------\:::\----\----'
echo -e '----|::|----|---------------/::::\---\:::\----\----------/::::\----\---'
echo -e '----|::|----|-----_____----/::::::\---\:::\----\--------/::::::\----\--'
echo -e '----|::|----|----/\----\--/:::/\:::\---\:::\----\------/:::/\:::\----\-'
echo -e '----|::|----|---/::\____\/:::/--\:::\---\:::\____\----/:::/--\:::\____\'
echo -e '----|::|----|--/:::/----/\::/----\:::\--/:::/----/---/:::/----\::/----/'
echo -e '----|::|----|-/:::/----/--\/____/-\:::\/:::/----/---/:::/----/-\/____/-'
echo -e '----|::|____|/:::/----/------------\::::::/----/---/:::/----/----------'
echo -e '----|:::::::::::/----/--------------\::::/----/---/:::/----/-----------'
echo -e '----\::::::::::/____/---------------/:::/----/----\::/----/------------'
echo -e '-----~~~~~~~~~~--------------------/:::/----/------\/____/-------------'
echo -e '----------------------------------/:::/----/---------------------------'
echo -e '---------------------------------/:::/----/----------------------------'
echo -e '---------------------------------\::/----/-----------------------------'
echo -e '----------------------------------\/____/------------------------------'
echo -e '-----------------------------------------------------------------------'
echo -e '\e[0m'

echo -e "\n Подписаться на мой канал Beloglazov invest, \n чтобы быть в курсе самых актуальных нод и активностей - https://t.me/beloglazovinvest\n"

sleep 2

while true; do
    echo "1. Установить ноду TITAN (Install TITAN node)"
    echo "2. Выход (Exit)"
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            echo "Установка ноды (Node installation)..."
            read -p "Enter Your Identity Code: " identity_code

            # update packages
            echo "Обновление пакетов (updating packages) ... "
            sleep 1
            if sudo apt update -y && sudo apt-get update; then
                echo -e "Обновление пакетов (updating packages): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Обновление пакетов (updating packages): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi

            # install additional packages
            echo "Установка дополнительных пакетов (installing additional packages)..."
            sleep 1
            if sudo apt install -y ca-certificates curl gnupg lsb-release; then
                echo -e "Установка пакетов (packages installation): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Установка пакетов (packages installation): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi

            # Docker installation
            echo "Установка докера (installing Docker)..."
            sleep 1
            if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
               echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
               sudo apt update &&
               sudo apt install -y docker-ce docker-ce-cli containerd.io &&
               sudo usermod -aG docker $USER &&
               newgrp docker &&
               sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&
               sudo chmod +x /usr/local/bin/docker-compose; then
                echo -e "Установка Docker (Docker installation): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Установка Docker (Docker installation): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi

            # Загружаем образ Titan
            echo "Скачиваем образ Titan (downloading Titan image)..."
            sleep 1
            if docker pull nezha123/titan-edge && mkdir -p ~/.titanedge; then
                echo -e "Образ скачан (image downloaded): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Образ скачан (image downloaded): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi

            # Запускаем контейнер
            echo "Запускаем контейнер (Launching the container)..."
            sleep 1
            if docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge; then
                echo -e "Контейнер запущен (Container started): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Контейнер запущен (Container started): Ошибка (\e[31mError\e[0m)"
            fi


            # Связываем ключи
            echo "Связываем ключи (Linking the keys)..."
            sleep 1
            if docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash="$identity_code" https://api-test1.container1.titannet.io/api/v2/device/binding; then
                echo -e "Ключи связаны (Keys are connected): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Ключи связаны (Keys are connected): Ошибка (\e[31mError\e[0m)"
            fi

            echo -e "\e[32m------ SUCCESS!!! ------\e[0m"
            echo -e "Titan node installation completed"
            ;;

        2)
            echo -e "\e[31mСкрипт остановлен (Script stopped)\e[0m"
            exit 0
            ;;
        *)
            echo -e "\e[31mНеверная опция\e[0m. Пожалуйста, выберите 1, 2. \n \e[31mInvalid option.\e[0m Please select 1, 2."
            ;;
    esac
done
