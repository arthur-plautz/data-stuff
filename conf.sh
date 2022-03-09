source .env
source scripts/local_ip.sh

export MYSQL_SOURCE_HOST=0.0.0.0
export MYSQL_SOURCE_PORT=3307

export PG_SOURCE_HOST=0.0.0.0
export PG_SOURCE_PORT=5435

export DW_HOST=0.0.0.0
export DW_PORT=5433

export KAFKA_PORT=29092