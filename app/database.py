import os
from sqlalchemy import create_engine, text

# Połączenie: użytkownik root, brak hasła, localhost, port 3306, baza booksy_db
DATABASE_URL = "mysql+pymysql://root:@localhost:3306/booksy_db"

engine = create_engine(DATABASE_URL, pool_pre_ping=True) #pool_pre_ping odswieza polaczenie, bo xampp sam z sibie potrafi sie wylaczyc

#To jest po to abym nie musiał za każdym razem hardkodowac "connection.execute"
def get_sql_query(query_name: str):
    current_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(current_dir)
    file_path = os.path.join(project_root, "sql", f"{query_name}.sql")

    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Nie znaleziono pliku z kwerendą: {file_path}")

    with open(file_path, "r", encoding="utf-8") as f:
        return text(f.read())