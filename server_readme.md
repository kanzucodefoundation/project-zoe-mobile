# Project Zoe Mock API Server

Mock API server for Project Zoe mobile app development. Implements the full API contract with realistic data across 4 countries and 6-level church hierarchy.

## Quick Start

```bash
# Install dependencies
npm install

# Start server
npm start

# Server runs at http://localhost:3001
```

## Test Accounts

All accounts use password: `password123`

| Email | Role | Access Level |
|-------|------|-------------|
| `fellowship@worshipharvest.org` | MC Shepherd | Single fellowship (Phase MC) |
| `zone@worshipharvest.org` | Zone Leader | North Zone + 5 fellowships |
| `location@worshipharvest.org` | Location Pastor | Kampala Location + 4 zones + 20 fellowships |
| `fob@worshipharvest.org` | FOB Leader | East Africa + 3 locations |
| `network@worshipharvest.org` | Network Leader | Africa Network + 2 FOBs |
| `movement@worshipharvest.org` | Movement Leader | Global (all regions) |
| `admin@worshipharvest.org` | System Admin | Full system access |

## Data Overview

### Hierarchy Structure
```
Movement: Worship Harvest Global
├─ Network: Africa Network
│  ├─ FOB: East Africa
│  │  ├─ Location: Kampala, Uganda (4 zones, 20 fellowships, ~135 members)
│  │  ├─ Location: Kigali, Rwanda (2 zones, 8 fellowships, ~20 members)
│  │  └─ Location: Nairobi, Kenya (3 zones, 12 fellowships, ~30 members)
└─ Network: Europe Network
   └─ FOB: Western Europe
      └─ Location: Berlin, Germany (2 zones, 6 fellowships, ~12 members)
```

### Reports Available
1. **MC Attendance Report** (Weekly) - 12 fields
2. **Sunday Service Report** (Weekly) - 8 fields
3. **Baptism Report** (Event-based) - 6 fields
4. **Salvation Report** (Event-based) - 5 fields

### Historical Data
- **MC Reports**: 8 weeks of history (80% submission rate)
- **Service Reports**: 8 weeks of history (90% submission rate)
- **Baptism/Salvation**: Sporadic events
- Some fellowships are overdue (for testing "overdue" UI)

## API Endpoints

Base URL: `http://localhost:3001/api`

### Authentication
```bash
POST /auth/login
POST /auth/refresh
POST /auth/logout
GET  /auth/me
```

### Groups & Hierarchy
```bash
GET  /groups/me
GET  /groups/:id
GET  /groups/:id/members
GET  /groups/categories
```

### Contacts (CRM)
```bash
GET   /crm/contacts
GET   /crm/contacts/:id
POST  /crm/contacts
PATCH /crm/contacts/:id
```

### Reports
```bash
GET  /reports
GET  /reports/:id
POST /reports/:reportId/submissions
GET  /reports/submissions/me
GET  /reports/submissions/team
GET  /reports/submissions/:id
```

### Dashboard
```bash
GET /dashboard/summary
```

### Users
```bash
GET /users
```

### Search
```bash
GET /search?q={query}&type={contacts|groups|all}
```

## Example Usage

### 1. Login
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "churchName": "worship harvest",
    "username": "fellowship@worshipharvest.org",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "token": "mock_jwt_...",
  "user": {
    "id": 151,
    "fullName": "Emmanuel Okello",
    "roles": ["MC Shepherd"],
    "permissions": ["REPORT_VIEW", "REPORT_SUBMIT", "CRM_VIEW"]
  },
  "hierarchy": {
    "myGroups": [
      {
        "id": 100,
        "name": "Phase MC",
        "type": "fellowship",
        "memberCount": 8
      }
    ]
  }
}
```

### 2. Get My Groups
```bash
curl http://localhost:3001/api/groups/me
```

### 3. Get Fellowship Members
```bash
curl http://localhost:3001/api/groups/100/members
```

### 4. Submit Report
```bash
curl -X POST http://localhost:3001/api/reports/1/submissions \
  -H "Content-Type: application/json" \
  -d '{
    "groupId": 100,
    "data": {
      "date": "2024-12-22",
      "smallGroupName": "Phase MC",
      "smallGroupAttendanceCount": 7,
      "mcHostHome": "Emmanuel Okello",
      "smallGroupNumberOfMembers": 8,
      "mcAttendeeNames": "Emmanuel, Sarah, David, Grace, Joshua, Rebecca, Moses",
      "mcGeneralFeedback": "Great fellowship time"
    }
  }'
