from fastapi import FastAPI, HTTPException
from app.database import engine, get_sql_query
from sqlalchemy import create_engine, text
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
        # 1. Pobierasz czysty tekst z pliku .sql
        query_string = get_sql_query("get_trainers")

        with engine.connect() as conn:
            # 2. Musisz użyć text(), aby SQLAlchemy zrozumiało kwerendę
            result = conn.execute(text(query_string))

            # 3. Mapowanie wyników
            trainers = [{"id": r.id, "name": r.full_name} for r in result]
            return {"status": "success", "data": trainers}
    except Exception as e:
        print(f"BŁĄD TRENERÓW: {e}")
        raise HTTPException(status_code=500, detail="Błąd pobierania trenerów")
@app.get("/slots")
def get_slots():
    try:
        # 1. Wczytujemy zapytanie z pliku
        query_string = get_sql_query("get_slots_data")

        with engine.connect() as conn:
            result = conn.execute(text(query_string))

            slots_list = []
            for row in result:
                # 2. Logika obliczeniowa (zamiast w widoku SQL, robimy to tutaj)
                remaining = row.capacity - row.occupied_count

                slots_list.append({
                    "id": row.id,
                    "time": row.start_time,
                    "trainer": row.trainer_name,
                    "location": f"{row.gym_name}, {row.city_name}",
                    "service": row.service_name,
                    "availability": {
                        "total": row.capacity,
                        "taken": row.occupied_count,
                        "free": remaining
                    },
                    "can_book": remaining > 0
                })

            return {"status": "success", "data": slots_list}

    except Exception as e:
        print(f"BŁĄD: {e}")
        raise HTTPException(status_code=500, detail="Błąd pobierania slotów")

@app.post("/book")
def make_booking(slot_id: int, client_id: int):
    # 1. Pobierasz surowy string kwerendy
    query = get_sql_query("create_booking")

    with engine.begin() as conn:
        # 2. OPAKUJESZ W text(), aby parametry (:sid, :cid) zadziałały
        result = conn.execute(text(query), {"sid": slot_id, "cid": client_id})

        if result.rowcount == 0:
            raise HTTPException(status_code=400, detail="Brak wolnych miejsc w tym slocie")

        return {"message": "Rezerwacja udana"}