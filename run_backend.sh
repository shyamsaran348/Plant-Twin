#!/bin/bash
echo "🌱 Starting Plant-Twin Backend..."
cd backend
# Check if venv exists, activate if so
if [ -d "venv" ]; then
    source venv/bin/activate
fi
pip install -r requirements.txt
uvicorn app.main:app --reload
