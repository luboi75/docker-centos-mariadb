#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mysqld_safe "$@"
fi

if [ "$1" = 'mysqld_safe' ]; then
    echo 'tu som'
	DATADIR="/var/lib/mysql"
	if [ ! -d "$DATADIR/mysql" ]; then
		if [ -z "$ROOT_PASSWORD" ]; then
            ROOT_PASSWORD=pass4you
			echo 'Falling back to default passowrd'
		fi

		echo 'Running mysql_install_db ...'
		mysql_install_db --datadir="$DATADIR"
		echo 'Finished mysql_install_db'
        # allow mysql user to use newly created directory structure
        chown -R mysql:mysql "$DATADIR/"
		tempSqlFile='/tmp/mysql-first-time.sql'
		cat > "$tempSqlFile" <<-EOSQL
			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
		EOSQL

        if [ -z "$DB" ]; then
            DB=mydb
			echo 'Falling back to default db name'
        fi

		echo "CREATE DATABASE IF NOT EXISTS \`$DB\` ;" >> "$tempSqlFile"

        if [ -z "$MYSQL_USER" ]; then
            MYSQL_USER=root
			echo 'Falling back to default user'
        fi

		echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$ROOT_PASSWORD' ;" >> "$tempSqlFile"
		echo "GRANT ALL ON \`$DB\`.* TO '$MYSQL_USER'@'%' ;" >> "$tempSqlFile"
		echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"
		set -- "$@" --init-file="$tempSqlFile"
	fi
	
fi

exec "$@"
