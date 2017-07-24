build:
	docker build -t bde2020/halyard-sdk:1.0.0-halyard1.2 ./sdk

run-sdk: build
	docker run -it --rm --network hbase --env-file ./hbase.env bde2020/halyard-sdk:1.0.0-halyard1.2 /bin/bash

add-rdf: build
	docker run -it --rm --network hbase --volume $(shell pwd)/rdf:/rdf --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.8-java8 hadoop fs -copyFromLocal -f /rdf/foaf.rdf /
	docker run -it --rm --network hbase --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.8-java8 hadoop fs -rm -f -r /tmp
	docker run -it --rm --network hbase --volume $(shell pwd)/rdf:/rdf --env-file ./hadoop.env --env-file ./hbase.env bde2020/halyard-sdk:1.0.0-halyard1.2 bulkload /foaf.rdf /tmp halyardtable
