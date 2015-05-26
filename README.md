# Pentaho BI Server 5.x

Easy-to-Use business intelligence (BI) for all

![logo](http://community.pentaho.com/img/logo-pentaho.svg)

> [http://community.pentaho.com/](http://community.pentaho.com/)

> Version: 5.3

## How to use this image

### Start a PostgreSQL instance

``` 
docker run --name postgres \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=password \
-d postgres
```

### Start Pentaho BI Server

``` 
docker run --name pentaho \
--link postgres:database \
-e TIMEZONE="America/Sao_Paulo" \
-e LOCALE="pt_BR" \
-e DB_USER=postgres \
-e DB_PASS=password \
-d leandrocp/pentaho-server
```

## Environment Variables

### PostgreSQL

You have to set the following variables:

* `POSTGRES_USER`
* `POSTGRES_PASSWORD`

See: https://registry.hub.docker.com/_/postgres/

### Pentaho

* `DB_USER` - default: "postgres"
* `DB_PASS` - default: "password"
* `TIMEZONE` - default: "America/Sao_Paulo"
* `LANG` - default: "pt_BR.UTF-8"

## Note

This image doen´t work without PostgreSQL and has no sample data loaded.

## TODO

* Improve database user/password params on conf files

## License

[MIT Licensed](https://github.com/leandrocp/pentaho-server-docker/blob/master/LICENSE.md).
