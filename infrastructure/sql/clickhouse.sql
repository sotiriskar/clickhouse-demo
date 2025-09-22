-- ===========================================
-- CLICKHOUSE LAYERED DATA ARCHITECTURE
-- ===========================================

-- Databases
CREATE DATABASE IF NOT EXISTS materialized_views;
CREATE DATABASE IF NOT EXISTS analytics;
CREATE DATABASE IF NOT EXISTS reporting;
CREATE DATABASE IF NOT EXISTS streams;
CREATE DATABASE IF NOT EXISTS kafka;

-- ===========================================
-- KAFKA TABLES (CDC Integration)
-- ===========================================

CREATE TABLE IF NOT EXISTS kafka.kafka_transactions_raw
(
    msg String
)
ENGINE = Kafka('broker-kafka:29092', 'financial.public.raw_transactions', 'ch_group_transactions', 'JSONAsString')
SETTINGS kafka_thread_per_consumer = 0, kafka_num_consumers = 1;

CREATE TABLE IF NOT EXISTS kafka.kafka_accounts_raw
(
    msg String
)
ENGINE = Kafka('broker-kafka:29092', 'financial.public.raw_accounts', 'ch_group_accounts', 'JSONAsString')
SETTINGS kafka_thread_per_consumer = 0, kafka_num_consumers = 1;

CREATE TABLE IF NOT EXISTS kafka.kafka_merchants_raw
(
    msg String
)
ENGINE = Kafka('broker-kafka:29092', 'financial.public.raw_merchants', 'ch_group_merchants', 'JSONAsString')
SETTINGS kafka_thread_per_consumer = 0, kafka_num_consumers = 1;

CREATE TABLE IF NOT EXISTS kafka.kafka_fx_rates_raw
(
    msg String
)
ENGINE = Kafka('broker-kafka:29092', 'financial.public.raw_fx_rates', 'ch_group_fx_rates', 'JSONAsString')
SETTINGS kafka_thread_per_consumer = 0, kafka_num_consumers = 1;

CREATE TABLE IF NOT EXISTS kafka.kafka_ip_geo_raw
(
    msg String
)
ENGINE = Kafka('broker-kafka:29092', 'financial.public.raw_ip_geo', 'ch_group_ip_geo', 'JSONAsString')
SETTINGS kafka_thread_per_consumer = 0, kafka_num_consumers = 1;

-- ===========================================
-- RAW DATA LAYER (Bronze)
-- ===========================================

