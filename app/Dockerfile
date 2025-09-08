FROM python:3.12-slim

# Create non-root user
RUN useradd -m appuser
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1     PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

USER appuser
EXPOSE 8080
# Uvicorn binds to 0.0.0.0:8080 so it matches the Helm chart's targetPort
ENV PORT=8080
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
