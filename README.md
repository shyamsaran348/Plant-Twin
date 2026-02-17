# 🌱 GreenTwin: Intelligent Digital Twin for Home Gardens

> **Production-Grade Plant Intelligence System** | *Powered by Digital Twins & Computer Vision*

![GreenTwin Banner](https://images.unsplash.com/photo-1530968464165-7a1861cbaf9f?q=80&w=2670&auto=format&fit=crop)

## 🚀 Project Status: Complete (v1.0)
GreenTwin is a full-stack automated plant care assistant that goes beyond simple reminders. It creates a **living digital twin** of every plant, simulating its health, stress, and biological needs in real-time.

### ✅ Key Features Implemented
| Feature | Status | Description |
| :--- | :--- | :--- |
| **Universal Disease AI** | 🟢 **Live** | Detects **38 diseases** across **14 species** (Apple, Tomato, Corn, etc.) using MobileNetV2. |
| **Digital Twin Engine** | 🟢 **Live** | Simulates `WaterStress`, `HeatStress`, and `HealthScore` based on user actions. |
| **Smart Watering Logic** | 🟢 **Live** | **Biological Logic**: Rewards watering dry plants (+5 Health) but **penalizes overwatering** (-2 Health) to prevent root rot. |
| **Dynamic User Profile** | 🟢 **Live** | Real-time dashboard showing User Name, Garden Type, and aggregated Plant Stats. |
| **Garden Gallery** | 🟢 **Live** | Visual history of plant growth. Users upload photos to track height and health evolution over time. |
| **Git Integration** | 🟢 **Live** | Fully version-controlled codebase with `requirements.txt` for reproducibility. |

---

## 🧠 Core Architecture (v1.0)

### 1. The Digital Twin Model
Unlike apps that use static "databases", GreenTwin uses a dynamic state model.
*   **State**: Every plant has a `PlantState` (Health, Hydration, Growth Stage).
*   **Logic**: Actions are not just database edits; they are **events** that impact the simulation.
    *   *Event*: `water_plant()`
    *   *Simulation*: `if current_stress < 0.2: apply_penalty(damage=2, type="Overwatering")`

### 2. Tech Stack
*   **Frontend**: **Flutter** (Dart) - Cross-platform mobile/web UI with `fl_chart` for growth analytics.
*   **Backend**: **FastAPI** (Python 3.12) - Async performance, SQLAlchemy ORM, Pydantic validation.
*   **AI Engine**: **PyTorch** - Universal Disease classifier loaded into memory for real-time inference.
*   **Database**: **SQLite** (Dev) / **PostgreSQL** (Prod) - Relational data integrity.

---

## 🔮 Future Vision: GreenTwin 2.0 Architecture
*Designed by Senior AI Systems Architect for Scalability to 100k+ Users*

We have laid the groundwork for a biologically accurate, "Auto-Pilot" system for home gardeners.

### 1. The "Living Twin" Engine (Non-Linear Biology)
Currently, health effects are linear. Real biology is synergistic.
*   **Synergistic Stress**: $Stress_{Total} = S_{water} + S_{disease} + (S_{water} \times S_{disease})$. A thirsty plant dies faster from disease.
*   **Recovery Lag**: Plants will not "snap back" to 100% health instantly. We will implement **Hysteresis** where health recovers over a specific $\Delta t$ (time decay), requiring consistent care.

### 2. Universal Leaf Condition Classifier (ULCC)
Shifting focus from "Crop Diseases" (e.g., Apple Scab) to **Home Plant Symptoms**.
*   **New Classes**: `Yellowing` (Chlorosis), `Browning` (Necrosis), `Drooping` (Turgidity Loss), `Sunburn`.
*   **Architecture**: Multi-Head MobileNetV3 to detect *multiple* concurrent issues (e.g., "Spider Mites" AND "Yellowing").

### 3. Auto-Pilot Intelligence
The Scheduler will become context-aware.
*   **Rain Hook**: Integration with OpenWeatherMap. If `Precipitation > 50%`, the "Watering Reminder" is silently skipped.
*   **Heatwave Alert**: If `Temp > 35°C`, an urgent "Check Hydration" task is generated automatically.

### 4. Scalability & Optimization
*   **Service Layer Separation**: Breaking `plants.py` into `TwinSimulationService`, `DiagnosticsService`, and `EnvironmentService`.
*   **Caching**: Redis implementation for Weather and User Profiles to reduce DB load during morning notification bursts.

---

## 🛠 Setup & Installation

### Prerequisites
*   Python 3.10+
*   Flutter SDK
*   Git

### 1. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```
*Server runs at `http://localhost:8000`*

### 2. Frontend Setup
```bash
cd plant_twin
flutter pub get
flutter run  # or flutter run -d chrome
```

## 📂 Project Structure
```
GreenTwin/
├── backend/
│   ├── app/
│   │   ├── ml/             # Inference Engine
│   │   ├── models/         # SQLAlchemy Models (Plant, User, Log)
│   │   ├── routers/        # API Endpoints
│   │   └── services/       # Twin Engine Logic
│   └── requirements.txt
├── plant_twin/             # Flutter App
│   ├── lib/
│   │   ├── models/         # Dart Data Models
│   │   ├── screens/        # UI Views (Dashboard, Gallery, Camera)
│   │   └── services/       # HTTP API Client
└── README.md
```

---
*Built with 💚 for the Hackathon*
