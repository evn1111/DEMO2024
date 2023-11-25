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
```bash
cp $CONFIG_FILE $BACKUP_FILE
```
7. Для того, чтобы пользователь понимал, что bash скрипт выполнение успешно, добавим вывод строки с помощью echo c указанием созданных раннее переменных
```bash
echo "Backup of $CONFIG_FILE saved to $BACKUP_FILE"
```
## Модуль 2 задание 3

Настройка домена на Debian реализуется с помощью FreeIPA.

FreeIPA — это решение для управления идентификацией с открытым исходным кодом для операционных систем Linux/Unix. Это дочерний проект RedHat Identity Management System, который предоставляет решения для аутентификации и авторизации для систем Linux/Unix.

Перед настройкой, убедитесь, что вы выполнили 1 и 2 задания 2 модуля, ибо без корректно натсроенных службы NTP и DNS могут возникунть ошибки.

Сначала введите следующую команду apt, чтобы установить основные зависимости.
```bash
sudo apt install curl gnupg git lsb-release
```
![image](https://github.com/evn1111/DEMO2024/assets/138611344/e0574f6c-6a08-4c26-aa77-085a3400b5fe)

Затем добавьте и загрузите ключ GPG репозитория Docker CE.

```bash
sudo mkdir -m 0755 -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
После добавления ключа GPG введите следующую команду, чтобы добавить репозиторий Docker CE.

```bash
echo 

  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu 

  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
![image](https://github.com/evn1111/DEMO2024/assets/138611344/31db1f23-3035-4522-9f58-0341a02f2a25)

Теперь запустите приведенную ниже команду «apt update», чтобы обновить индекс вашего пакета Debian.

```bash
sudo apt update
```
![image](https://github.com/evn1111/DEMO2024/assets/138611344/c332793b-c44f-470f-801a-424daee66365)

Затем установите пакеты Docker CE, введя команду «apt install» ниже. Введите y для подтверждения при появлении запроса и нажмите ENTER, чтобы продолжить.

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

![image](https://github.com/evn1111/DEMO2024/assets/138611344/3e3749ff-d255-4870-ad71-d4c232834ee4)

Если Docker CE установлен, он также автоматически запускается и включается. выполните команду systemctl ниже, чтобы проверить службу Docker.

```bash
sudo systemctl is-enabled docker

sudo systemctl status docker
```

![image](https://github.com/evn1111/DEMO2024/assets/138611344/580b61bf-402d-4c44-a6c7-38267d7f6aad)

Наконец, если вы планируете запускать приложение Docker от пользователя без полномочий root, вам необходимо добавить своего пользователя в группу «docker». Введите следующую команду, чтобы добавить пользователя в группу «docker». В этом примере вы добавите пользователя «user» в группу «docker».

```bash
sudo usermod -aG docker user
```
Теперь выполните следующую команду git, чтобы загрузить репозиторий freeipa-container в вашу систему. Затем переместите в него свой рабочий каталог.

```bash
git clone https://github.com/freeipa/freeipa-container.git

cd freeipa-container
```

![image](https://github.com/evn1111/DEMO2024/assets/138611344/3ae349c9-b310-4dc5-9e4c-457c773b3ea1)

Теперь запустите приведенную ниже команду «ls», чтобы проверить список файлов и каталогов в репозитории «freeipa-container». Вы должны увидеть несколько файлов Dockerfile, которые вы можете использовать для настройки сервера FreeIPA в вашей системе Debian.

```bash
ls
```

![image](https://github.com/evn1111/DEMO2024/assets/138611344/280d11ab-f678-48ea-be7c-f1f72998f94a)

Затем введите следующую команду, чтобы создать новый образ Docker сервера FreeIPA. В этом примере вы создадите образ Docker-сервера FreeIPA на основе «AlmaLinux 9» и будет называться «freeipa-almalinux9».

```bash
docker build -t freeipa-almalinux9 -f  Dockerfile.almalinux-9 .
```

После выполнения команды docker build вы должны увидеть процесс сборки образа Docker для сервера FreeIPA.

![image](https://github.com/evn1111/DEMO2024/assets/138611344/ba6030be-2030-4f7b-9f74-ebbb6e4c3765)

Выполните следующую команду, чтобы проверить список образов Docker, доступных в вашей системе. Вы должны увидеть образ Docker под названием «freeipa-almalinux9», созданный и доступный в вашей системе.

```bash
docker images
```

![image](https://github.com/evn1111/DEMO2024/assets/138611344/263978e2-4840-477b-8ba1-f8c753038b74)



## Модуль 2 задание 4

Вначале установим на каждом сервере необходимые компонент
1. Установите и настройте Samba на сервере HQ-SRV, если он еще не установлен. Выполните команду для установки Samba (если она еще не установлена):

Установите на HQ-SRV пакет nfs-kernel-server, которы позволит вам предоставлять доступ к вашим каталогам. Поскольку это первая операция, которую вы выполняете с помощью apt в этом сеансе, обновите индекс локальных пакетов перед установкой:

```bash
sudo apt update
sudo apt install nfs-kernel-server
```
После установки пакетов переключитесь на клиентский сервер

На клиенте необходимо установить пакет nfs-common, обеспечивающий функции NFS без добавления каких-либо серверных компонентов. Обновите индекс локальных пакетов перед установкой, чтобы гарантированно использовать актуальную информацию:

Для начала создайте каталоги

```bash
mkdir /shares/network -p
mkdir /shares/branch_files -p
mkdir /shares/admin_files -p
```

Для настройки экспорта каталога, откройте следующие записи:

```bash
/share/network client_ip(rw,sync,no_roo_squash)
/share/branch_files client_ip(rw,sync,no_roo_squash)
/share/admin_files client_ip(rw,sync,no_roo_squash)
```
Здесь мы используем для обоих каталогов одинаковые параметры конфигурации, за исключением no_root_squash. Посмотрим, что означают эти опции:

rw: эта опция дает клиенту доступ к чтению и записи на соответствующем томе.
sync: эта опция принудительно заставляет NFS записывать изменения на диске, прежде чем отправлять ответ. В результате мы получаем более стабильную и согласованную среду, поскольку в ответе отражается фактическое состояние удаленного тома. Однако при этом снижается скорость операций с файлами.
no_subtree_check: данная опция предотвращает проверку вложенного дерева, когда хост проверяет фактическую доступность файла в экспортированном дереве при каждом запросе. Это может вызвать много проблем в случае переименования файла, когда он открыт на клиентской системе. Проверку вложенного дерева в большинстве случаев лучше отключить.
no_root_squash: по умолчанию NFS преобразует запросы удаленного пользователя root в запросы пользователя без привилегий на сервере. Это предназначено для обеспечения безопасности, чтобы пользователь root клиентской системы не мог использовать файловую систему хоста с правами root. Опция no_root_squash отключает такое поведение для определенных общих ресурсов.
Нам нужно создать строку для каждого каталога, к которым мы планируем предоставить общий доступ. Обязательно замените сокращение client_ip своим реальным IP-адресом:

Для безопасности NFS преобразует любые операции root на клиенте в операции с учетными данными nobody:nogroup. В связи с этим, нам необходимо изменить владельца каталога для соответствия этим учетным данным.

```bash
sudo systemctl restart nfs-kernel-server
```

Когда вы закончите внесение изменений, сохраните и закройте файл. Чтобы сделать общие ресурсы доступными для настроенных клиентов, перезапустите сервер NFS с помощью следующей команды:

```bash
chown nobody:nogroup /shares/network
chown nobody:nogroup /shares/branch_files
chown nobody:nogroup  /shares/admin_files
```

```bash
sudo apt update
sudo apt install nfs-common
```

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
Добавьте Apache2 в автозапуск.

```bash
sudo systemctl enable apache2
```

Для провекра первичной работоспособности яндекс зайдите в браузер и в поисковой строке введите ваш IP-адрес.

```bash
http://your-IP-address
```
![image](https://github.com/evn1111/DEMO2024/assets/138611344/47180cb7-317f-40c5-8d5d-7e0b31bcb7a8)

Для установки PHP для Moodle, скачиваем пакеты.

```bash
sudo apt install php libapache2-mod-php php-iconv php-intl php-soap php-zip php-curl php-mbstring php-mysql php-gd php-xml php-pspell php-json php-xmlrpc
```

Проверить наличие PHP можно командой:

```bash
php -v
```

Вы должны получить такой ответ:

```bash
Output: PHP 7.4.28 (cli) (built: Feb 17 2022 16:17:19) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.28, Copyright (c), by Zend Technologies
```

Установка Базы Данных MariaDB осуществляется следующей командой:

```bash
sudo apt install mariadb-server mariadb-client
```

Добавьте MariaDB в автозагрузку.

```bash
sudo systemctl enable mariadb
```

Для дальнейшей работы, нужно отредактировать конфигурационный файл MariaDB.

```
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Добавьте следующие строки:

```bash
default_storage_engine = innodb
innodb_file_per_table = 1
innodb_file_format = Barracuda
```
Перезапустите службу
```bash
sudo systemctl restart mariadb
```

Для создания базы данных в MariaDB, сначала войдите в неё.

```bash
sudo  mysql -u root
```

Чтобы создать базу данных, пользователя базы данных и выдать все привелегии, нужно прописать:

```bash
MariaDB [(none)]> CREATE DATABASE moodledb;
MariaDB [(none)]> CREATE USER 'moodle_user'@'localhost' IDENTIFIED BY 'Moodle_Passw0rd!';
MariaDB [(none)]> GRANT ALL ON moodledb.* TO 'moodle_user'@'localhost';
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> EXIT
```

Установка Moodle производится с помощью команды:

```bash
sudo wget https://download.moodle.org/download.php/direct/stable400/moodle-4.0.1.zip
```

После загрузки, распакуйте скаченные файлы и сохраните их в директорию  для html.

```bash
sudo unzip moodle-4.0.1.zip -d /var/www/html/
```

Создайте директорию для Moodle.

```bash
sudo mkdir /var/www/html/moodledata
```

Настройте права доступа для созданной диреткории.

```bash
sudo chown -R www-data:www-data /var/www/html/moodle/
sudo chmod -R 755 /var/www/html/moodle/
sudo chown -R www-data:www-data /var/www/html/moodledata/
```

Создайте конфигурационный файл Apache для сайта.

```bash
nano /etc/apache2/sites-available/moodle.conf
```

Файл должен выглядить следующим образом:

```bash
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

Активируйте виртуальный хост Apache.

```bash
sudo a2ensite moodle.conf
```

Перезапустите службу.

```bash
sudo systemctl restart apache2
```

Чтобы получить доступ к веб-установки, открой браузер и перейдите по IP-адресу/DNS имени на ваш хост.

```bash
http://your-domain.com
```

В появившемся окне, выберите язык

![image](https://github.com/evn1111/DEMO2024/assets/138611344/120189d1-2cf5-4679-b9b5-c34a38f02e51)
Настройте URL-адрес, корневой веб-каталог и каталог данных, а затем нажмите «Далее»

![image](https://github.com/evn1111/DEMO2024/assets/138611344/c93ee33a-1b18-4602-ba71-15fc279ce9aa)
Настройте «драйвер базы данных», используйте сервер базы данных MariaDB и нажмите «Далее»

![image](https://github.com/evn1111/DEMO2024/assets/138611344/ae735653-3dda-4dad-a84d-d34bd243e96f)
Введите информацию о базе данных и нажмите «Далее», чтобы продолжить

![image](https://github.com/evn1111/DEMO2024/assets/138611344/d19606a4-5891-4af8-a2e5-1f159b209352)
Примите Соглашение об авторском праве и нажмите «Продолжить»

![image](https://github.com/evn1111/DEMO2024/assets/138611344/d43f8e18-cde7-4fae-af21-77b2c6ca94ed)
Система проверяет конфигурацию сервера и все расширения PHP, необходимые для Moodle

![image](https://github.com/evn1111/DEMO2024/assets/138611344/f958edee-27a6-425f-9d93-52961aa9492b)
Если все требования выполнены, нажмите «Продолжить»

![image](https://github.com/evn1111/DEMO2024/assets/138611344/5ffcad3e-b76a-4fcf-b1bc-aad9aaa7c3a8)
Убедитесь, что все результаты «Success». Затем снова нажмите «Продолжить»

![image](https://github.com/evn1111/DEMO2024/assets/138611344/b85ab35e-d92f-4b52-8917-0a7d7184a05b)
Заполните информацию об администраторе и нажмите «Обновить профиль»

![image](https://github.com/evn1111/DEMO2024/assets/138611344/869177fb-00e6-4767-9bb6-f3fbe17cfb4d)
Вы будете перенаправлены на панель администратора

![image](https://github.com/evn1111/DEMO2024/assets/138611344/b509f0a3-42fa-4911-bc20-4db2598845c3)

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