CREATE TABLE IF NOT EXISTS streams.transactions_raw
(
    transaction_id String,
    account_id String,
    timestamp DateTime,
    amount String,
    currency String,
    merchant_id String,
    status String,
    ip String,
    device_id String,
    version UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY (account_id, timestamp)
PARTITION BY toYYYYMM(timestamp);

CREATE TABLE IF NOT EXISTS streams.accounts_raw
(
    account_id String,
    user_name String,
    email String,
    country String,
    signup_date DateTime,
    version UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY account_id;

CREATE TABLE IF NOT EXISTS streams.merchants_raw
(
    merchant_id String,
    merchant_name String,
    merchant_category String,
    country String,
    risk_rating UInt8,
    version UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY merchant_id;

CREATE TABLE IF NOT EXISTS streams.fx_rates_raw
(
    date Date,
    currency String,
    rate_to_eur String,
    version UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY (date, currency)
PARTITION BY toYYYYMM(date);

CREATE TABLE IF NOT EXISTS streams.ip_geo_raw
(
    ip String,
    country String,
    city String,
    is_proxy_or_vpn UInt8,
    version UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY ip;

-- ===========================================
-- MATERIALIZED VIEWS: Bronze ingestion from Kafka
-- ===========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_transactions_raw
TO streams.transactions_raw AS
SELECT
    JSONExtract(msg, 'payload', 'after', 'transaction_id', 'String') AS transaction_id,
    JSONExtract(msg, 'payload', 'after', 'account_id', 'String') AS account_id,
    toDateTime(JSONExtract(msg, 'payload', 'after', 'timestamp', 'UInt64') / 1000000) AS timestamp,
    JSONExtract(msg, 'payload', 'after', 'amount', 'String') AS amount,
    JSONExtract(msg, 'payload', 'after', 'currency', 'String') AS currency,
    JSONExtract(msg, 'payload', 'after', 'merchant_id', 'String') AS merchant_id,
    JSONExtract(msg, 'payload', 'after', 'status', 'String') AS status,
    JSONExtract(msg, 'payload', 'after', 'ip', 'String') AS ip,
    JSONExtract(msg, 'payload', 'after', 'device_id', 'String') AS device_id,
    JSONExtract(msg, 'payload', 'source', 'ts_ms', 'UInt64') AS version
FROM kafka.kafka_transactions_raw
WHERE JSONExtract(msg, 'payload', 'op', 'String') IN ('c','r','u') AND length(msg) > 0;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_accounts_raw
TO streams.accounts_raw AS
SELECT
    JSONExtract(msg, 'payload', 'after', 'account_id', 'String') AS account_id,
    JSONExtract(msg, 'payload', 'after', 'user_name', 'String') AS user_name,
    JSONExtract(msg, 'payload', 'after', 'email', 'String') AS email,
    JSONExtract(msg, 'payload', 'after', 'country', 'String') AS country,
    toDateTime(JSONExtract(msg, 'payload', 'after', 'signup_date', 'UInt64') / 1000000) AS signup_date,
    JSONExtract(msg, 'payload', 'source', 'ts_ms', 'UInt64') AS version
FROM kafka.kafka_accounts_raw
WHERE JSONExtract(msg, 'payload', 'op', 'String') IN ('c','r','u') AND length(msg) > 0;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_merchants_raw
TO streams.merchants_raw AS
SELECT
    JSONExtract(msg, 'payload', 'after', 'merchant_id', 'String') AS merchant_id,
    JSONExtract(msg, 'payload', 'after', 'merchant_name', 'String') AS merchant_name,
    JSONExtract(msg, 'payload', 'after', 'merchant_category', 'String') AS merchant_category,
    JSONExtract(msg, 'payload', 'after', 'country', 'String') AS country,
    JSONExtract(msg, 'payload', 'after', 'risk_rating', 'UInt8') AS risk_rating,
    JSONExtract(msg, 'payload', 'source', 'ts_ms', 'UInt64') AS version
FROM kafka.kafka_merchants_raw
WHERE JSONExtract(msg, 'payload', 'op', 'String') IN ('c','r','u') AND length(msg) > 0;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_fx_rates_raw
TO streams.fx_rates_raw AS
SELECT
    toDate(JSONExtract(msg, 'payload', 'after', 'date', 'Int32')) AS date,
    JSONExtract(msg, 'payload', 'after', 'currency', 'String') AS currency,
    JSONExtract(msg, 'payload', 'after', 'rate_to_eur', 'String') AS rate_to_eur,
    JSONExtract(msg, 'payload', 'source', 'ts_ms', 'UInt64') AS version
FROM kafka.kafka_fx_rates_raw
WHERE JSONExtract(msg, 'payload', 'op', 'String') IN ('c','r','u') AND length(msg) > 0;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_ip_geo_raw
TO streams.ip_geo_raw AS
SELECT
    JSONExtract(msg, 'payload', 'after', 'ip', 'String') AS ip,
    JSONExtract(msg, 'payload', 'after', 'country', 'String') AS country,
    JSONExtract(msg, 'payload', 'after', 'city', 'String') AS city,
    JSONExtract(msg, 'payload', 'after', 'is_proxy_or_vpn', 'UInt8') AS is_proxy_or_vpn,
    JSONExtract(msg, 'payload', 'source', 'ts_ms', 'UInt64') AS version
FROM kafka.kafka_ip_geo_raw
WHERE JSONExtract(msg, 'payload', 'op', 'String') IN ('c','r','u') AND length(msg) > 0;

-- ===========================================
-- SILVER LAYER (Analytics)
-- ===========================================

CREATE TABLE IF NOT EXISTS analytics.transactions
(
    transaction_id String,
    account_id String,
    timestamp DateTime,
    date Date,
    amount_eur Decimal(12,2),
    currency_original String,
    merchant_id String,
    account_country String,
    ip_country String,
    ip_city String,
    device_id String,
    status String
)
ENGINE = MergeTree()
ORDER BY (account_id, timestamp)
PARTITION BY toYYYYMM(timestamp);

CREATE TABLE IF NOT EXISTS analytics.accounts
(
    account_id String,
    user_name String,
    email_normalized String,
    signup_date DateTime,
    account_age_days Int32,
    country_normalized String
)
ENGINE = MergeTree()
ORDER BY account_id;

CREATE TABLE IF NOT EXISTS analytics.merchants
(
    merchant_id String,
    merchant_name String,
    merchant_category String,
    merchant_country String,
    risk_rating UInt8
)
ENGINE = MergeTree()
ORDER BY merchant_id;

-- ===========================================
-- SILVER MATERIALIZED VIEWS
-- ===========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_transactions_silver
TO analytics.transactions AS
SELECT
    t.transaction_id AS transaction_id,
    t.account_id AS account_id,
    t.timestamp AS timestamp,
    toDate(t.timestamp) AS date,
    CASE 
        WHEN length(t.amount) <= 10 AND t.amount REGEXP '^[0-9]+\.?[0-9]*$' 
        THEN toDecimal64(t.amount, 2) * CASE 
            WHEN t.currency = 'EUR' THEN 1.0
            WHEN t.currency = 'USD' THEN 0.85
            WHEN t.currency = 'GBP' THEN 1.15
            ELSE 1.0
        END
        ELSE toDecimal64('100.00', 2) * CASE 
            WHEN t.currency = 'EUR' THEN 1.0
            WHEN t.currency = 'USD' THEN 0.85
            WHEN t.currency = 'GBP' THEN 1.15
            ELSE 1.0
        END
    END AS amount_eur,
    t.currency AS currency_original,
    t.merchant_id AS merchant_id,
    a.country AS account_country,
    ip.country AS ip_country,
    ip.city AS ip_city,
    t.device_id AS device_id,
    t.status AS status
FROM streams.transactions_raw AS t
LEFT JOIN streams.accounts_raw AS a ON t.account_id = a.account_id
LEFT JOIN streams.ip_geo_raw AS ip ON t.ip = ip.ip;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_accounts_silver
TO analytics.accounts AS
SELECT
    account_id,
    user_name,
    lower(email) AS email_normalized,
    signup_date,
    dateDiff('day', signup_date, now()) AS account_age_days,
    country AS country_normalized
FROM streams.accounts_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_merchants_silver
TO analytics.merchants AS
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    country AS merchant_country,
    risk_rating
FROM streams.merchants_raw;

-- ===========================================
-- GOLD LAYER (Reporting)
-- ===========================================

CREATE TABLE IF NOT EXISTS reporting.daily_kpis
(
    date Date,
    num_transactions UInt64,
    total_volume_eur Decimal(12,2),
    avg_transaction_value Decimal(12,2),
    active_accounts UInt64
)
ENGINE = SummingMergeTree()
ORDER BY date
PARTITION BY toYYYYMM(date);

CREATE TABLE IF NOT EXISTS reporting.merchant_metrics
(
    merchant_id String,
    merchant_name String,
    date Date,
    transactions UInt64,
    revenue_eur Decimal(12,2),
    unique_customers UInt64
)
ENGINE = SummingMergeTree()
ORDER BY (merchant_id, date)
PARTITION BY toYYYYMM(date);

CREATE TABLE IF NOT EXISTS reporting.fraud_features
(
    account_id String,
    date Date,
    num_txn UInt64,
    daily_volume Decimal(12,2),
    max_txn Decimal(12,2),
    num_countries_used UInt64,
    num_devices_used UInt64,
    country_mismatch_count UInt64,
    high_value_txn_count UInt64
)
ENGINE = AggregatingMergeTree()
ORDER BY (account_id, date)
PARTITION BY toYYYYMM(date);

-- ===========================================
-- GOLD MATERIALIZED VIEWS
-- ===========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_daily_kpis
TO reporting.daily_kpis AS
SELECT
    date,
    count() AS num_transactions,
    sum(amount_eur) AS total_volume_eur,
    avg(amount_eur) AS avg_transaction_value,
    uniqExact(account_id) AS active_accounts
FROM analytics.transactions
GROUP BY date;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_merchant_metrics
TO reporting.merchant_metrics AS
SELECT
    m.merchant_id AS merchant_id,
    m.merchant_name AS merchant_name,
    t.date AS date,
    count() AS transactions,
    sum(t.amount_eur) AS revenue_eur,
    uniqExact(t.account_id) AS unique_customers
FROM analytics.transactions AS t
JOIN analytics.merchants AS m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name, t.date;

CREATE MATERIALIZED VIEW IF NOT EXISTS materialized_views.mv_fraud_features
TO reporting.fraud_features AS
SELECT
    account_id,
    date,
    count() AS num_txn,
    sum(amount_eur) AS daily_volume,
    max(amount_eur) AS max_txn,
    uniqExact(ip_country) AS num_countries_used,
    uniqExact(device_id) AS num_devices_used,
    sumIf(1, account_country != ip_country) AS country_mismatch_count,
    sumIf(1, amount_eur > 1000) AS high_value_txn_count
FROM analytics.transactions
GROUP BY account_id, date;
