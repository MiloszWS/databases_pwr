from fastapi import FastAPI, HTTPException
from app.database import engine, get_sql_query
app = FastAPI()

@app.get("/")
def welcome():
    return {
        "message": "Główne okno. Aplikacja działa poprawnie. Jeżeli chcesz zobaczyć daną kwerendę należy napisać w pasku adresu /'nazwa_endpointa'",
        "status": "online",
        "lista endpointów": "/docs"  # Podpowiadamy, gdzie szukać dokumentacji
    }
@app.get("/trainers")
def get_trainers():
    try:
        #Pobieramy treści kwerendy z pliku sql/get_trainers.sql
        query = get_sql_query("get_trainers")

        #Łączenie i wykonanie zapytania
        with engine.connect() as connection:
            result = connection.execute(query)

            trainers_list = []
            for row in result:
                trainers_list.append({"id": row.id, "name": row.full_name, "email": row.email})
            #ewentualnie mozna zrobić tak:
            #trainers_list = [dict(row._mapping) for row in result] - automatycznie zamienia wiersze na wyrazy
            return {"trainers": trainers_list}

    except Exception as e:
        # Obsługa błędu jeśli nie stworzymy pliku
        raise HTTPException(status_code=500, detail=f"Błąd bazy: {str(e)}")