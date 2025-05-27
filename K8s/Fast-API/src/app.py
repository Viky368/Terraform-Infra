# app.py
from fastapi import FastAPI

# Create an instance of FastAPI
app = FastAPI()

# Define a route for the root path
@app.get("/")
def read_root():
    return {"message": "This is a test project"}

# Define a route for a specific path (e.g., /testapi)
@app.get("/testapi")
def read_testapi():
    return {"message": "This is a test project - /testapi endpoint"}
