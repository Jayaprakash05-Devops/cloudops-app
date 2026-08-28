# 🚀 Authentication Quick Start

## ✅ What's New

Your CloudOps Command Center now has **complete authentication**:

- 🔐 **Login Page** with modern UI
- 👥 **User Management** (Admin only)
- 🎫 **JWT Authentication**
- 🛡️ **Protected Routes** (all pages require login)
- 👤 **User Roles** (Admin & User)

---

## 🎯 Quick Test (5 Minutes)

### 1. Start the Platform

```bash
docker-compose up -d
```

Wait 10-15 seconds for services to start.

### 2. Open the Dashboard

```
http://localhost:3000
```

You'll see the **login page** automatically.

### 3. Login with Default Admin

**Username:** `admin`  
**Password:** `admin123`

Click "Sign In" and you'll be redirected to the dashboard.

### 4. Try User Management

1. Look at the sidebar - you'll see **"Users"** option (admins only)
2. Click **"Users"** to open the user management page
3. Click **"+ Add User"** to create a new user
4. Fill in the form:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `test123`
   - Full Name: `Test User`
   - Role: `user`
5. Click **"Add User"**

### 5. Test the New User

1. Click on your profile in the sidebar footer
2. Click **"Logout"**
3. Login with:
   - Username: `testuser`
   - Password: `test123`
4. Notice the **"Users"** menu is gone (only admins see it)

### 6. Logout

Click on your profile → **"Logout"**

---

## 📊 What You Can Do

### As Admin (username: admin)

✅ Access all dashboard pages  
✅ View **User Management** page  
✅ Add new users  
✅ Edit users (change role, email, name)  
✅ Deactivate/Activate users  
✅ Delete users (except admin)  
✅ Reset user passwords  
✅ Change your own password  

### As Regular User

✅ Access all dashboard pages  
✅ View cost optimizer  
✅ View Kubernetes manager  
✅ View incidents  
✅ View automation  
✅ View ChatOps  
✅ View metrics  
✅ Read user guide  
❌ Cannot access User Management  
✅ Change your own password  

---

## 🔧 API Testing

### Test Login API

```bash
curl -X POST http://localhost:8007/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "xxx",
    "username": "admin",
    "email": "admin@cloudops.local",
    "full_name": "Administrator",
    "role": "admin",
    "is_active": true
  }
}
```

### Test Protected Endpoint

```bash
# Save token
TOKEN=$(curl -s -X POST http://localhost:8007/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | jq -r '.access_token')

# Use token
curl http://localhost:8007/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

### Create New User (Admin Only)

```bash
curl -X POST http://localhost:8007/auth/register \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "developer",
    "email": "dev@example.com",
    "password": "dev123",
    "full_name": "Developer User",
    "role": "user"
  }'
```

---

## 📁 What Was Added

### New Service

```
services/auth-service/
├── main.py              # FastAPI authentication service
├── requirements.txt     # Dependencies
└── Dockerfile           # Container image
```

**Port:** 8007  
**API Docs:** http://localhost:8007/docs

### New Frontend Pages

```
frontend/src/
├── context/
│   └── AuthContext.jsx       # Auth state management
├── pages/
│   ├── Login.jsx             # Login page
│   └── UserManagement.jsx    # Admin user management
└── styles/
    └── Login.css             # Login page styling
```

### Updated Files

- `frontend/src/App.jsx` - Added protected routes
- `frontend/src/styles/App.css` - Added auth styles
- `docker-compose.yml` - Added auth-service
- `test-services.sh` - Added auth service tests

---

## 🎨 Features Showcase

### Login Page
- Beautiful gradient background with animated orbs
- Modern glassmorphism card design
- Real-time form validation
- Loading states
- Error messages
- Default credentials shown

### User Profile (Sidebar)
- Shows user avatar (first letter of name)
- Displays full name and role
- Dropdown menu with:
  - Email address
  - Logout button

### User Management Page (Admin)
- Table view of all users
- Search and filter (future)
- Actions per user:
  - ✏️ Edit - Change details
  - 🔑 Reset Password
  - 🗑️ Delete (except admin)
- Add new users with form modal
- Edit users with form modal
- Active/Inactive status toggle

### Protected Routes
- Automatic redirect to login if not authenticated
- Token stored in localStorage
- Auto-refresh on page reload
- 24-hour token expiration
- Clean logout flow

---

## 🔐 Security Features

✅ **Password Hashing** - SHA256 hashed passwords  
✅ **JWT Tokens** - Industry-standard authentication  
✅ **Token Expiration** - 24-hour automatic expiry  
✅ **Role-based Access** - Admin vs User permissions  
✅ **Protected Routes** - All pages require login  
✅ **No Plain-text Storage** - Passwords never stored in plain text  
✅ **Redis Storage** - User data stored in Redis  
✅ **CORS Enabled** - Secure cross-origin requests  

---

## 📚 Documentation

**Complete Guide:** `AUTHENTICATION_GUIDE.md` (60+ sections)

**API Docs:**
- FastAPI Interactive: http://localhost:8007/docs
- ReDoc: http://localhost:8007/redoc

**Quick Tests:**
```bash
./test-services.sh
```

---

## 🚨 Important Notes

### ⚠️ Change Default Password!

The default admin password (`admin123`) should be changed immediately:

1. Login as admin
2. Use the change password API:

```bash
curl -X POST http://localhost:8007/auth/change-password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "old_password": "admin123",
    "new_password": "YourNewSecurePassword123"
  }'
```

### 🔄 Token Lifetime

- Tokens expire after **24 hours**
- You'll be automatically logged out
- Simply login again to get a new token

### 🗑️ Cannot Delete Admin

- The default `admin` user cannot be deleted
- This prevents you from locking yourself out
- You can create additional admin users

---

## 🎯 Next Steps

### Immediate
1. ✅ Login with default admin
2. ✅ Change admin password
3. ✅ Create your team users
4. ✅ Assign appropriate roles

### Soon
- Add password strength requirements
- Add email verification
- Add password reset via email
- Add 2FA (Two-Factor Authentication)
- Add audit logs
- Add session management dashboard

---

## 🐛 Troubleshooting

### Can't Login

**Check:**
1. Services are running: `docker-compose ps`
2. Auth service is healthy: `curl http://localhost:8007/health`
3. Using correct credentials: `admin` / `admin123`

**Solution:**
```bash
docker-compose restart auth-service
```

### Token Expired

**Symptom:** Automatic redirect to login  
**Solution:** Normal behavior - login again

### Can't Access User Management

**Check:** You're logged in as admin  
**Reason:** Only admin role can access this page

### Frontend Not Loading

**Check:**
```bash
docker logs cloudops-frontend
curl http://localhost:3000
```

**Solution:**
```bash
docker-compose restart frontend
```

---

## 📞 Get Help

**Check Service Health:**
```bash
./test-services.sh
```

**View Logs:**
```bash
docker logs cloudops-auth-service
docker logs cloudops-frontend
```

**Restart Services:**
```bash
docker-compose restart
```

---

## 🎉 Summary

**What You Have:**

✅ Complete authentication system  
✅ Login page with modern UI  
✅ User management for admins  
✅ JWT token-based auth  
✅ Protected routes  
✅ Role-based access control  
✅ Secure password hashing  
✅ 8 backend services (including auth)  
✅ 1 interactive dashboard  
✅ Full documentation  

**Access Now:**

```
http://localhost:3000
```

**Default Login:**
- Username: `admin`
- Password: `admin123`

**Enjoy your secure CloudOps Command Center!** 🚀
