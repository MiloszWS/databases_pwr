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
            return {"trainers": trainers_list}

    except Exception as e:
        # Obsługa błędu jeśli nie stworzymy pliku
        raise HTTPException(status_code=500, detail=f"Błąd bazy: {str(e)}")
@app.get("/slots")
def get_available_slots():
    query = get_sql_query("get_available_slots")
    with engine.connect() as conn:
        result = conn.execute(query)
        return {"available_slots": [dict(row._mapping) for row in result]}
@app.post("/book")
def make_booking(slot_id: int, client_id: int):
    query = get_sql_query("create_booking")
    with engine.begin() as conn:  # engine.begin automatycznie zatwierdzi zmiany (commit)
        result = conn.execute(query, {"sid": slot_id, "cid": client_id})

        # Jeśli nic nie wstawiono, znaczy że nie było miejsc
        if result.rowcount == 0:
            raise HTTPException(status_code=400, detail="Brak wolnych miejsc w tym slocie")

        return {"message": "Rezerwacja udana"}