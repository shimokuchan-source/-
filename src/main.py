import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Pomodoro Focus App")

# 静的ファイルの配信
if not os.path.exists("src/static"):
    os.makedirs("src/static", exist_ok=True)

app.mount("/static", StaticFiles(directory="src/static"), name="static")

@app.get("/")
def read_index():
    return FileResponse("src/static/index.html")
