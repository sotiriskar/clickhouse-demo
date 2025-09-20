from psycopg2.extras import execute_values
from datetime import datetime, timedelta
from faker import Faker
import psycopg2
import random
import time


# ----------------- CONFIG -----------------
CONFIG = {
    "postgres": {
        "host": "localhost",
        "port": 5432,
        "dbname": "financial",
        "user": "postgres",
        "password": "postgres"
    },
    "push_interval_sec": 24,
    "rows_per_batch": 123456,
    "num_accounts_pool": 12345,
    "num_merchants_pool": 56,
    "num_ip_pool": 5678
}
# -----------------------------------------

fake = Faker()

# ----------------- POOLS -----------------
# Merchants pool
MERCHANTS_POOL = [
    {
        "merchant_id": fake.uuid4(),
        "merchant_name": fake.company()[:100],
        "merchant_category": random.choice(["Retail", "Food", "Travel", "Electronics"]),
        "country": fake.country()[:100],
        "risk_rating": random.randint(1,5)
    }
    for _ in range(CONFIG["num_merchants_pool"])
]

# Accounts pool
ACCOUNTS_POOL = [
    (
        fake.uuid4(),
        fake.name()[:100],
        fake.email()[:255],
        fake.country()[:100],
        fake.date_time_between(start_date="-2y", end_date="now")
    )
    for _ in range(CONFIG["num_accounts_pool"])
]

# IP pool
IP_POOL = [(fake.ipv4_public(), fake.country()[:100], fake.city()[:100], random.choice([True, False])) 
           for _ in range(CONFIG["num_ip_pool"])]

# FX rates pool
def generate_fx_rates():
    currencies = ["EUR", "USD", "GBP"]
    rows = []
    today = datetime.now().date()
    for i in range(365):
        d = today - timedelta(days=i)
        for c in currencies:
            rate = round(random.uniform(0.7, 1.3), 6)
            rows.append((d, c, rate))
    return rows

# ----------------- GENERATORS -----------------
def generate_transactions(n):
    transactions = []
    currencies = ["EUR", "USD", "GBP"]
    for _ in range(n):
        transaction_id = fake.uuid4()
        account_id, *_ = random.choice(ACCOUNTS_POOL)
        timestamp = fake.date_time_between(start_date="-1d", end_date="now")
        amount = round(random.uniform(1.0, 5000.0), 2)
        currency = random.choice(currencies)
        merchant = random.choice(MERCHANTS_POOL)["merchant_id"]
        status = random.choices(["success", "failed", "pending"], weights=[0.90,0.05,0.05])[0]
        ip, ip_country, ip_city, is_proxy = random.choice(IP_POOL)
        device_id = fake.uuid4()
        transactions.append((
            transaction_id, account_id, timestamp, amount, currency,
            merchant, status, ip, device_id
        ))
    return transactions

# ----------------- PUSH FUNCTION -----------------
def push_to_postgres(conn, table, rows):
    if not rows:
        return
    insert_query = f"INSERT INTO {table} VALUES %s ON CONFLICT DO NOTHING"
    with conn.cursor() as cur:
        execute_values(cur, insert_query, rows)
    conn.commit()
    print(f"Pushed {len(rows)} rows to {table} at {datetime.now()}")

# ----------------- MAIN LOOP -----------------
def main():
    conn = psycopg2.connect(**CONFIG["postgres"])
    
    # Push fixed tables once
    push_to_postgres(conn, "raw_merchants", [(m["merchant_id"], m["merchant_name"], m["merchant_category"], m["country"], m["risk_rating"]) for m in MERCHANTS_POOL])
    push_to_postgres(conn, "raw_accounts", ACCOUNTS_POOL)
    push_to_postgres(conn, "raw_ip_geo", IP_POOL)
    push_to_postgres(conn, "raw_fx_rates", generate_fx_rates())

    while True:
        start_time = time.time()
        
        # Generate transactions sampling from pools
        transactions_rows = generate_transactions(CONFIG["rows_per_batch"])
        push_to_postgres(conn, "raw_transactions", transactions_rows)

        elapsed = time.time() - start_time
        sleep_time = max(0, CONFIG["push_interval_sec"] - elapsed)
        time.sleep(sleep_time)


if __name__ == "__main__":
    main()
