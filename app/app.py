from fastapi import FastAPI
from fastapi.responses import PlainTextResponse

app = FastAPI()

@app.get("/healthz", response_class=PlainTextResponse)
def health():
    return "ok"

@app.get("/", response_class=PlainTextResponse)
def root():
    # Simple log-like print; uvicorn will capture stdout
    print("Hello endpoint hit")
    return "Hello World from FastAPI on GKE + Helm!"
