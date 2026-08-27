# Senvo PPG Scanner - API Documentation

## Backend Overview

The Senvo backend is a Flask REST API that provides cloud processing and data management services for the PPG scanner mobile app.

## Base URL

```
http://localhost:5000  (Development)
https://senvo-api.herokuapp.com  (Production)
```

## Endpoints

### Health Check

**GET** `/health`

Check if the API server is running.

**Response (200)**
```json
{
  "status": "healthy",
  "timestamp": "2026-08-27T10:00:00Z"
}
```

### User Authentication

**POST** `/api/auth/register`

Register a new user.

**Request**
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "name": "User Name"
}
```

**Response (201)**
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "name": "User Name",
  "created_at": "2026-08-27T10:00:00Z"
}
```

---

**POST** `/api/auth/login`

Authenticate user and get JWT token.

**Request**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response (200)**
```json
{
  "access_token": "jwt_token_here",
  "user_id": "user_123",
  "expires_in": 3600
}
```

### Vitals Data

**POST** `/api/vitals/record`

Save a PPG scan result.

**Headers**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request**
```json
{
  "heart_rate": 72,
  "spo2": 98.5,
  "blood_pressure": {
    "systolic": 120,
    "diastolic": 80
  },
  "signal_quality": 0.85,
  "timestamp": "2026-08-27T10:00:00Z",
  "device_info": {
    "model": "Samsung Galaxy A10",
    "os_version": "11"
  }
}
```

**Response (201)**
```json
{
  "id": "vitals_456",
  "user_id": "user_123",
  "heart_rate": 72,
  "spo2": 98.5,
  "blood_pressure": {
    "systolic": 120,
    "diastolic": 80
  },
  "signal_quality": 0.85,
  "created_at": "2026-08-27T10:00:00Z"
}
```

---

**GET** `/api/vitals/history`

Retrieve user's vitals history.

**Headers**
```
Authorization: Bearer <access_token>
```

**Query Parameters**
```
?limit=50&offset=0&start_date=2026-08-01&end_date=2026-08-31
```

**Response (200)**
```json
{
  "data": [
    {
      "id": "vitals_456",
      "heart_rate": 72,
      "spo2": 98.5,
      "blood_pressure": { "systolic": 120, "diastolic": 80 },
      "signal_quality": 0.85,
      "created_at": "2026-08-27T10:00:00Z"
    }
  ],
  "total": 156,
  "limit": 50,
  "offset": 0
}
```

---

**GET** `/api/vitals/{vitals_id}`

Get a specific vitals record.

**Headers**
```
Authorization: Bearer <access_token>
```

**Response (200)**
```json
{
  "id": "vitals_456",
  "user_id": "user_123",
  "heart_rate": 72,
  "spo2": 98.5,
  "blood_pressure": { "systolic": 120, "diastolic": 80 },
  "signal_quality": 0.85,
  "created_at": "2026-08-27T10:00:00Z"
}
```

### Analytics

**GET** `/api/analytics/summary`

Get user's health summary and trends.

**Headers**
```
Authorization: Bearer <access_token>
```

**Query Parameters**
```
?period=week  (day, week, month, year)
```

**Response (200)**
```json
{
  "period": "week",
  "average_heart_rate": 72,
  "min_heart_rate": 65,
  "max_heart_rate": 85,
  "average_spo2": 98.2,
  "total_scans": 7,
  "trend": "stable"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request",
  "message": "Missing required field: heart_rate",
  "code": "INVALID_REQUEST"
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized",
  "message": "Missing or invalid authorization token",
  "code": "UNAUTHORIZED"
}
```

### 404 Not Found
```json
{
  "error": "Not found",
  "message": "Vitals record not found",
  "code": "NOT_FOUND"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "message": "An unexpected error occurred",
  "code": "INTERNAL_ERROR"
}
```

## Authentication

All endpoints (except `/health`, `/api/auth/register`, `/api/auth/login`) require JWT token in Authorization header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Rate Limiting

- **Standard**: 1000 requests per hour
- **Premium**: 10000 requests per hour

Rate limit headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1630070400
```

## Webhooks

Subscribe to events via webhooks:

**POST** `/api/webhooks/subscribe`

```json
{
  "event_type": "vitals.recorded",
  "url": "https://yourapp.com/webhook/vitals"
}
```

Events:
- `vitals.recorded`: New vitals data added
- `vitals.anomaly`: Unusual reading detected
- `user.signup`: New user registered

## SDK Examples

### Flutter/Dart

```dart
final client = HttpClient();
final request = client.postUrl(Uri.parse('https://api.senvo.com/api/vitals/record'));

request.headers.set('Authorization', 'Bearer $token');
request.headers.set('Content-Type', 'application/json');

request.write(jsonEncode({
  'heart_rate': 72,
  'spo2': 98.5,
  'signal_quality': 0.85,
}));

final response = await request.close();
```

### Python

```python
import requests

headers = {'Authorization': f'Bearer {token}'}
data = {
    'heart_rate': 72,
    'spo2': 98.5,
    'signal_quality': 0.85,
}

response = requests.post(
    'https://api.senvo.com/api/vitals/record',
    json=data,
    headers=headers
)
```

## Versioning

Current API version: `v1`

Future versions will be available at:
- `/api/v2/...`
- `/api/v3/...`

Legacy versions remain supported with deprecation notices.
