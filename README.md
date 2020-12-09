This image is compiled with `ENV TZ=America/Los_Angeles`

# To change the timezone compile your own image.
## To Build


#### Edit `Dockerfile.ubase` with Local Time Zone:
```
FROM ubuntu

# Set Local Time Zone
ENV TZ=America/Los_Angeles
...
```

#### Edit `Dockerfile.ubuntu` with Local Time Zone:
```
FROM blackmore-ubase as build

RUN echo "In build stage"

FROM ubuntu

# Set Local Time Zone
ENV TZ=America/Los_Angeles
...
```

#### Log in to [Docker Hub](https://hub.docker.com).

`docker login`

#### Build 

`moreBuilder/build.sh`

