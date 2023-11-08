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

## Запуск сервиса  Moodle LMS (Apache2+MariaDB)

Веб-сервер Apache доступен в репозитории Debian и может быть установлен через менеджер пакетов apt, выполнив следующую команду:
```bash
sudo apt install apache2
```
Добавьте Apache2 в автозапуск 
```bash
sudo systemctl enable apache2
```
Для провекра первичной работоспособности яндекс зайдите в браузер и в поисковой строке введите ваш IP-адрес
```bash
http://your-IP-address
```
![image](https://github.com/evn1111/DEMO2024/assets/138611344/47180cb7-317f-40c5-8d5d-7e0b31bcb7a8)

Для установки PHP для Moodle, скачиваем пакеты
```bash
sudo apt install php libapache2-mod-php php-iconv php-intl php-soap php-zip php-curl php-mbstring php-mysql php-gd php-xml php-pspell php-json php-xmlrpc
```
Проверить наличие PHP можно командой
```bash
php -v
```
Вы должны получить такой ответ
```bash
Output: PHP 7.4.28 (cli) (built: Feb 17 2022 16:17:19) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.28, Copyright (c), by Zend Technologies
```
Установка Базы Данных MariaDB осуществляется следующей командой 
```bash
sudo apt install mariadb-server mariadb-client
```
Добавьте MariaDB в автозагрузку 
```bash
sudo systemctl enable mariadb
```
Для дальнейшей работы, нужно отредактировать конфигурационный файл MariaDB
```
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
Добавьте следующие строки
```bash
default_storage_engine = innodb
innodb_file_per_table = 1
innodb_file_format = Barracuda
```
Перезапустите службу
```bash
sudo systemctl restart mariadb
```
Для создания базы данных в MariaDB, сначала войдите в неё 
```bash
sudo  mysql -u root
```
Чтобы создать базу данных, пользователя базы данных и выдать все привелегии, нужно прописать 
```bash
MariaDB [(none)]> CREATE DATABASE moodledb;
MariaDB [(none)]> CREATE USER 'moodle_user'@'localhost' IDENTIFIED BY 'Moodle_Passw0rd!';
MariaDB [(none)]> GRANT ALL ON moodledb.* TO 'moodle_user'@'localhost';
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> EXIT
```
Установка Moodle производится с помощью команды 
```bash
sudo wget https://download.moodle.org/download.php/direct/stable400/moodle-4.0.1.zip
```
После загрузки, распакуйте скаченные файлы и сохраните их в директорию  для html
```bash
sudo unzip moodle-4.0.1.zip -d /var/www/html/
```
Создайте директорию для Moodle
```bash
sudo mkdir /var/www/html/moodledata
```
Настройке права доступа для созданной диреткории
```bash
sudo chown -R www-data:www-data /var/www/html/moodle/
sudo chmod -R 755 /var/www/html/moodle/
sudo chown -R www-data:www-data /var/www/html/moodledata/
```
Создайте конфигурационный файл Apache для сайта 
```bash
nano /etc/apache2/sites-available/moodle.conf
```
Файл должен выглядить следующим образом
```bashMoodle on Debian 11
How to Install Moodle on Debian 11
 JUNE 13, 2022  POSTED INDEBIAN
Moodle is a popular, free, and open-source Course Management system based on PHP released under the GNU General Public License.

The Moodle platform is highly customizable and takes a modular approach to features, so it is extensible and adaptable to your needs. It is probably most popular open source learning management platform available today.

In this tutorial, we will show you how to install Moodle on your Debian 11 OS.

Step 1: Update Operating System
Update and upgrade the system repositories to make sure all existing packages are up to date:

$ sudo apt update && sudo apt upgrade
Step 2: Install Apache webserver
Apache web server is available on the Debian repository and can be installed via apt package manager by executing the following command:

$ sudo apt install apache2
You can start the Apache service and configure it to run on startup by entering the following commands:

$ sudo systemctl start apache2
$ sudo systemctl enable apache2
Verify the status of the Apache service using systemctl status command:

$ sudo systemctl status apache2
Output:

● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running)
       Docs: https://httpd.apache.org/docs/2.4/
    Process: 459 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)
   Main PID: 666 (apache2)
      Tasks: 6 (limit: 2301)
     Memory: 24.3M
        CPU: 439ms
     CGroup: /system.slice/apache2.service
             ├─666 /usr/sbin/apache2 -k start
             ├─677 /usr/sbin/apache2 -k start
             ├─678 /usr/sbin/apache2 -k start
             ├─679 /usr/sbin/apache2 -k start
             ├─680 /usr/sbin/apache2 -k start
             └─681 /usr/sbin/apache2 -k start
You can test to make sure everything is working correctly by navigating to:

http://your-IP-address
If everything is configured properly, you should be greeted by the Apache2 Debian Default Page, as seen below.

Apache2 Debian Default Page

Step 3: Install PHP and PHP extensions for Moodle
By default, Debian 11 comes with PHP version 7.4.

You can install PHP and required PHP extensions using the following command:

$ sudo apt install php libapache2-mod-php php-iconv php-intl php-soap php-zip php-curl php-mbstring php-mysql php-gd php-xml php-pspell php-json php-xmlrpc
Verify if PHP is installed.

php -v
Output: PHP 7.4.28 (cli) (built: Feb 17 2022 16:17:19) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.28, Copyright (c), by Zend Technologies
Step 4: Install MariaDB
We will use MariaDB as the database system for Moodle (Moodle supports MariaDB/MySQL and PostgreSQL).

