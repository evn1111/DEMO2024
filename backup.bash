#!/bin/bash

# Укажите путь к файлу конфигурации
CONFIG_FILE="/etc/network/interfaces"

# Создайте имя файла для резервной копии, добавив текущую дату и время
BACKUP_FILE="/root/interfaces_backup_$(date +%Y%m%d%H%M%S)"

# Создайте резервную копию файла конфигурации
cp $CONFIG_FILE $BACKUP_FILE

echo "Backup of $CONFIG_FILE saved to $BACKUP_FILE"
