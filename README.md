# docker-deb-mythtv-mythweb

MythTV backend with Mythweb added, built with 'czartj/docker-deb-mythtv' as it's base
<br>

Added the **Environment variable**:
```
MYTH_WEB_PORT
```

Run with something like this:
```
docker  run --name mythbackend \
        -v /srv/nfs/mythtv/dvr1:/srv/nfs/mythtv/dvr1 \
        -v /srv/nfs/mythtv/dvr0:/srv/nfs/mythtv/dvr0 \
        -v /srv/nfs/mythtv/dvr3:/srv/nfs/mythtv/dvr3 \
        -v /data/syncthing/data/xmltv/:/xmltv \
        -v /etc/localtime:/etc/localtime \
        -e "MYTH_DATABASE_HOST=odh2p" \
        -e "MYTH_DATABASE_PORT=3306" \
        -e "MYTH_DATABASE_USER=mythtv" \
        -e "MYTH_DATABASE_PASSWORD=mythtv" \
        -e "MYTH_DATABASE_NAME=mythconverg" \
        -e "MYTH_WEB_PORT=8008" \
        --network="host" \
        czartj/docker-deb-mythtv-mythweb:latest
```

So running the example above use with use something such as:
```
       <Location /mythweb>
                ProxyPass http://localhost:8008/mythweb/
                ProxyPassReverse http://localhost:8008/mythweb/
        </Location>
```
For a apache2 reverse proxy...
