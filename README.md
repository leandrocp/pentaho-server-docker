# Pentaho BI Server 5.x

Easy-to-Use business intelligence (BI) for all

> [http://community.pentaho.com/](http://community.pentaho.com/)

![logo](http://community.pentaho.com/img/logo-pentaho.svg)

# How to use this image

## Start a PostgreSQL instance

``` 
docker run --name postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -d postgres
```

## Start Pentaho BI Server

``` 
docker run --name pentaho --link postgres:database -e DB_USER=postgres -e DB_PASS=password -d leandrocp/pentaho-server
```
