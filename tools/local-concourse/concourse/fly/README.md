# fly CLI

## Commands

- EXECUTE TASK\
```fly -t ci execute -c <taskname.yml>```

- SET PIPELINE\
```fly -t ci set-pipeline -p geocoderService -c pipeline.yml```

- SET PIPELINE WITH ENV VARIABLES\
```fly -t ci set-pipeline -p geocoderService -c pipeline.yml -v here-app-code=CODE -v here-geocoder-url=https://geocoder.api.here.com/6.2/geocode.json -v geocoder-db-host=192.168.2.58 -v geocoder-db-port=15432 -v geocoder-db-user=postgres -v geocoder-db-password=local -v geocoder-db-name=geocoder_test```

## Sources
- Documentation\
https://concourse-ci.org/fly.html
