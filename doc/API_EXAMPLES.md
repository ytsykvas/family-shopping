# API Usage Examples

This document provides practical examples of using the authentication API for React Native or other API clients.

## Base URL

- Development: `http://localhost:3000`
- Production: `https://your-domain.com`

## Authentication Flow

### 1. User Registration

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "John Doe"
    }
  }'
```

Response:
```json
{
  "status": {
    "code": 200,
    "message": "Signed up successfully."
  },
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2024-12-10T22:30:00.000Z"
  }
}
```

**Important:** Save the `Authorization` header from the response:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjM5MTY0NjAwLCJleHAiOjE2MzkyNTEwMDAsImp0aSI6ImFiY2QxMjM0In0.xxxxx
```

### 2. User Login

```bash
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password123"
    }
  }'
```

Response includes JWT token in header and body similar to registration.

### 3. Making Authenticated Requests

Use the JWT token in the `Authorization` header:

```bash
curl -X GET http://localhost:3000/api/v1/posts \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

### 4. User Logout

```bash
curl -X DELETE http://localhost:3000/users/sign_out \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

Response:
```json
{
  "status": 200,
  "message": "Logged out successfully."
}
```

This revokes the token by adding it to the denylist.

## React Native Example

### Setup Axios

```javascript
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_URL = 'http://localhost:3000';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests automatically
api.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle 401 responses
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await AsyncStorage.removeItem('authToken');
      // Navigate to login screen
    }
    return Promise.reject(error);
  }
);

export default api;
```

### Authentication Service

```javascript
import api from './api';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const authService = {
  async register(email, password, name) {
    const response = await api.post('/users', {
      user: {
        email,
        password,
        password_confirmation: password,
        name,
      },
    });
    
    const token = response.headers.authorization.replace('Bearer ', '');
    await AsyncStorage.setItem('authToken', token);
    
    return response.data;
  },

  async login(email, password) {
    const response = await api.post('/users/sign_in', {
      user: { email, password },
    });
    
    const token = response.headers.authorization.replace('Bearer ', '');
    await AsyncStorage.setItem('authToken', token);
    
    return response.data;
  },

  async logout() {
    try {
      await api.delete('/users/sign_out');
    } finally {
      await AsyncStorage.removeItem('authToken');
    }
  },

  async isAuthenticated() {
    const token = await AsyncStorage.getItem('authToken');
    return !!token;
  },
};
```

### Usage in Components

```javascript
import React, { useState } from 'react';
import { View, TextInput, Button, Alert } from 'react-native';
import { authService } from './services/authService';

const LoginScreen = ({ navigation }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    try {
      setLoading(true);
      const data = await authService.login(email, password);
      Alert.alert('Success', data.status.message);
      navigation.navigate('Home');
    } catch (error) {
      Alert.alert('Error', error.response?.data?.error || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
      />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      <Button
        title="Login"
        onPress={handleLogin}
        disabled={loading}
      />
    </View>
  );
};

export default LoginScreen;
```

### Making API Calls

```javascript
import api from './api';

// Get posts
export const getPosts = async () => {
  const response = await api.get('/api/v1/posts');
  return response.data;
};

// Create post
export const createPost = async (title, content) => {
  const response = await api.post('/api/v1/posts', {
    post: { title, content }
  });
  return response.data;
};

// Update post
export const updatePost = async (id, title, content) => {
  const response = await api.put(`/api/v1/posts/${id}`, {
    post: { title, content }
  });
  return response.data;
};

// Delete post
export const deletePost = async (id) => {
  const response = await api.delete(`/api/v1/posts/${id}`);
  return response.data;
};
```

## Error Handling

### Common HTTP Status Codes

- `200` - Success
- `201` - Created
- `401` - Unauthorized (invalid or expired token)
- `403` - Forbidden (not authorized to perform action)
- `404` - Not Found
- `422` - Unprocessable Entity (validation errors)
- `500` - Internal Server Error

### Error Response Format

```json
{
  "error": "You are not authorized to perform this action"
}
```

Or for validation errors:

```json
{
  "status": {
    "message": "User couldn't be created successfully. Email has already been taken"
  },
  "data": {
    "email": ["has already been taken"]
  }
}
```

## Token Expiration

JWT tokens expire after 24 hours by default. When a token expires:

1. API returns `401 Unauthorized`
2. Client should clear the token from storage
3. Redirect user to login screen
4. User needs to login again to get a new token

## Testing with Postman

1. Create a new request
2. Set method to POST
3. URL: `http://localhost:3000/users/sign_in`
4. Headers:
   - `Content-Type: application/json`
5. Body (raw JSON):
   ```json
   {
     "user": {
       "email": "user@example.com",
       "password": "password123"
     }
   }
   ```
6. Send request
7. Copy the token from the `Authorization` response header
8. Use this token in subsequent requests

## Security Best Practices

1. **Always use HTTPS in production**
2. **Store tokens securely** (use AsyncStorage or SecureStore in React Native)
3. **Never log tokens** in production
4. **Implement token refresh** if needed for better UX
5. **Handle token expiration gracefully**
6. **Clear tokens on logout**
7. **Validate all user inputs**
8. **Use strong passwords** (min 6 characters by default in Devise)
