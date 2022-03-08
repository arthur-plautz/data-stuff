# data-stuff

## Setup

### Environment
Create a virtualenv:
```
virtualenv -p python3.8 venv
source venv/bin/activate
pip install -r requirements.txt
```

Create a .env file:
```bash
export MYSQL_SOURCE_USER=your-db-user
export MYSQL_SOURCE_PASSWORD=your-db-password

export POSTGRES_SOURCE_USER=your-db-user
export POSTGRES_SOURCE_PASSWORD=your-db-password

export DW_USER=your-db-user
export DW_PASSWORD=your-db-password
```

Source config file:
```bash
source conf.sh
```

### MySQL Source Database

Setup mysql CLI:
```bash
make setup_mysql
```

Build Source Database:
```bash
make build_mysql
```

Load Source Database:
```bash
make load_mysql_source
```

### Postgres Source Database

Build Source Database:
```bash
make build_postgres
```

Load Source Database:
```bash
make load_postgres_source
```

### OpenMetadata

[Here](https://docs.open-metadata.org/install/run-openmetadata) you can follow the full setup documentation.

Requirements:
- Docker (v20.10.0 or greater)
- Compose (v2)
- Python (v3.8 or greater)

Install OpenMetadata Deps:
```bash
pip install --upgrade pip setuptools
pip install --upgrade 'openmetadata-ingestion[docker]'
```

Install Ingestion Deps:
```bash
pip install 'openmetadata-ingestion[data-profiler]'
```

Build Connector File with Secrets:
```bash
make build_mysql_connector
```

Start OpenMetadata and Ingest:
```bash
cd catalog
metadata docker --start
metadata ingest -c ./mysql-connector.json
```
