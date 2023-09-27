# DEMO2024
inspared by https://github.com/valeriar23/DEMO2022

Топология сети


![image](https://github.com/evn1111/DEMO2024/assets/138611344/fc1f64f7-9990-4a47-97c8-05d034b1b5b7)

## План выполнения DEMO
- 1 Модуль
1. Базовая настройка сетевых устройств
2. Настройка внутренней маршрутизации
3. Настройка DHCP
4. Настройка локальных учетных записей
5. Проверка пропускной способности
6. Написание backup скрипта
7. Настройка SSH
8. Настройка контроль доступ по SSH
- 2 Модуль
1. Настройка DNS сервера
2. Настройка NTP
3. Настройка выбора сервера домена
4. Реализация файлового сервера
5. Конфигурация веб-севера LMS Apache
6. Запуск сервиса MediaWiki используя docker

## Дисклеймер
В связи с отсутствием конкретных данных, относящихся к IP адресации в сети (за исключением необходимого количества хостов для каждого офиса см. Пункт 1 Модуль 1). Было решено взять в качестве образца:
ISP:CLI - 1.1.10.0/24
ISP:BR-R - 5.5.5.0/28
ISP:HQ-R - 4.4.4.0/26
BR-R:BR-SRV - 172.16.100.0/28
HQ-R:HQ-SRV - 192.168.100.0/26

## Так-же настройка IPv6 рассматриваться на данный момент не будет

# Модуль 1 задание 6 
"Составьте backup скрипты для сохранения конфигурации сетевых устройств, а именно HQ-R BR-R.  Продемонстрируйте их работу"

