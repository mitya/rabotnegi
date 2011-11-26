* To restore the development database - 
  rake data:restore_dev src=tmp/db_110810_1510
  mongorestore -d rabotnegi_dev --drop tmp/db_110810_1510
  mongorestore -d rabotnegi_dev --drop tmp/db_110810_1510