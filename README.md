# docker-halyard

Docker image for [Halyard](https://github.com/merck/halyard) triplestore.

# How to use

## Standalone Halyard (one node local setup)

To deploy Halyard on one node:
```
docker-compose -f docker-compose-standalone.yml up -d
```

## Load data

```
make add-rdf
```

## Using Halyard Webapps

Open http://localhost:8080/rdf4j-workbench in your browser and create new repository with halyardtable name and id. The repo will contain the data loaded in the previous step.
