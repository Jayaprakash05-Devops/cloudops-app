from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, timedelta
import jwt
import hashlib
import secrets
import redis
import json
import os

app = FastAPI(title="Auth Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# JWT configuration
SECRET_KEY = os.getenv("JWT_SECRET_KEY", secrets.token_urlsafe(32))
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 hours

# Redis connection
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

# HTTP Bearer token
security = HTTPBearer()

# Models
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    full_name: str
    role: str = "user"  # user, admin

class UserLogin(BaseModel):
    username: str
    password: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None

class PasswordChange(BaseModel):
    old_password: str
    new_password: str

class UserResponse(BaseModel):
    id: str
    username: str
    email: str
    full_name: str
    role: str
    is_active: bool
    created_at: str
    last_login: Optional[str] = None

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

# Helper functions
def hash_password(password: str) -> str:
    """Hash password using SHA256"""
    return hashlib.sha256(password.encode()).hexdigest()

def verify_password(password: str, hashed_password: str) -> bool:
    """Verify password against hash"""
    return hash_password(password) == hashed_password

def create_access_token(data: dict) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> dict:
    """Decode JWT access token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

def get_user_by_username(username: str) -> Optional[dict]:
    """Get user from Redis by username"""
    user_data = redis_client.get(f"user:{username}")
    if user_data:
        return json.loads(user_data)
    return None

def get_user_by_id(user_id: str) -> Optional[dict]:
    """Get user from Redis by ID"""
    username = redis_client.get(f"userid:{user_id}")
    if username:
        return get_user_by_username(username)
    return None

def save_user(user: dict):
    """Save user to Redis"""
    redis_client.set(f"user:{user['username']}", json.dumps(user))
    redis_client.set(f"userid:{user['id']}", user['username'])
    redis_client.sadd("users", user['username'])

def get_all_users() -> List[dict]:
    """Get all users from Redis"""
    usernames = redis_client.smembers("users")
    users = []
    for username in usernames:
        user = get_user_by_username(username)
        if user:
            users.append(user)
    return users

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Get current authenticated user"""
    token = credentials.credentials
    payload = decode_access_token(token)
    username = payload.get("sub")
    if not username:
        raise HTTPException(status_code=401, detail="Invalid token")

    user = get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    if not user.get("is_active", True):
        raise HTTPException(status_code=401, detail="User is inactive")

    return user

def require_admin(current_user: dict = Depends(get_current_user)) -> dict:
    """Require admin role"""
    if current_user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return current_user

# Initialize admin user
def init_admin_user():
    """Initialize default admin user"""
    admin = get_user_by_username("admin")
    if not admin:
        admin_user = {
            "id": secrets.token_urlsafe(16),
            "username": "admin",
            "email": "admin@cloudops.local",
            "password": hash_password("admin123"),
            "full_name": "Administrator",
            "role": "admin",
            "is_active": True,
            "created_at": datetime.utcnow().isoformat(),
            "last_login": None
        }
        save_user(admin_user)
        print("✅ Default admin user created (username: admin, password: admin123)")

@app.on_event("startup")
async def startup_event():
    """Initialize on startup"""
    init_admin_user()

# Health check
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        redis_client.ping()
        return {
            "status": "healthy",
            "service": "auth-service",
            "redis": "connected",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "service": "auth-service",
            "redis": "disconnected",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }

# Authentication endpoints
@app.post("/auth/login", response_model=TokenResponse)
async def login(credentials: UserLogin):
    """User login"""
    user = get_user_by_username(credentials.username)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )

    if not verify_password(credentials.password, user["password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )

    if not user.get("is_active", True):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account is inactive"
        )

    # Update last login
    user["last_login"] = datetime.utcnow().isoformat()
    save_user(user)

    # Create access token
    access_token = create_access_token(data={"sub": user["username"]})

    # Remove password from response
    user_response = {k: v for k, v in user.items() if k != "password"}

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user_response
    }

@app.post("/auth/register", response_model=UserResponse)
async def register(user_data: UserCreate, admin: dict = Depends(require_admin)):
    """Register new user (admin only)"""
    # Check if username exists
    existing_user = get_user_by_username(user_data.username)
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")

    # Check if email exists
    all_users = get_all_users()
    for u in all_users:
        if u["email"] == user_data.email:
            raise HTTPException(status_code=400, detail="Email already exists")

    # Create new user
    new_user = {
        "id": secrets.token_urlsafe(16),
        "username": user_data.username,
        "email": user_data.email,
        "password": hash_password(user_data.password),
        "full_name": user_data.full_name,
        "role": user_data.role,
        "is_active": True,
        "created_at": datetime.utcnow().isoformat(),
        "last_login": None
    }

    save_user(new_user)

    # Remove password from response
    return {k: v for k, v in new_user.items() if k != "password"}

@app.get("/auth/me", response_model=UserResponse)
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """Get current user info"""
    return {k: v for k, v in current_user.items() if k != "password"}

@app.post("/auth/verify")
async def verify_token(current_user: dict = Depends(get_current_user)):
    """Verify JWT token"""
    return {
        "valid": True,
        "user": {k: v for k, v in current_user.items() if k != "password"}
    }

@app.post("/auth/change-password")
async def change_password(
    password_data: PasswordChange,
    current_user: dict = Depends(get_current_user)
):
    """Change user password"""
    if not verify_password(password_data.old_password, current_user["password"]):
        raise HTTPException(status_code=400, detail="Invalid old password")

    current_user["password"] = hash_password(password_data.new_password)
    save_user(current_user)

    return {"message": "Password changed successfully"}

# User management endpoints (admin only)
@app.get("/users", response_model=List[UserResponse])
async def list_users(admin: dict = Depends(require_admin)):
    """List all users (admin only)"""
    users = get_all_users()
    return [{k: v for k, v in user.items() if k != "password"} for user in users]

@app.get("/users/{username}", response_model=UserResponse)
async def get_user(username: str, admin: dict = Depends(require_admin)):
    """Get user by username (admin only)"""
    user = get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {k: v for k, v in user.items() if k != "password"}

@app.put("/users/{username}", response_model=UserResponse)
async def update_user(
    username: str,
    user_data: UserUpdate,
    admin: dict = Depends(require_admin)
):
    """Update user (admin only)"""
    user = get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update fields
    if user_data.email is not None:
        user["email"] = user_data.email
    if user_data.full_name is not None:
        user["full_name"] = user_data.full_name
    if user_data.role is not None:
        user["role"] = user_data.role
    if user_data.is_active is not None:
        user["is_active"] = user_data.is_active

    save_user(user)
    return {k: v for k, v in user.items() if k != "password"}

@app.delete("/users/{username}")
async def delete_user(username: str, admin: dict = Depends(require_admin)):
    """Delete user (admin only)"""
    if username == "admin":
        raise HTTPException(status_code=400, detail="Cannot delete admin user")

    user = get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    redis_client.delete(f"user:{username}")
    redis_client.delete(f"userid:{user['id']}")
    redis_client.srem("users", username)

    return {"message": f"User {username} deleted successfully"}

@app.post("/users/{username}/reset-password")
async def reset_password(
    username: str,
    new_password: str,
    admin: dict = Depends(require_admin)
):
    """Reset user password (admin only)"""
    user = get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user["password"] = hash_password(new_password)
    save_user(user)

    return {"message": f"Password reset successfully for user {username}"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8007)
