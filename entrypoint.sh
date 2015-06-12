#!/bin/bash
set -e

DB_USER=${DB_USER:-postgres}
DB_PASS=${DB_PASS:-password}
DB_HOST=pentaho-database
DB_PORT=${DB_PORT:-5432}

function persist_dirs() {
  echo "-----> persist dirs"

  if [ ! -d /pentaho-data/pentaho-solutions ]; then
    mv $PENTAHO_HOME/biserver-ce/pentaho-solutions /pentaho-data/pentaho-solutions
    ln -s /pentaho-data/pentaho-solutions $PENTAHO_HOME/biserver-ce/pentaho-solutions
  fi

  if [ ! -d /pentaho-data/tomcat ]; then
    mv $PENTAHO_HOME/biserver-ce/tomcat /pentaho-data/tomcat
    ln -s /pentaho-data/tomcat $PENTAHO_HOME/biserver-ce/tomcat 
  fi
}

# TODO: Fix to work on Google Container Engine
function wait_database() {
  # TODO: Detect postgres port
  #port=$(env | grep DATABASE_PORT | grep TCP_PORT | cut -d = -f 2)
  port=5432

  echo -n "-----> waiting for database on $DB_HOST:$port ..."
  while ! nc -w 1 $DB_HOST $port 2>/dev/null
  do
    echo -n .
    sleep 1
  done

  echo '[OK]'
}

function setup_database() {
  echo "-----> setup database"
  wait_database

  sed -i "s/5432/${DB_PORT}/g" $PENTAHO_HOME/conf/repository.xml && \
  sed -i "s/\*\*password\*\*/${DB_PASS}/g" $PENTAHO_HOME/conf/repository.xml && \
  cp -fv $PENTAHO_HOME/conf/repository.xml \
    $PENTAHO_HOME/biserver-ce/pentaho-solutions/system/jackrabbit/repository.xml

  sed -i "s/5432/${DB_PORT}/g" $PENTAHO_HOME/conf/context.xml && \
  sed -i "s/\*\*password\*\*/${DB_PASS}/g" $PENTAHO_HOME/conf/context.xml && \
  cp -fv $PENTAHO_HOME/conf/context.xml \
    $PENTAHO_HOME/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml

  sed -i "s/5432/${DB_PORT}/g" $PENTAHO_HOME/conf/applicationContext-spring-security-hibernate.properties && \
  sed -i "s/\*\*password\*\*/${DB_PASS}/g" $PENTAHO_HOME/conf/applicationContext-spring-security-hibernate.properties && \
  cp -fv $PENTAHO_HOME/conf/applicationContext-spring-security-hibernate.properties \
    $PENTAHO_HOME/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties

  sed -i "s/5432/${DB_PORT}/g" $PENTAHO_HOME/conf/jdbc.properties && \
  sed -i "s/\*\*password\*\*/${DB_PASS}/g" $PENTAHO_HOME/conf/jdbc.properties && \
  cp -fv $PENTAHO_HOME/conf/jdbc.properties \
    $PENTAHO_HOME/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties

  sed -i 's/\\connect.*/\\connect quartz/g' \
    $PENTAHO_HOME/biserver-ce/data/postgresql/create_quartz_postgresql.sql

  sed -i 's/hsql/postgresql/g' \
    $PENTAHO_HOME/biserver-ce/pentaho-solutions/system/hibernate/hibernate-settings.xml

  sed -i 's/localhost/pentaho-database/g' \
    $PENTAHO_HOME/biserver-ce/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml

  sed -i 's/system\/hibernate\/hsql.hibernate.cfg.xml/system\/hibernate\/postgresql.hibernate.cfg.xml/g' \
    $PENTAHO_HOME/biserver-ce/pentaho-solutions/system/hibernate/hibernate-settings.xml

  export PGPASSWORD=$DB_PASS
  if ! psql -lqt -U $DB_USER -h pentaho-database | grep -w hibernate; then
    echo "-----> importing sql files"

    psql -U $DB_USER -h pentaho-database -f $PENTAHO_HOME/biserver-ce/data/postgresql/create_jcr_postgresql.sql
    psql -U $DB_USER -h pentaho-database -f $PENTAHO_HOME/biserver-ce/data/postgresql/create_quartz_postgresql.sql
    psql -U $DB_USER -h pentaho-database -f $PENTAHO_HOME/biserver-ce/data/postgresql/create_repository_postgresql.sql
    
    psql -U $DB_USER -h pentaho-database -c "ALTER USER pentaho_user WITH PASSWORD '${DB_PASS}'"
    psql -U $DB_USER -h pentaho-database -c "ALTER USER jcr_user WITH PASSWORD '${DB_PASS}'"
    psql -U $DB_USER -h pentaho-database -c "ALTER USER hibuser WITH PASSWORD '${DB_PASS}'"

    # http://jira.pentaho.com/browse/BISERVER-10639
    # https://github.com/wmarinho/docker-pentaho/blob/5.3/config/postgresql/biserver-ce/data/postgresql/create_quartz_postgresql.sql#L37
    psql -U $DB_USER -h pentaho-database quartz -c 'CREATE TABLE "QRTZ" ( NAME VARCHAR(200) NOT NULL, PRIMARY KEY (NAME) );'
  fi
  unset PGPASSWORD

  touch /pentaho-data/.database.ok
}

function setup_tomcat() {
  echo "-----> setup webserver"

  rm -rf "$PENTAHO_HOME/biserver-ce/tomcat/conf/Catalina/*"
  rm -rf "$PENTAHO_HOME/biserver-ce/tomcat/temp/*"
  rm -rf "$PENTAHO_HOME/biserver-ce/tomcat/work/*"

  cp -fv $PENTAHO_HOME/conf/web.xml \
    $PENTAHO_HOME/biserver-ce/tomcat/webapps/pentaho/WEB-INF/web.xml

  echo "org.pentaho.reporting.engine.classic.core.modules.output.pageable.pdf.Encoding=ISO-8859-1" >> \
    $PENTAHO_HOME/biserver-ce/tomcat/webapps/pentaho/WEB-INF/classes/classic-engine.properties

  touch /pentaho-data/.tomcat.ok
}

function setup_plugins() {
  echo "-----> setup plugins"

  if [ ! -f /pentaho-data/.plugins.ok ]; then
    echo "-----> install ctools"

    wget --no-check-certificate 'https://raw.github.com/pmalves/ctools-installer/master/ctools-installer.sh' -P / -o /dev/null

    chmod +x /ctools-installer.sh

    /ctools-installer.sh \
      -s $PENTAHO_HOME/biserver-ce/pentaho-solutions \
      -w $PENTAHO_HOME/biserver-ce/tomcat/webapps/pentaho \
      -c marketplace,cdf,cda,cde,cgg,cfr,sparkl,cdc,cdv,saiku,saikuadhoc \
      --no-update \
      -y

    touch /pentaho-data/.plugins.ok
  fi
}

if [ "$1" = 'run' ]; then
  persist_dirs
  setup_tomcat
  setup_database
  setup_plugins

  echo "-----> starting pentaho"
  $PENTAHO_HOME/biserver-ce/start-pentaho.sh
else
  exec "$@"
fi
