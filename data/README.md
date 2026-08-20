# Data Directory

This directory contains persistent data for all services.
Each service has its own subdirectory.

## Structure

```
data/
├── grok2api/
│   ├── data/        # SQLite DB (accounts.db) and app data
│   └── logs/        # Application logs
└── grok-register-panel/
    ├── accounts/    # Registered account files (*.txt)
    ├── log/         # Panel logs, proxy_pool.json, batch_traffic.json
    ├── cpa_auth/    # CPA auth JSON files (auto-injected into grok2api)
    └── grok2api_auth/ # grok2api auth JSON files
```

> **Note**: The actual data files are git-ignored.
> Only `.gitkeep` placeholder files are committed.
