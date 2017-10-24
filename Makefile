build-sdk:
	docker build -t dicegroup/halyard-sdk:1.0.0-halyard1.2 ./sdk

run-sdk: build-sdk
	docker run -it --rm --network hbase --env-file ./hbase.env dicegroup/halyard-sdk:1.0.0-halyard1.2 /bin/bash

add-rdf:
	docker run -it --rm --network hbase --volume $(shell pwd)/rdf:/rdf --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.7.4-java8 hadoop fs -copyFromLocal -f /rdf/foaf.rdf /
	docker run -it --rm --network hbase --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.8-java8 hadoop fs -rm -f -r /tmp
	docker run -it --rm --network hbase --volume $(shell pwd)/rdf:/rdf --env-file ./hadoop.env --env-file ./hbase.env dicegroup/halyard-sdk:1.0.0-halyard1.2 bulkload /foaf.rdf /tmp halyardtable

build-webapps:
	docker build -t dicegroup/halyard-webapps:1.0.0-halyard1.2 ./webapps

run-webapps: build-webapps
	docker service create --name halyard --label traefik.docker.network=hbase --label traefik.port=8080 --network hbase --env-file ./webapps.env --publish 8081:8080 dicegroup/halyard-webapps:1.0.0-halyard1.2

make-dirs:
	mkdir -p benchmark
	mkdir -p iguana

get-data-10: make-dirs
	wget http://benchmark.dbpedia.org/benchmark_10.nt.bz2 -O benchmark/benchmark_10.nt.bz2
	bunzip2 benchmark/benchmark_10.nt.bz2

load-data-10:
	docker run -it --rm --network hbase --volume $(shell pwd)/benchmark:/benchmark --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.7.4-java8 hadoop fs -copyFromLocal -f /benchmark/benchmark_10.nt /
	docker run -it --rm --network hbase --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.7.4-java8 hadoop fs -rm -f -r /tmp
	docker run --name benchmark-load-10 --network hbase --env-file ./webapps.env dicegroup/halyard-sdk:1.0.0-halyard1.2 bulkload /benchmark_10.nt /tmp benchmark10

get-data-50:
	wget http://benchmark.dbpedia.org/benchmark_50.nt.bz2 -O benchmark/benchmark_50.nt.bz2
	bunzip2 benchmark/benchmark_50.nt.bz2

load-data-50:
	docker run -it --rm --network hbase --volume $(shell pwd)/benchmark:/benchmark --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.7.4-java8 hadoop fs -copyFromLocal -f /benchmark/benchmark_50.nt /
	docker run -it --rm --network hbase --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.7.4-java8 hadoop fs -rm -f -r /tmp
	docker run -d --name benchmark-load-50 --network hbase --env-file ./webapps.env dicegroup/halyard-sdk:1.0.0-halyard1.2 bulkload /benchmark_50.nt /tmp benchmark50

get-data-100:
	wget http://benchmark.dbpedia.org/benchmark_100.nt.bz2 -O benchmark/benchmark_100.nt.bz2
	bunzip2 benchmark/benchmark_100.nt.bz2

load-data-100:
	docker run -it --rm --network hbase --volume $(shell pwd)/benchmark:/benchmark --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.7.4-java8 hadoop fs -copyFromLocal -f /benchmark/benchmark_100.nt /
	docker run -it --rm --network hbase --env CORE_CONF_fs_defaultFS=hdfs://namenode:9000 bde2020/hadoop-base:1.2.0-hadoop2.7.4-java8 hadoop fs -rm -f -r /tmp
	docker run -d --name benchmark-load-100 --network hbase --env-file ./webapps.env dicegroup/halyard-sdk:1.0.0-halyard1.2 bulkload /benchmark_100.nt /tmp benchmark100

continue-data-load:
	docker run -it --name continue-data-load --network hbase --env-file ./webapps.env  dicegroup/halyard-sdk:1.0.0-halyard1.2 hbase org.apache.hadoop.hbase.tool.LoadIncrementalHFiles hdfs://namenode:9000/tmp benchmark100
