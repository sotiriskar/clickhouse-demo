# Financial Data Dashboard

A comprehensive SvelteKit dashboard for analyzing financial data stored in ClickHouse. This dashboard provides three main features:

## Features

### 📊 Gold Layer Dashboard
- **KPIs & Statistics**: Real-time key performance indicators including total transactions, volume, average transaction value, and active accounts
- **Interactive Charts**: Beautiful visualizations using Chart.js showing transaction trends and volume patterns
- **Recent Data Table**: Quick overview of recent daily KPIs

### 🔍 Analytics Dashboard
- **Searchable Tables**: Explore transactions, merchants, and accounts with real-time search
- **Advanced Filtering**: Search across multiple fields with debounced input
- **Pagination**: Efficient data loading with pagination support
- **Status Indicators**: Visual indicators for transaction status and risk ratings

### 💻 SQLPad Query Editor
- **SQL Query Editor**: Execute custom ClickHouse queries with syntax highlighting
- **Query History**: Keep track of recent queries with success/failure indicators
- **Export Features**: Download results as CSV or Excel files
- **Real-time Results**: View query results with execution statistics

## Technology Stack

- **Frontend**: SvelteKit with TypeScript
- **Charts**: Chart.js with date-fns adapter
- **Icons**: Lucide Svelte
- **Styling**: Custom CSS with modern design
- **Backend**: ClickHouse HTTP API

## Getting Started

### Prerequisites

- Node.js 18+ 
- ClickHouse server running on localhost:8123
- Docker Compose setup for the data pipeline

### Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

3. Open your browser to `http://localhost:5173`

### Data Setup

Make sure your ClickHouse server is running with the financial data schema. The dashboard expects the following databases and tables:

- `reporting.daily_kpis` - Daily KPI metrics
- `reporting.merchant_metrics` - Merchant performance data
- `reporting.fraud_features` - Fraud detection features
- `analytics.transactions` - Transaction data
- `analytics.merchants` - Merchant information
- `analytics.accounts` - Account information

## API Endpoints

The dashboard uses internal API routes:

- `GET /api/kpis` - Fetch daily KPIs
- `GET /api/transactions` - Search transactions
- `GET /api/merchants` - Search merchants  
- `GET /api/accounts` - Search accounts
- `POST /api/query` - Execute custom SQL queries

## Usage

### Gold Layer
- View real-time KPIs and trends
- Analyze transaction patterns with interactive charts
- Monitor daily performance metrics

### Analytics
- Switch between different data tables (Transactions, Merchants, Accounts)
- Use the search bar to filter results in real-time
- Navigate through paginated results

### SQLPad
- Write custom ClickHouse SQL queries
- Use Ctrl+Enter to execute queries quickly
- Export results to CSV or Excel format
- View query execution statistics
- Access query history for quick re-execution

## Security Features

- SQL injection protection (only SELECT queries allowed)
- Input validation and sanitization
- Error handling with user-friendly messages

## Responsive Design

The dashboard is fully responsive and works on:
- Desktop computers
- Tablets
- Mobile devices

## Development

### Project Structure

```
src/
├── lib/
│   ├── components/          # Reusable Svelte components
│   ├── clickhouse.ts       # ClickHouse client
│   ├── types.ts           # TypeScript type definitions
│   └── utils.ts           # Utility functions
├── routes/
│   ├── api/               # API endpoints
│   └── +page.svelte       # Main dashboard page
└── app.css               # Global styles
```

### Adding New Features

1. Create new components in `src/lib/components/`
2. Add API routes in `src/routes/api/`
3. Update types in `src/lib/types.ts`
4. Add utility functions in `src/lib/utils.ts`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.