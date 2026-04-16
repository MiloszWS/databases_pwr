
# System for booking with personal trainers

Simple project for advanced databases course on the University.



## Prerequisites for installation
To install project there is needed uvicorn tool and local server database generator (for example XAMPP).

#### To install uvicorn:
```text
  macOS / Linux: curl -LsSf https://astral.sh/uv/install.sh | sh
  Windows (PowerShell): powershell -c "irm https://astral.sh | iex"
```
#### To install XAMPP:
```text
  Download it from official site: https://www.apachefriends.org/pl/index.html
```

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
  1. Open XAMPP and run MySQL server

  2. In Your IDE create connection with running server. (In VS Code use Database Client extension)

  3. To create basic structure of database open db/reset.sql and run that SQL code.

  4. To create massive data seed run app/generate_data.py

  5. To start running aplication paste in terminal: uvicorn app.main:app --reload
```


## Documentation

- [Tips and helpful commands](./others/commands.md)
- [Available endpoints](./others/endpoints.md)

## Authors

- [@MiloszWS](https://github.com/MiloszWS)
- [@zwyklylukasz](https://github.com/zwyklylukasz)

