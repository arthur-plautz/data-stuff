export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

setup_mysql:
	sudo apt update
	sudo apt install mysql-server

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
	 -e PGDATA=/var/lib/postgresql/data/pgdata \
     -v $(PWD)/database/postgres_data:/var/lib/postgresql/data \
	 -p $(PG_SOURCE_PORT):5432 \
	 -d postgres postgres -c wal_level=logical -c max_replication_slots=1

build_dw:
	docker rm -f data-warehouse || true
	docker run --name data-warehouse --network=bridge \
	 -e POSTGRES_USER=$(DW_USER) \
	 -e POSTGRES_PASSWORD=$(DW_PASSWORD) \
	 -e POSTGRES_DB="dw" \
	 -e PGDATA=/var/lib/postgresql/data/pgdata \
     -v $(PWD)/database/dw_data:/var/lib/postgresql/data \
	 -p $(DW_PORT):5432 \
	 -d postgres

load_mysql_source: build_mysql
	sleep 5
	cd database
	[ ! -d "mysql_source_data" ] && git clone https://github.com/datacharmer/test_db.git mysql_source_data
	cd mysql_source_data
	mysql --host=$(MYSQL_SOURCE_HOST) --port=$(MYSQL_SOURCE_PORT) -u$(MYSQL_SOURCE_USER) -p$(MYSQL_SOURCE_PASSWORD) < employees.sql

load_postgres_source: build_postgres
	sleep 5
	cd database/postgres_source_data
	PGPASSWORD=$(PG_SOURCE_PASSWORD) psql --host=$(PG_SOURCE_HOST) --port=$(PG_SOURCE_PORT) --user=$(PG_SOURCE_USER) northwind < northwind.sql

build_openmetadata_connector:
	cd catalog
	cp mysql-example.json mysql-connector.json
	sed -i 's/your-port/$(MYSQL_SOURCE_PORT)/g' mysql-connector.json
	sed -i 's/your-user/$(MYSQL_SOURCE_USER)/g' mysql-connector.json
	sed -i 's/your-pass/$(MYSQL_SOURCE_PASSWORD)/g' mysql-connector.json

build_debezium_postgres_connector:
	cd debezium
	cp postgres-example.json postgres-connector.json
	sed -i 's/your-user/$(PG_SOURCE_USER)/g' postgres-connector.json
	sed -i 's/your-pass/$(PG_SOURCE_PASSWORD)/g' postgres-connector.json
	sed -i 's/your-host/$(LOCAL_IP)/g' postgres-connector.json
	sed -i 's/your-port/$(PG_SOURCE_PORT)/g' postgres-connector.json

build_debezium_dw_connector:
	cd debezium
	cp dw-example.json dw-connector.json
	sed -i 's/your-user/$(DW_USER)/g' dw-connector.json
	sed -i 's/your-pass/$(DW_PASSWORD)/g' dw-connector.json
	sed -i 's/your-host/$(LOCAL_IP)/g' dw-connector.json
	sed -i 's/your-port/$(DW_PORT)/g' dw-connector.json

build_kafka:
	cd debezium
	docker-compose up -d

build_debezium: build_kafka
	docker build -t debezium-local debezium
	docker rm -f debezium || true
	docker run --name debezium --network=bridge \
	 -p 8083:8083 \
	 -e BOOTSTRAP_SERVERS=$(LOCAL_IP):29092 \
	 -e GROUP_ID=1 \
	 -e CONFIG_STORAGE_TOPIC=storage_config \
	 -e OFFSET_STORAGE_TOPIC=storage_offset \
	 -e STATUS_STORAGE_TOPIC=storage_status \
	 -e KEY_CONVERTER=io.confluent.connect.avro.AvroConverter \
     -e VALUE_CONVERTER=io.confluent.connect.avro.AvroConverter \
     -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=http://$(LOCAL_IP):8081 \
     -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=http://$(LOCAL_IP):8081 \
	 -d debezium-local

remove_debezium:
	docker rm -f debezium kafka-ui schema-registry kafka zookeeper

create_debezium_postgres_connector:
	cd debezium
	python create_connector.py postgres

create_debezium_dw_connector:
	cd debezium
	python create_connector.py dw

create_debezium_consumer:
	cd debezium
	python create_consumer.py

run_airflow:
	cd airflow
	docker-compose up -d

stop_airflow:
	cd airflow
	docker-compose stop
