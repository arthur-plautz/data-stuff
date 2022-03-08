export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

setup_mysql:
	sudo apt update
	sudo apt install mysql-server

load_source:
	cd database
	[ ! -d "source_data" ] && git clone https://github.com/datacharmer/test_db.git source_data
	cd source_data
	mysql --host=0.0.0.0 --port=3307 -uroot -proot < employees.sql

build_mysql:
	docker rm -f mysql-employees || true
	docker run --name mysql-employees --network=bridge \
	 -v $(PWD)/database/mysql_data:/var/lib/mysql \
	 -e MYSQL_ROOT_PASSWORD=$(SOURCE_PASSWORD) \
	 -p $(SOURCE_PORT):3306 \
	 -d mysql

build_postgres:
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
	sed -i 's/your-port/$(SOURCE_PORT)/g' mysql-connector.json
	sed -i 's/your-user/$(SOURCE_USER)/g' mysql-connector.json
	sed -i 's/your-pass/$(SOURCE_PASSWORD)/g' mysql-connector.json

run_airflow:
	cd airflow
	docker-compose up -d

stop_airflow:
	cd airflow
	docker-compose stop

run_kafka:
	cd kafka
	docker-compose up -d

stop_kafka:
	cd kafka
	docker-compose stop