```

### 5. Get Dashboard Summary
```bash
curl http://localhost:3001/api/dashboard/summary
```

## Testing Different User Roles

### Fellowship Leader (Phase MC only)
```bash
# Login as fellowship leader
curl -X POST http://localhost:3001/api/auth/login \
  -d '{"username":"fellowship@worshipharvest.org","password":"password123"}' \
  -H "Content-Type: application/json"

# See only Phase MC (1 group, 8 members)
curl http://localhost:3001/api/groups/me
```

### Zone Leader (North Zone Kampala)
```bash
# Login as zone leader
curl -X POST http://localhost:3001/api/auth/login \
  -d '{"username":"zone@worshipharvest.org","password":"password123"}' \
  -H "Content-Type: application/json"

# See 1 zone + 5 fellowships (~32 members)
curl http://localhost:3001/api/groups/me
```

### Location Pastor (All Kampala)
```bash
# Login as location pastor
curl -X POST http://localhost:3001/api/auth/login \
  -d '{"username":"location@worshipharvest.org","password":"password123"}' \
  -H "Content-Type: application/json"

# See 1 location + 4 zones + 20 fellowships (~135 members)
curl http://localhost:3001/api/groups/me
```

### Movement Leader (Global)
```bash
# Login as movement leader
curl -X POST http://localhost:3001/api/auth/login \
  -d '{"username":"movement@worshipharvest.org","password":"password123"}' \
  -H "Content-Type: application/json"

# See entire global hierarchy (500+ members)
curl http://localhost:3001/api/groups/me
```

## Features

✅ **Full 6-level hierarchy** (Movement → Network → FOB → Location → Zone → Fellowship)  
✅ **Multi-country data** (Uganda, Rwanda, Kenya, Germany)  
✅ **Realistic names & addresses** (Ugandan, Rwandan, Kenyan, German)  
✅ **Historical submissions** (8 weeks with realistic gaps)  
✅ **Overdue tracking** (some fellowships haven't submitted)  
✅ **7 role-based test accounts**  
✅ **Stateful** (POST creates data, GET retrieves it)  
✅ **Network delay simulation** (400ms)  
✅ **Pagination support**  
✅ **Search functionality**  

## Mobile Dev Workflow

1. **Start the server**: `npm start`
2. **Point mobile app to**: `http://localhost:3001/api`
3. **Login with test account**: Use any of the 7 accounts
4. **Build features**: All endpoints work with realistic data
5. **Test scenarios**:
   - Submit reports → persists in mock DB
   - View team reports → see overdue/submitted status
   - Search members → real filtering
   - Test different roles → see different hierarchy levels

## Network Configuration

For mobile testing on physical device:

```bash
# Find your computer's local IP
ipconfig getifaddr en0  # macOS
ip addr show           # Linux
ipconfig              # Windows

# Update mobile app base URL to:
http://192.168.1.XXX:3001/api
```

## Deployment to Render

1. Push to GitHub:
```bash
git init
git add .
git commit -m "Initial mock API"
git remote add origin <your-repo>
git push -u origin main
```

2. Create `Procfile`:
```
web: node server.js
```

3. Deploy on [Render.com](https://render.com):
   - Connect GitHub repo
   - Select "Node"
   - Deploy
   - Get public URL: `https://project-zoe-mock.onrender.com/api`

