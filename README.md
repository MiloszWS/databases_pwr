
# System for booking with personal trainers

Simple project for advanced databases course on the University.



## Prerequisites for installation
To install project there is needed uvicorn tool and local server database generator (for example XAMPP).

#### To install uvicorn:
```text
  macOS / Linux: curl -LsSf https://astral.sh/uv/install.sh | sh
  Windows (PowerShell): powershell -c "irm https://astral.sh | iex"
```
#### To install XAMPP (optional eg. for apache benchmark):
```text
  Download it from official site: https://www.apachefriends.org/pl/index.html
```
#### To install Docker:
  Downaload and install Docker Desktop: https://www.docker.com/products/docker-desktop/

## Installation

#### With uv (recommended)

```bash
  # Clone the repository
  git clone https://github.com/MiloszWS/Databases_pwr.git
  
  # Navigate to the project directory
  cd Databases_pwr

  # Create the virtual environment, install package and dependencies
  uv sync

  # Activate the virtual environment
  source .venv/bin/activate
```
    
## Deployment

#### To deploy this project run

```text
  1. In terminal in your project run 'docker-compose up -d'

  2. In Your IDE create connection with running server. (In VS Code use Database Client extension)

  3. To create basic structure of database open db/reset.sql and run that SQL code.

  4. To create massive data seed run app/generate_data.py

  5. To start running aplication paste in terminal: uvicorn app.main:app --reload

  6. To close docker enter in terminal 'docker-compose down -v'

  7. To run Apache Benchmark go to ab.exe directory (if you have xampp it is in xampp/apache/bin) open powershell and run '.\ab.exe -n 1000 -c 50 http://127.0.0.1:8000/slots' where -n 1000 is number of request and -c 50 is number of hosts trying to connect to db
```


## Documentation

- [Tips and helpful commands](./others/commands.md)
- [Available endpoints](./others/endpoints.md)

## Authors

- [@MiloszWS](https://github.com/MiloszWS)
- [@zwyklylukasz](https://github.com/zwyklylukasz)

