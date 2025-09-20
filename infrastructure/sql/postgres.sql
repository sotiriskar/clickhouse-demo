-- Transactions table
CREATE TABLE raw_transactions (
    transaction_id UUID PRIMARY KEY,
    account_id UUID NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    merchant_id UUID NOT NULL,
    status VARCHAR(20),  -- success, failed, pending
    ip VARCHAR(45),
    device_id VARCHAR(100)
);

-- Accounts table
CREATE TABLE raw_accounts (
    account_id UUID PRIMARY KEY,
    user_name VARCHAR(100),
    email VARCHAR(255),
    country VARCHAR(100),
    signup_date TIMESTAMP DEFAULT now()
);

-- Merchants table
CREATE TABLE raw_merchants (
    merchant_id UUID PRIMARY KEY,
    merchant_name VARCHAR(100),
    merchant_category VARCHAR(100),
    country VARCHAR(100),
    risk_rating INT
);

-- FX rates table
CREATE TABLE raw_fx_rates (
    date DATE NOT NULL,
    currency VARCHAR(10) NOT NULL,
    rate_to_eur NUMERIC(12,6) NOT NULL,
    PRIMARY KEY (date, currency)
);

-- IP geolocation table
CREATE TABLE raw_ip_geo (
    ip VARCHAR(45) PRIMARY KEY,
    country VARCHAR(100),
    city VARCHAR(100),
    is_proxy_or_vpn BOOLEAN DEFAULT FALSE
);
