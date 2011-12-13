* To restore the development database - 
  rake data:restore_dev src=tmp/db_110810_1510
  mongorestore -d rabotnegi_dev --drop tmp/db_110810_1510
  mongorestore -d rabotnegi_dev --drop tmp/db_110810_1510
  
  
* Resque
 PIDFILE=./tmp/resque.pid BACKGROUND=yes QUEUE=file_serve rake environment resque:work
 PIDFILE=./tmp/resque.pid BACKGROUND=yes QUEUE=* rake resque:work