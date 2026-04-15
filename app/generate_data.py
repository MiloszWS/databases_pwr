import random
from datetime import datetime, timedelta
from faker import Faker
from sqlalchemy import text
from database import engine

# Ustawiamy polski język dla realistycznych danych
fake = Faker('pl_PL')

# Parametry generowania
NUM_GYMS = 100
NUM_TRAINERS = 300
NUM_SLOTS = 100000

def generate_massive_data():
    print("Starting data generation")

    with engine.begin() as conn:
        # 1. Pobieramy dostępne ID województw i usług (zakładamy, że są w bazie po restarcie)
        voivodeships = [row.id for row in conn.execute(text("SELECT id FROM voivodeships")).fetchall()]
        services = [dict(row._mapping) for row in conn.execute(text("SELECT id, is_group, default_duration FROM services")).fetchall()]
        
        if not voivodeships or not services:
            print("Error! Data reference (voivodeships or services) is missing. Please run the reset.sql script first to populate these tables.")
            return

        # 2. Generowanie Miast (~50 miast)
        print("City generation...")
        cities_data = [{"name": fake.city(), "voivodeship_id": random.choice(voivodeships)} for _ in range(50)]
        conn.execute(text("INSERT INTO cities (name, voivodeship_id) VALUES (:name, :voivodeship_id)"), cities_data)
        city_ids = [row.id for row in conn.execute(text("SELECT id FROM cities")).fetchall()]

        # 3. Generowanie Siłowni (~100 siłowni)
        print("Gyms generation...")
        gyms_data = [{
            "name": f"Fit Gym {fake.company()}",
            "city_id": random.choice(city_ids),
            "street_address": fake.street_address()
        } for _ in range(NUM_GYMS)]
        conn.execute(text("INSERT INTO gyms (name, city_id, street_address) VALUES (:name, :city_id, :street_address)"), gyms_data)
        gym_ids = [row.id for row in conn.execute(text("SELECT id FROM gyms")).fetchall()]

        # 4. Generowanie Trenerów (~300 trenerów)
        print("Trainers generation...")
        trainers_data = [{
            "full_name": fake.name(),
            "email": fake.unique.email(),
            "password_hash": "hashed_password_123",
            "phone": fake.phone_number()
        } for _ in range(NUM_TRAINERS)]
        conn.execute(text("INSERT INTO trainers (full_name, email, password_hash, phone) VALUES (:full_name, :email, :password_hash, :phone)"), trainers_data)
        trainer_ids = [row.id for row in conn.execute(text("SELECT id FROM trainers")).fetchall()]

        # 5. Łączenie Trenerów z Siłowniami i Usługami (Many-to-Many)
        print("Working on trainer-gym and trainer-service relationships...")
        trainer_gyms_data = []
        trainer_services_data = []
        
        for t_id in trainer_ids:
            # Trener pracuje w 1 do 3 siłowni
            assigned_gyms = random.sample(gym_ids, random.randint(1, 3))
            for g_id in assigned_gyms:
                trainer_gyms_data.append({"t_id": t_id, "g_id": g_id})
                
            # Trener oferuje od 1 do 3 usług
            assigned_services = random.sample([s['id'] for s in services], random.randint(1, 3))
            for s_id in assigned_services:
                trainer_services_data.append({"t_id": t_id, "s_id": s_id})

        # Ignorujemy błędy duplikatów (INSERT IGNORE) na wypadek losowych powtórzeń
        conn.execute(text("INSERT IGNORE INTO trainer_gyms (trainer_id, gym_id) VALUES (:t_id, :g_id)"), trainer_gyms_data)
        conn.execute(text("INSERT IGNORE INTO trainer_services (trainer_id, service_id) VALUES (:t_id, :s_id)"), trainer_services_data)

        # 6. Generowanie 100 000 Slotów!
        print(f"Generating {NUM_SLOTS} slots...")
        slots_data = []
        
        # Generujemy daty od dzisiaj (15 Kwietnia 2026) przez kolejne 180 dni
        start_date = datetime(2026, 4, 15, 8, 0, 0) 

        for i in range(NUM_SLOTS):
            t_id = random.choice(trainer_ids)
            g_id = random.choice(gym_ids)
            service = random.choice(services)
            
            # Losowa data w ciągu najbliższego pół roku, losowa godzina między 8:00 a 20:00
            random_days = random.randint(0, 180)
            random_hours = random.randint(0, 12)
            slot_start = start_date + timedelta(days=random_days, hours=random_hours)
            slot_end = slot_start + timedelta(minutes=service['default_duration'])
            
            # Zależnie od usługi: trening personalny (1 miejsce), grupowe (np. 15 miejsc)
            capacity = 15 if service['is_group'] else 1

            slots_data.append({
                "trainer_id": t_id,
                "gym_id": g_id,
                "service_id": service['id'],
                "start_time": slot_start,
                "end_time": slot_end,
                "capacity": capacity,
                "is_group_class": service['is_group']
            })

            # BATCH INSERT: Wrzucamy do bazy paczkami po 5000, żeby nie "udusić" pythona i bazy
            if len(slots_data) >= 5000:
                conn.execute(text("""
                    INSERT INTO slots (trainer_id, gym_id, service_id, start_time, end_time, capacity, is_group_class) 
                    VALUES (:trainer_id, :gym_id, :service_id, :start_time, :end_time, :capacity, :is_group_class)
                """), slots_data)
                slots_data = [] # Czyścimy paczkę
                print(f"   ... generated {i+1} / {NUM_SLOTS}")

        # Wrzucamy resztkówkę, jeśli coś zostało
        if slots_data:
            conn.execute(text("""
                INSERT INTO slots (trainer_id, gym_id, service_id, start_time, end_time, capacity, is_group_class) 
                VALUES (:trainer_id, :gym_id, :service_id, :start_time, :end_time, :capacity, :is_group_class)
            """), slots_data)

    print("✅ Ready! Massive data generation completed.")

if __name__ == "__main__":
    generate_massive_data()