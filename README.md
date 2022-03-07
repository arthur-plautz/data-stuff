# data-stuff

## Setup
Create a virtualenv:
```
virtualenv -p python3 venv
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

Build Source Database:
```bash
make setup_mysql
make build_database
make load_source
```
