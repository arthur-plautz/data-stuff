export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

setup_mysql:
	sudo apt update
	sudo apt install mysql-server

load_mysql_source:
	cd database
	[ ! -d "mysql_source_data" ] && git clone https://github.com/datacharmer/test_db.git mysql_source_data
	cd mysql_source_data
	mysql --host=$(MYSQL_SOURCE_HOST) --port=$(MYSQL_SOURCE_PORT) -u$(MYSQL_SOURCE_USER) -p$(MYSQL_SOURCE_PASSWORD) < employees.sql

load_postgres_source:
	cd database/postgres_source_data
	PGPASSWORD=$(PG_SOURCE_PASSWORD) psql --host=$(PG_SOURCE_HOST) --port=$(PG_SOURCE_PORT) --user=$(PG_SOURCE_USER) postgres < northwind.sql

build_mysql:
	docker rm -f mysql-employees || true
	docker run --rm --name mysql-employees --network=bridge \
	 -v $(PWD)/database/mysql_data:/var/lib/mysql \
	 -e MYSQL_ROOT_PASSWORD=$(MYSQL_SOURCE_PASSWORD) \
	 -p $(MYSQL_SOURCE_PORT):3306 \
	 -d mysql

build_postgres:
	docker rm -f pg-northwind || true
	docker run --name pg-northwind --network=bridge \
	 -e POSTGRES_USER=$(PG_SOURCE_USER) \
	 -e POSTGRES_PASSWORD=$(PG_SOURCE_PASSWORD) \
	 -e POSTGRES_DB="northwind" \
	 -p $(PG_SOURCE_PORT):5432 \
	 -d postgres postgres -c wal_level=logical

build_dw:
	docker rm -f pg-dw || true
	docker run --name pg-dw --network=bridge \
	 -e POSTGRES_USER=$(DW_USER) \
	 -e POSTGRES_PASSWORD=$(DW_PASSWORD) \
	 -e POSTGRES_DB="pg_dw" \
	 -p $(DW_PORT):5432 \
	 -d postgres

build_mysql_connector:
	cd catalog
	cp mysql-example.json mysql-connector.json
	sed -i 's/your-port/$(MYSQL_SOURCE_PORT)/g' mysql-connector.json
	sed -i 's/your-user/$(MYSQL_SOURCE_USER)/g' mysql-connector.json
	sed -i 's/your-pass/$(MYSQL_SOURCE_PASSWORD)/g' mysql-connector.json

build_postgres_connector:
	cd debezium
	cp pg-connector-example.json pg-connector.json
	sed -i 's/your-port/$(PG_SOURCE_PORT)/g' pg-connector.json
	sed -i 's/your-user/$(PG_SOURCE_USER)/g' pg-connector.json
	sed -i 's/your-pass/$(PG_SOURCE_PASSWORD)/g' pg-connector.json

build_zookeeper:
	docker rm -f zookeeper || true
	docker run --name zookeeper \
	 -p 2181:2181 \
	 -d debezium/zookeeper:1.8

build_kafka: build_zookeeper
	docker rm -f kafka || true
	docker run --name kafka --link zookeeper:zookeeper \
	 -p 9092:9092 \
	 -d debezium/kafka:1.8

build_debezium: build_kafka
	docker rm -f debezium || true
	docker run --name debezium --link kafka:kafka --link pg-northwind:postgres \
	 -p 8083:8083 \
	 -e GROUP_ID=1 \
	 -e CONFIG_STORAGE_TOPIC=storage_config \
	 -e OFFSET_STORAGE_TOPIC=storage_offset \
	 -e STATUS_STORAGE_TOPIC=storage_status \
	 -d debezium/connect:1.8

run_airflow:
	cd airflow
	docker-compose up -d

stop_airflow:
	cd airflow
	docker-compose stop
