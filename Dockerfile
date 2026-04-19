# Use a minimal Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependency file first (better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Run the application
<<<<<<< HEAD
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
=======
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
>>>>>>> 8d74be2 (commit 2)
