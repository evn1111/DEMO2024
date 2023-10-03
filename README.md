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
- ISP:CLI - 1.1.10.0/24
- ISP:BR-R - 5.5.5.0/28
- ISP:HQ-R - 4.4.4.0/26
- BR-R:BR-SRV - 172.16.100.0/28
- HQ-R:HQ-SRV - 192.168.100.0/26

  На самом экзамене IP адресация 100% будет другая

## Так-же настройка IPv6 рассматриваться на данный момент не будет

## Модуль 1 задание 6 
"Составьте backup скрипты для сохранения конфигурации сетевых устройств, а именно HQ-R BR-R.  Продемонстрируйте их работу"

1. Создайте файл backup.bash в домашней директории пользователя
```
touch /root/backup.bash
```
2. Откройте его с помшью любого текстового редактора, в моём случае - VIM
```
vim /root/backup.bash
```
3. В начале создания bash скрипта, необходимо указать
```
#!/bin/bash
```
#!/bin/bash - это шебанг (shebang) или интерпретаторная строка, которая используется в начале исполняемых сценариев в операционной системе Linux и других подобных системах Unix. Эта строка указывает на то, какую программу использовать для интерпретации и выполнения содержимого файла. В данном случае #!/bin/bash означает, что файл должен быть выполнен с использованием оболочки Bash (Bourne-again shell).

4. Следующей строкой укажем путь к файлу конфигурации, резервное копирование которой мы хотим сделать 
```
CONFIG_FILE="/etc/network/interfaces"
```
5. Создаём имя файла для резервной копии, добавив текущую дату и время
```
BACKUP_FILE="/root/interfaces_backup_$(date +%Y%m%d%H%M%S)"
```
6. Создаём резервную копию файла конфигурации
```
cp $CONFIG_FILE $BACKUP_FILE
```
7. Для того, чтобы пользователь понимал, что bash скрипт выполнение успешно, добавим вывод строки с помощью echo c указанием созданных раннее переменных
```
echo "Backup of $CONFIG_FILE saved to $BACKUP_FILE"
```
## Модуль 2 задание 4

Настройка SMB-сервера на базе сервера HQ-SRV для реализации общих папок с разрешениями для разных пользователей и автоматическим монтированием при входе доменных пользователей может быть выполнена следующим образом:

1. Установите и настройте Samba на сервере HQ-SRV, если он еще не установлен. Выполните команду для установки Samba (если она еще не установлена):

```bash
sudo apt-get install samba
```

2. Создайте общие папки, которые должны быть опубликованы:

```bash
sudo mkdir /shared/Branch_Files
sudo mkdir /shared/Network
sudo mkdir /shared/Admin_Files
```

3. Настройте разрешения для этих папок, чтобы удовлетворить требованиям доступа пользователей:

```bash
sudo chown BranchAdminUser /shared/Branch_Files
sudo chown NetworkAdminUser /shared/Network
sudo chown AdminUser /shared/Admin_Files
```

Где `BranchAdminUser`, `NetworkAdminUser` и `AdminUser` - это пользователи, которым разрешено доступ к соответствующим папкам.

4. Отредактируйте конфигурационный файл Samba `/etc/samba/smb.conf`:

```bash
sudo nano /etc/samba/smb.conf
```

Добавьте следующие секции для каждой общей папки:

```ini
[Branch_Files]
   path = /shared/Branch_Files
   valid users = BranchAdminUser
   read only = no

[Network]
   path = /shared/Network
   valid users = NetworkAdminUser
   read only = no

[Admin_Files]
   path = /shared/Admin_Files
   valid users = AdminUser
   read only = no
```

Убедитесь, что заменили `BranchAdminUser`, `NetworkAdminUser` и `AdminUser` на реальные имена пользователей.

5. Сохраните и закройте файл smb.conf.

6. Запустите следующие команды для создания пользователей Samba и установки паролей для них:

```bash
sudo smbpasswd -a BranchAdminUser
sudo smbpasswd -a NetworkAdminUser
sudo smbpasswd -a AdminUser
```

Следуйте инструкциям для установки паролей.

7. Теперь настроим автоматическое монтирование при входе пользователя в систему. Для этого можно использовать `pam_mount`. Установите его, если он еще не установлен:

```bash
sudo apt-get install libpam-mount
```

8. Отредактируйте конфигурационный файл PAM для монтирования `/etc/security/pam_mount.conf.xml`. Добавьте следующие строки в файл:

```xml
<!-- Пример для BranchAdminUser -->
<volume user="BranchAdminUser" fstype="cifs" server="HQ-SRV" path="/Branch_Files" mountpoint="/mnt/Branch_Files" options="username=BranchAdminUser,password=your_password,uid=1000,gid=1000" />
```

Замените `BranchAdminUser` на имя пользователя, `your_password` на пароль пользователя, а также укажите соответствующие секции для других пользователей.

9. Убедитесь, что PAM поддерживает монтирование, отредактировав файл `/etc/security/pam_mount.conf.xml`:

```bash
sudo nano /etc/security/pam_mount.conf.xml
```

Убедитесь, что строка `<action>` установлена в "mount".

10. Сохраните и закройте файл `pam_mount.conf.xml`.

11. Теперь настроим PAM для автоматического монтирования при входе. Отредактируйте файл `/etc/pam.d/common-session`:

```bash
sudo nano /etc/pam.d/common-session
```

Добавьте следующую строку в конец файла:

```bash
session optional pam_mount.so
```

12. Сохраните и закройте файл `common-session`.

13. Перезапустите службу Samba и PAM:

```bash
sudo service smbd restart
sudo service nmbd restart
sudo service pam_mount restart
```

Теперь при входе доменного пользователя в систему автоматически будет выполняться монтирование соответствующих общих папок Samba, и при выходе из сессии они будут отключены. Убедитесь, что правильно настроены разрешения и пароли для пользователей Samba, а также что на сервере HQ-SRV работает служба Samba.

## Запуск сервиса  MediaWiki используя docker на сервере

1. Установите службы Docker и Docker-compose

2. Создайте файл wiki.yml
```bash
touch wiki.yml
```
3. Отредактируйте созданный файл
```bash
vim wiki.yml
```
4. Приведите его к следующему виду
```
# MediaWiki with MariaDB
#
# Access via "http://localhost:8080"
#   (or "http://$(docker-machine ip):8080" if using docker-machine)
version: '3'
services:
  mediawiki:
    image: mediawiki
    restart: always
    ports:
      - 8080:80
    links:
      - database
    volumes:
      - images:/var/www/html/images
      # After initial setup, download LocalSettings.php to the same directory as
      # this yaml and uncomment the following line and use compose to restart
      # the mediawiki service
      # - ./LocalSettings.php:/var/www/html/LocalSettings.php
  # This key also defines the name of the database host used during setup instead of the default "localhost"
  database:
    image: mariadb
    restart: always
    environment:
      # @see https://phabricator.wikimedia.org/source/mediawiki/browse/master/includes/DefaultSettings.php
      MYSQL_DATABASE: mediawiki
      MYSQL_USER: wik
      MYSQL_PASSWORD: DEP@ssw0rd
      MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
    volumes:
      - db:/var/lib/mysql

volumes:
  images:
  db:
```
5. Запустите docker контейнеры 
```bash
docker-compose -f wiki.yml up -d
```
6. Проверьте запуск контейнеров
```bash
docker ps
```
