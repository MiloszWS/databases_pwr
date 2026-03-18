from fastapi import FastAPI
from sqlalchemy import create_engine, text

# Połączenie: użytkownik root, brak hasła, localhost, port 3306, baza booksy_db
DATABASE_URL = "mysql+pymysql://root:@localhost:3306/booksy_db"

engine = create_engine(DATABASE_URL)
app = FastAPI()

@app.get("/")
def get_trainers():
    # To zapytanie w przyszłości zamienimy na np. wyszukiwanie treningów dla klientów 
    with engine.connect() as connection:
        result = connection.execute(text("SELECT * FROM trainers"))
        
        trainers_list = []
        for row in result:
            trainers_list.append({"id": row.id, "name": row.full_name, "email": row.email})
            
        return {"trainers": trainers_list}