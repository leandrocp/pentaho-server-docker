# Pentaho BI Server 5.x

Easy-to-Use business intelligence (BI) for all

![logo](http://community.pentaho.com/img/logo-pentaho.svg)

> [http://community.pentaho.com/](http://community.pentaho.com/)

> Version: 5.3

## How to use this image

### Start a PostgreSQL instance

``` 
docker run --name some-postgres \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=password \
-d postgres
```

### Start Pentaho BI Server

``` 
docker run --name pentaho \
--link some-postgres:postgres \
-e TIMEZONE="America/Sao_Paulo" \
-e DB_USER=postgres \
-e DB_PASS=password \
-d leandrocp/pentaho-server
```

### Open Admin

Open [http://dockerhost:8080/](http://dockerhost:8080/) and fill credentials:

* User Name: admin
* Password: password

### Deploy on [Tutum](http://tutum.com)

See [tutum.yml](https://github.com/leandrocp/pentaho-server-docker/blob/master/tutum.yml)

[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)

## Environment Variables

### PostgreSQL

You have to set the following variable:

* `POSTGRES_PASSWORD`

See: [https://registry.hub.docker.com/_/postgres/](https://registry.hub.docker.com/_/postgres/)

### Pentaho

* `DB_HOST` - default: linked `postgres` container
* `DB_USER` - default: "postgres"
* `DB_PASS` - default: "password"
* `DB_PORT` - default: 5432
* `DB_SERVICE_NAME` - default: empty. See TODO
* `TIMEZONE` - default: "America/Sao_Paulo"
* `LOCALE` - default: "en_US.UTF-8 UTF-8"
* `LANG` - default: en_US.UTF-8
* `INSTALL_PLUGINS` - default: false

## Notes

* This image doen´t work without PostgreSQL and has no sample data loaded.
* It's recommended at least *2GB* memory
* The server takes a little to load, wait for the message:
```
Pentaho BI Platform server is ready.
...
Server startup in 173920 ms
```

## See Also

* [https://github.com/wmarinho/docker-pentaho](https://github.com/wmarinho/docker-pentaho)

## License

[MIT Licensed](https://github.com/leandrocp/pentaho-server-docker/blob/master/LICENSE.md)
