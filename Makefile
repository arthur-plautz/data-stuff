export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

setup_mysql:
	sudo apt update
	sudo apt install mysql-server

load_source:
	cd db
	[ ! -d "source_data" ] && git clone https://github.com/datacharmer/test_db.git source_data
	cd source_data
	mysql --host=0.0.0.0 --port=3307 -uroot -proot < employees.sql

build_database:
	docker rm -f mysql-employees || true
	docker run --name mysql-employees --network=bridge \
	 -v $(PWD)/db/mysql_data:/var/lib/mysql \
	 -e MYSQL_ROOT_PASSWORD=$(DB_PASSWORD) \
	 -p $(DB_PORT):3306 \
	 -d mysql