You can install MariaDB with the following command:

$ sudo apt install mariadb-server mariadb-client
The commands below can be used to stop, start and enable MariaDB service to start automatically at the next boot:

$ sudo systemctl start mariadb
$ sudo systemctl stop mariadb
$ sudo systemctl enable mariadb
Also, you can verify the status of the MariaDB service using systemctl status command:

$ sudo systemctl status mariadb
Output:

● mariadb.service - MariaDB 10.5.15 database server
     Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
     Active: active (running)
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
   Main PID: 16987 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 8 (limit: 2287)
     Memory: 63.0M
        CPU: 1.403s
     CGroup: /system.slice/mariadb.service
             └─16987 /usr/sbin/mariadbd
Then open the MariaDB default configuration file:

$ sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
Under ‘[mysqld]‘ line, paste the following configuration:

default_storage_engine = innodb
innodb_file_per_table = 1
innodb_file_format = Barracuda
Save and exit, then restart MariaDB service:

$ sudo systemctl restart mariadb
Step 5: Create Database
Log into the MariaDB prompt:

$ sudo  mysql -u root
To create a database, database user, and grant all privileges to the database user run the following commands:

MariaDB [(none)]> CREATE DATABASE moodledb;
MariaDB [(none)]> CREATE USER 'moodle_user'@'localhost' IDENTIFIED BY 'Moodle_Passw0rd!';
MariaDB [(none)]> GRANT ALL ON moodledb.* TO 'moodle_user'@'localhost';
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> EXIT
Step 6: Download Moodle
We will now download the latest stable Moodle version from the Moodle Official site.

Use the following command to download Moodle:

$ sudo wget https://download.moodle.org/download.php/direct/stable400/moodle-4.0.1.zip
Extract file into the folder /var/www/html/ with the following command:

$ sudo unzip moodle-4.0.1.zip -d /var/www/html/
Then, create a new directory in /var/www/html directory:

$ sudo mkdir /var/www/html/moodledata
Enable permission for the Apache webserver user to access the files:

$ sudo chown -R www-data:www-data /var/www/html/moodle/
$ sudo chmod -R 755 /var/www/html/moodle/
$ sudo chown -R www-data:www-data /var/www/html/moodledata/
Step 7: Configure Apache Web Server for Moodle
Navigate to /etc/apache2/sites-available directory and run the following command to create a configuration file for your installation:

$ sudo nano /etc/apache2/sites-available/moodle.conf
Add the following content:

<VirtualHost *:80>

ServerAdmin webmaster@your-domain.com

ServerName your-domain.com
ServerAlias www.your-domain.com
DocumentRoot /var/www/html/moodle

<Directory /var/www/html/moodle/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
</Directory>

ErrorLog ${APACHE_LOG_DIR}/your-domain.com_error.log
CustomLog ${APACHE_LOG_DIR}/your-domain.com_access.log combined

</VirtualHost>
```
Активируйте виртуальный хост Apache
```bash
sudo a2ensite moodle.conf
```
Перезапустите службу
```bash
sudo systemctl restart apache2
```

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
      MYSQL_USER: wiki
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
7. Если вы всё сделали правильно, то при переходе на адрес хоста, на котором запущены контейнеры вас будет ждать следующая веб-страниа
<img width="347" alt="image" src="https://github.com/evn1111/DEMO2024/assets/138611344/61689498-0abb-4537-831d-54bf7904e526">

Нажимамем "Please set up the wiki first."

8. Выбираем язык
<img width="376" alt="image" src="https://github.com/evn1111/DEMO2024/assets/138611344/6d7f5226-4f3a-477d-8820-38ed18be2794">

9. Приступаем к настройке базы данных
<img width="529" alt="image" src="https://github.com/evn1111/DEMO2024/assets/138611344/776de038-b687-4832-b2bf-56dc022ea925">

10 Для того, чтобы узнать хост базы данных, пропишем
```bash
docker exec -it root-database-1 bash
```
Где "root-database-1" - имя запущенного контейнера, чтобы его уточнить, можно прописать 
```bash
docker ps
```
А после того, как вам удалось войти в контейнер БД, нужно прописать команду 
```bash
hostname -i
```
В результате чего, БД выдаст вам желаемый хост базы данных

11. Заполняем таблицу основываясь на wiki.yml файле и полученном хосте
<img width="524" alt="image" src="https://github.com/evn1111/DEMO2024/assets/138611344/80bd2043-413b-4021-a1d2-8188e7ff024a">

12. Создаём учетную запись
<img width="347" alt="image" src="https://github.com/evn1111/DEMO2024/assets/138611344/9c8ff72f-9bdb-41c0-9603-48c6d04bfd9f">

13. После проделанных манипуляций, сайт Mediawiki предложит вам скачать файл LocalSettings.php, который нужно скопировать в одну директорию с wiki.yml
```bash
cp /home/user/Downloads/LocalSettings.php /root/
```
14. Снимаем комментарий со строчки в wiki.yml
```bash
./LocalSettings.php:/var/www/html/LocalSettings.php
```

16. Перезапускаем контейнеры
```bash
docker-compose -f wiki.yml up -d
```
17. Mediawiki должно работать
<img width="959" alt="image" src="https://github.com/evn1111/DEMO2024/assets/138611344/59eb8d0e-141f-4cba-9e08-50290fdb3430">






