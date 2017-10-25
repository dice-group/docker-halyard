DOCKER_NETWORK = dockerhalyard_default
HADOOP_ENV_FILE = hadoop.env
HBASE_ENV_FILE = hbase.env
current_branch := $(shell git rev-parse --abbrev-ref HEAD)
HADOOP_VERSION := 2.0.0-hadoop2.7.4-java8

build: build-sdk build-webapps

build-sdk:
	docker build -t dicegroup/halyard-sdk:${current_branch} ./sdk
build-webapps:
	docker build -t dicegroup/halyard-webapps:${current_branch} ./webapps

run-sdk: build-sdk
	docker run -it --rm --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} dicegroup/halyard-sdk:${current_branch} /bin/bash
run-webapps: build-webapps
	docker service create --name halyard --label traefik.docker.network=hbase --label traefik.port=8080 --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} --publish 8081:8080 dicegroup/halyard-webapps:${current_branch}

add-rdf:
	docker run -it --rm --network ${DOCKER_NETWORK} --volume $(shell pwd)/rdf:/rdf --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -copyFromLocal -f /rdf/foaf.rdf /
	docker run -it --rm --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -rm -f -r /tmp
	docker run -it --rm --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} dicegroup/halyard-sdk:${current_branch} bulkload /foaf.rdf /tmp halyardtable

make-dirs:
	mkdir -p benchmark
	mkdir -p iguana

get-data-10: make-dirs
	wget http://benchmark.dbpedia.org/benchmark_10.nt.bz2 -O benchmark/benchmark_10.nt.bz2
	bunzip2 benchmark/benchmark_10.nt.bz2

load-data-10:
	docker run -it --rm --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} --volume $(shell pwd)/benchmark:/benchmark bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -copyFromLocal -f /benchmark/benchmark_10.nt /
	docker run -it --rm --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -rm -f -r /tmp
	docker run --name benchmark-load-10 --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} dicegroup/halyard-sdk:${current_branch} bulkload /benchmark_10.nt /tmp benchmark10

get-data-50:
	wget http://benchmark.dbpedia.org/benchmark_50.nt.bz2 -O benchmark/benchmark_50.nt.bz2
	bunzip2 benchmark/benchmark_50.nt.bz2

load-data-50:
	docker run -it --rm --network ${DOCKER_NETWORK} --volume $(shell pwd)/benchmark:/benchmark  --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -copyFromLocal -f /benchmark/benchmark_50.nt /
	docker run -it --rm --network ${DOCKER_NETWORK}  --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -rm -f -r /tmp
	docker run -d --name benchmark-load-50 --network ${DOCKER_NETWORK}  --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} dicegroup/halyard-sdk:${current_branch} bulkload /benchmark_50.nt /tmp benchmark50

get-data-100:
	wget http://benchmark.dbpedia.org/benchmark_100.nt.bz2 -O benchmark/benchmark_100.nt.bz2
	bunzip2 benchmark/benchmark_100.nt.bz2

load-data-100:
	docker run -it --rm --network ${DOCKER_NETWORK} --volume $(shell pwd)/benchmark:/benchmark --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -copyFromLocal -f /benchmark/benchmark_100.nt /
	docker run -it --rm --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} bde2020/hadoop-base:${HADOOP_VERSION} hadoop fs -rm -f -r /tmp
	docker run -d --name benchmark-load-100 --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} dicegroup/halyard-sdk:${current_branch} bulkload /benchmark_100.nt /tmp benchmark100

continue-data-load:
	docker run -it --name continue-data-load --network ${DOCKER_NETWORK} --env-file ${HADOOP_ENV_FILE} --env-file ${HBASE_ENV_FILE} dicegroup/halyard-sdk:${current_branch} hbase org.apache.hadoop.hbase.tool.LoadIncrementalHFiles hdfs://namenode:9000/tmp benchmark100
