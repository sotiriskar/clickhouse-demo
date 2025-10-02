# ClickHouse Financial Data Warehouse Demo

A comprehensive demonstration of a **Bronze/Silver/Gold Architecture** with **Real-Time Analytics** using ClickHouse, PostgreSQL, Kafka, and Debezium for financial data processing.

## 🏗️ Architecture Overview

This demo showcases a modern data warehouse architecture with:

- **Bronze Layer**: Raw data ingestion from PostgreSQL via Debezium CDC
- **Silver Layer**: Data transformation and cleaning in ClickHouse
- **Gold Layer**: Aggregated analytics and KPIs for business intelligence
- **Real-Time Analytics**: Live dashboards with SvelteKit frontend

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Python 3.8+ (for mock data generation)
- Node.js 18+ (for frontend development)

### 1. Start the Infrastructure

```bash
# Navigate to the infrastructure directory
cd infrastructure

# Start all services (PostgreSQL, Kafka, ClickHouse, etc.)
docker-compose up -d

# Wait for all services to be healthy (this may take 2-3 minutes)
docker-compose ps
```

### 2. Generate Mock Data

```bash
# Navigate to utils directory
cd ../utils

# Install Python dependencies
pip install -r requirements.txt

# Run the mock data generator (this will continuously generate financial data)
python mock_data.py
```

**Note**: The mock data generator will:
- Create merchants, accounts, and IP geolocation data
- Continuously generate transaction data every 24 seconds
- Insert ~123K transactions per batch
- Run indefinitely until stopped (Ctrl+C)

### 3. Access the Applications

Once everything is running, you can access:

- **Frontend Dashboard**: http://localhost:5173
- **ClickHouse Web UI**: http://localhost:8123
- **Kafka Control Center**: http://localhost:9021
- **Debezium UI**: http://localhost:8080
- **PostgreSQL**: localhost:5432 (user: postgres, password: postgres)

## 🛠️ Development Setup

### Frontend Development

To run the frontend in development mode:

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The frontend will be available at http://localhost:5173 with hot reloading enabled.

### Manual Infrastructure Management

#### Start Individual Services

```bash
# Start only ClickHouse
docker-compose up -d clickhouse-server

# Start only PostgreSQL
docker-compose up -d postgres

# Start Kafka stack
docker-compose up -d zookeeper-kafka broker-kafka schema-registry
```

#### View Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f clickhouse-server
docker-compose logs -f postgres
docker-compose logs -f broker-kafka
```

#### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ This will delete all data)
docker-compose down -v
```

## 📊 Data Flow

1. **Data Generation**: `mock_data.py` generates realistic financial data
2. **Bronze Layer**: PostgreSQL stores raw transaction data
3. **CDC**: Debezium captures changes and streams to Kafka
4. **Silver Layer**: ClickHouse processes and transforms the data
5. **Gold Layer**: Aggregated analytics and KPIs
6. **Frontend**: Real-time dashboard displays insights

## 🔧 Configuration

### Mock Data Configuration

Edit `utils/mock_data.py` to modify:
- `push_interval_sec`: Time between data batches (default: 24 seconds)
- `rows_per_batch`: Number of transactions per batch (default: 123,456)
- `num_accounts_pool`: Number of accounts to simulate (default: 12,345)
- `num_merchants_pool`: Number of merchants (default: 56)

### Database Connections

- **PostgreSQL**: localhost:5432 (financial database)
- **ClickHouse**: localhost:8123 (HTTP), localhost:9000 (Native)

## 🐛 Troubleshooting

### Common Issues

1. **Services not starting**: Wait 2-3 minutes for all services to initialize
2. **Port conflicts**: Ensure ports 5432, 8123, 9092, 8080, 8083, 8084, 8085, 8087, 9021 are available
3. **Mock data not generating**: Check PostgreSQL connection and ensure the database is running
4. **Frontend not loading**: Verify ClickHouse is healthy and accessible

### Health Checks

```bash
# Check service health
docker-compose ps

# Test ClickHouse connection
curl http://localhost:8123/ping

# Test PostgreSQL connection
docker exec -it postgres pg_isready -U postgres -d financial
```

### Reset Everything

```bash
# Stop and remove all containers and volumes
docker-compose down -v

# Remove any orphaned containers
docker system prune -f

# Start fresh
docker-compose up -d
```

## 📁 Project Structure

```
clickhouse-demo/
├── frontend/                 # SvelteKit frontend application
│   ├── src/
│   │   ├── lib/components/  # Reusable UI components
│   │   └── routes/api/      # API endpoints
│   └── package.json
├── infrastructure/           # Docker Compose configuration
│   ├── docker-compose.yml   # All services definition
│   └── sql/                 # Database initialization scripts
├── utils/                   # Data generation utilities
│   ├── mock_data.py         # Mock data generator
│   └── requirements.txt     # Python dependencies
└── README.md
```

## 🎯 Features Demonstrated

- **Real-time Data Pipeline**: CDC with Debezium and Kafka
- **Data Warehouse Architecture**: Bronze/Silver/Gold layers
- **Analytics Dashboard**: Interactive charts and KPIs
- **Scalable Infrastructure**: Docker containerization
- **Modern Frontend**: SvelteKit with TypeScript
- **Data Visualization**: Chart.js integration

## 📈 Performance Notes

- Mock data generator creates ~123K transactions every 24 seconds
- ClickHouse handles millions of rows efficiently
- Frontend updates in real-time as new data arrives
- All services are optimized for development/demo purposes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request
