#!/bin/bash
tput reset
tput civis

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

print_logo () {
    echo
    show_orange " .___________. __  .___________.     ___      .__   __. " && sleep 0.2
    show_orange " |           ||  | |           |    /   \     |  \ |  | " && sleep 0.2
    show_orange "  ---|  |---- |  |  ---|  |----    /  ^  \    |   \|  | " && sleep 0.2
    show_orange "     |  |     |  |     |  |       /  /_\  \   |  .    | " && sleep 0.2
    show_orange "     |  |     |  |     |  |      /  _____  \  |  |\   | " && sleep 0.2
    show_orange "     |__|     |__|     |__|     /__/     \__\ |__| \__| " && sleep 0.2
    echo
    sleep 1
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo ""
        show_green "Успешно (Success)"
        echo ""
    else
        sleep 1
        echo ""
        show_red "Ошибка (Fail)"
        echo ""
    fi
}

exit_script() {
    show_red "Скрипт остановлен (Script stopped)"
        echo ""
        exit 0
}

incorrect_option () {
    echo ""
    show_red "Неверная опция. Пожалуйста, выберите из тех, что есть."
    echo ""
    show_red "Invalid option. Please choose from the available options."
    echo ""
}

while true; do
    print_logo
    echo "1. Подготовка (Preparation)"
    echo "2. Установка (Installation)"
    echo "3. Управление (Operational)"
    echo "4. Удаление (Delete)"
    echo "5. Выход (Exit)"
    echo ""
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            # update packages
            echo "Обновление пакетов (updating packages) ... "
            sleep 2
            if sudo apt update -y && sudo apt-get upgrade; then
                sleep 1
                echo -e "Обновление пакетов (updating packages): Успешно (\e[32mSuccess\e[0m)"
                sleep 1
            else
                echo -e "Обновление пакетов (updating packages): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi

            # install additional packages
            echo "Установка дополнительных пакетов (installing additional packages)..."
            sleep 2
            if sudo apt install -y ca-certificates curl gnupg lsb-release; then
                echo -e "Установка пакетов (packages installation): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Установка пакетов (packages installation): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi

            # Docker installation
            echo "Установка докера (installing Docker)..."
            sleep 2
            if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
               echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
               sudo apt update &&
               sudo apt install -y docker-ce docker-ce-cli containerd.io &&
               sudo usermod -aG docker $USER; then
                echo -e "Установка Docker (Docker installation): Успешно (\e[32mSuccess\e[0m) \n \e[33mДля завершения настройки Docker: \n 1) завершите скрипт \n 2) напишите exit \n 3) откройте терминал заново.\e[0m"
            else
                echo -e "Установка Docker (Docker installation): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi
            echo
            show_green "--- ПОГОТОВКА ЗАЕРШЕНА. PREPARATION COMPLETED ---"
            echo
            ;;
        2)
            echo "Установка ноды (Node installation)..."
            echo ""
            sleep 2
            read -p "Enter Your Identity Code: " identity_code


            # install Docker Compose
            echo "Установка Docker Compose (Docker Compose installation)..."
            sleep 2
            if sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&
               sudo chmod +x /usr/local/bin/docker-compose; then
                echo -e "Установка Docker Compose (Docker Compose installation): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Установка Docker  Compose (Docker Compose installation): Ошибка (\e[31mError\e[0m)"
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
            if docker run --name titan --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge; then
                echo -e "Контейнер запущен (Container started): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Контейнер запущен (Container started): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi


            # Связываем ключи
            echo "Связываем ключи (Linking the keys)..."
            sleep 1
            if docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash="$identity_code" https://api-test1.container1.titannet.io/api/v2/device/binding; then
                echo -e "Ключи связаны (Keys are connected): Успешно (\e[32mSuccess\e[0m)"
            else
                echo -e "Ключи связаны (Keys are connected): Ошибка (\e[31mError\e[0m)"
                exit 1
            fi
            echo
            echo -e "\e[32m------ SUCCESS!!! ------\e[0m"
            echo -e "Titan node installation completed"
            echo
            ;;
        3)
            # OPERATIONAL
            while true; do
                show_green "------ OPERATIONAL MENU ------ "
                echo "1. Рестарт (Restart)"
                echo "2. Стоп (Stop)"
                echo "3. Выход (Exit)"
                echo
                read -p "Выберите опцию (Select option): " option
                echo
                case $option in
                    1)
                        echo "Выполняем рестрат ноды (Restarting node)..."
                        if docker run --name titan -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge; then
                            echo -e "Рестарт выполнен (Restart completed): Успешно (\e[32mSuccess\e[0m)"
                        else
                            echo -e "Рестарт выполнен (Restart completed): Ошибка (\e[31mSuccess\e[0m)"
                            exit 1
                        fi
                        ;;
                    2)
                        #  stop node
                        show_orange "Останавливаем ноду (Stopping node)..."
                        sleep 1
                        run_commands "docker stop titan"
                        ;;
                    3)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        4)
            # Delete node
            process_notification "Удаление (Deleting)..."
            echo
            while true; do
                read -p "Удалить ноду? Delete node? (yes/no): " option

                case "$option" in
                    yes|y|Y|Yes|YES)
                        process_notification "Останавливаем (Stopping) Chainbase..."
                        run_commands "docker stop titan"

                        process_notification "Чистим (Cleaning)..."
                        run_commands "docker rmi nezha123/titan-edge"

                        show_green "--- НОДА УДАЛЕНА. NODE DELETED. ---"
                        break
                        ;;
                    no|n|N|No|NO)
                        process_notification "Отмена (Cancel)"
                        echo ""
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        5)
            exit_script
            ;;
        *)
            incorrect_option
            ;;
    esac
done
