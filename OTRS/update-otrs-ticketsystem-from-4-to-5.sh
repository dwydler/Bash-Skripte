#!/bin/bash

service cron stop
service apache2 stop
service postfix stop

cd /opt/otrs/
su - otrs
bin/Cron.sh stop
bin/otrs.Scheduler.pl -a stop
logout


cd /opt
mv otrs otrs-old
git clone https://github.com/OTRS/otrs.git -b rel-5_0


cp /opt/otrs-old/Kernel/Config.pm /opt/otrs/Kernel/
cp /opt/otrs-old/Kernel/Config/GenericAgent.pm /opt/otrs/Kernel/Config/
cp /opt/otrs-old/Kernel/Config/Files/ZZZAuto.pm /opt/otrs/Kernel/Config/Files/
cp /opt/otrs-old/var/log/TicketCounter.log /opt/otrs/var/log/


cd /opt/otrs/var/cron
for foo in *.dist; do cp $foo `basename $foo .dist`; done


cd /opt/otrs/
bin/otrs.SetPermissions.pl --web-group=www-data


/opt/otrs/bin/otrs.CheckModules.pl
apt-get install -y libmime-base64-urlsafe-perl libauthen-sasl-perl libxml-libxml-perl libxml-libxslt-perl


cat scripts/DBUpdate-to-5.mysql.sql | mysql –p -f -u root otrs
su - otrs
bin/otrs.Console.pl Maint::Database::Check
scripts/DBUpdate-to-5.pl


cd /opt/otrs/
bin/otrs.Console.pl Maint::Config::Rebuild
bin/otrs.Console.pl Maint::Cache::Delete
logout


cp /opt/otrs-old/var/article/* /opt/otrs/var/article/ -R
/opt/otrs/bin/otrs.SetPermissions.pl --web-group=www-data


service postfix start
service apache2 start
service cron start


su - otrs
/opt/otrs/bin/otrs.Daemon.pl start
/opt/otrs/bin/Cron.sh start
logout