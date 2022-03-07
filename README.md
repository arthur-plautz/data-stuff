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
export DB_USER=your-db-user
export DB_PASSWORD=your-db-password
```

Source config file:
```bash
source conf.sh
```

### Source Database

Setup mysql CLI:
```bash
make setup_mysql
```

Build Database:
```bash
make build_database
```

Load Source Database:
```bash
make load_source
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

Start OpenMetadata and Ingest:
```bash
cd catalog
metadata docker --start
metadata ingest -c ./mysql-connector.json
```
