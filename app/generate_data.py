import random
from datetime import datetime, timedelta
from faker import Faker
from sqlalchemy import text
from database import engine

# Polish language
fake = Faker('pl_PL')

# parameters
NUM_GYMS = 100
NUM_TRAINERS = 300
NUM_SLOTS = 100000

def generate_massive_data():
    print("Starting data generation")

    with engine.begin() as conn:
        # Downloading reference data for voivodeships and services
        voivodeships = [row.id for row in conn.execute(text("SELECT id FROM voivodeships")).fetchall()]
        services = [dict(row._mapping) for row in conn.execute(text("SELECT id, is_group, default_duration FROM services")).fetchall()]
        
        if not voivodeships or not services:
            print("Error! Data reference (voivodeships or services) is missing. Please run the reset.sql script first to populate these tables.")
            return

        # generating cities (~50 cities)
        print("City generation...")
        cities_data = [{"name": fake.city(), "voivodeship_id": random.choice(voivodeships)} for _ in range(50)]
        conn.execute(text("INSERT INTO cities (name, voivodeship_id) VALUES (:name, :voivodeship_id)"), cities_data)
        city_ids = [row.id for row in conn.execute(text("SELECT id FROM cities")).fetchall()]

        # generating gyms (~100 gyms)
        print("Gyms generation...")
        gyms_data = [{
            "name": f"Fit Gym {fake.company()}",
            "city_id": random.choice(city_ids),
            "street_address": fake.street_address()
        } for _ in range(NUM_GYMS)]
        conn.execute(text("INSERT INTO gyms (name, city_id, street_address) VALUES (:name, :city_id, :street_address)"), gyms_data)
        gym_ids = [row.id for row in conn.execute(text("SELECT id FROM gyms")).fetchall()]

        # generating trainers (~300 trainers)
        print("Trainers generation...")
        trainers_data = [{
            "full_name": fake.name(),
            "email": fake.unique.email(),
            "password_hash": "hashed_password_123",
            "phone": fake.phone_number()
        } for _ in range(NUM_TRAINERS)]
        conn.execute(text("INSERT INTO trainers (full_name, email, password_hash, phone) VALUES (:full_name, :email, :password_hash, :phone)"), trainers_data)
        trainer_ids = [row.id for row in conn.execute(text("SELECT id FROM trainers")).fetchall()]

        # connecting trainers with gyms and services
        print("Working on trainer-gym and trainer-service relationships...")
        trainer_gyms_data = []
        trainer_services_data = []
        
        for t_id in trainer_ids:
            # trainer works in 1 to 3 gyms
            assigned_gyms = random.sample(gym_ids, random.randint(1, 3))
            for g_id in assigned_gyms:
                trainer_gyms_data.append({"t_id": t_id, "g_id": g_id})
                
            # trainer offers 1 to 3 services
            assigned_services = random.sample([s['id'] for s in services], random.randint(1, 3))
            for s_id in assigned_services:
                trainer_services_data.append({"t_id": t_id, "s_id": s_id})

        # ignore duplicates just in case, since we might have trainers working in the same gym or offering the same service
        conn.execute(text("INSERT IGNORE INTO trainer_gyms (trainer_id, gym_id) VALUES (:t_id, :g_id)"), trainer_gyms_data)
        conn.execute(text("INSERT IGNORE INTO trainer_services (trainer_id, service_id) VALUES (:t_id, :s_id)"), trainer_services_data)

        # 6. Generowanie 100 000 Slotów!
        print(f"Generating {NUM_SLOTS} slots...")
        slots_data = []
        
        # generating slots for the next 6 months, starting from April 15, 2026, 8:00 AM
        start_date = datetime(2026, 4, 15, 8, 0, 0) 

        for i in range(NUM_SLOTS):
            t_id = random.choice(trainer_ids)
            g_id = random.choice(gym_ids)
            service = random.choice(services)
            
            # randomly generate a slot start time within the next 6 months, with some randomness in hours to avoid all slots starting at the same time
            random_days = random.randint(0, 180)
            random_hours = random.randint(0, 12)
            slot_start = start_date + timedelta(days=random_days, hours=random_hours)
            slot_end = slot_start + timedelta(minutes=service['default_duration'])
            
            # one or fifteen clients can book the slot, depending on whether it's a group class or not
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

            # batch insert every 5000 slots
            if len(slots_data) >= 5000:
                conn.execute(text("""
                    INSERT INTO slots (trainer_id, gym_id, service_id, start_time, end_time, capacity, is_group_class) 
                    VALUES (:trainer_id, :gym_id, :service_id, :start_time, :end_time, :capacity, :is_group_class)
                """), slots_data)
                slots_data = [] # Czyścimy paczkę
                print(f"   ... generated {i+1} / {NUM_SLOTS}")

        # insert remaining slots if any
        if slots_data:
            conn.execute(text("""
                INSERT INTO slots (trainer_id, gym_id, service_id, start_time, end_time, capacity, is_group_class) 
                VALUES (:trainer_id, :gym_id, :service_id, :start_time, :end_time, :capacity, :is_group_class)
            """), slots_data)

    print("✅ Ready! Massive data generation completed.")

if __name__ == "__main__":
    generate_massive_data()