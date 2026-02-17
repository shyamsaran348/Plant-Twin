# 🌱 GreenTwin

> **An Intelligent Plant Care Assistant Powered by Digital Twins**

![GreenTwin Banner](https://images.unsplash.com/photo-1530968464165-7a1861cbaf9f?q=80&w=2670&auto=format&fit=crop)

---

## 1. Problem Statement

Plant care is often inconsistent, reactive, and knowledge-heavy. Users managing home gardens, institutional green spaces, or small farms struggle with:

*   **Remembering correct care schedules**
*   **Understanding plant-specific needs**
*   **Identifying diseases early**
*   **Tracking plant health progression over time**

Most existing solutions offer static care tips or isolated features such as reminders or image lookup, but fail to provide a **continuous, intelligent understanding** of plant health. This leads to late disease detection, improper care decisions, plant loss, and inefficient resource use.

**There is a need for a unified plant care assistant that combines guidance, monitoring, and intelligence into a single, reliable system.**

---

## 2. Solution Overview

**GreenTwin** is a full-stack, production-ready plant care application that assists users throughout the complete lifecycle of plant management. Each plant is represented as a **digital twin** — a continuously updated digital representation that reflects the plant’s health, growth, stress, and disease risk.

GreenTwin enables users to:

*   **Create and manage detailed plant profiles (Digital Twins)**
*   **Receive timely, intelligent care reminders**
*   **Monitor plant health through real-time visual indicators**
*   **Detect diseases early using image-based Machine Learning**
*   **Track growth history through interactive charts and galleries**

The system is designed for **real usage**, not demonstration, with persistent data, real inference, and real user workflows.

---

## 3. Core Innovation

GreenTwin introduces three key innovations:

1.  **Digital Twins for Plants**: Each plant maintains a live internal state that evolves over time instead of static records.
2.  **Novelty**: Implements a **Synergistic Stress Model** where Disease and Drought multiply each other's impact (Non-linear decay).
3.  **Biological Realism**: Includes a **Recovery Lag** system—plants heal slowly over time rather than instantly resetting.
4.  **Integrated Disease Intelligence**: Machine learning analyzes leaf images to assess disease risk and feed results directly into plant health simulation.
5.  **Unified Assistant Experience**: Care tips, reminders, disease alerts, and progress tracking are delivered through a single coherent interface rather than separate tools.
6.  **Active Adaptation (Auto-Pilot)**: The system doesn't just monitor; it acts. It automatically skips watering schedules during rain and triggers emergency alerts during heatwaves.

---

## 4. Application Architecture

### 4.1 Digital Twin Engine

Each plant twin maintains:

*   **Health Score (0–100)**: Overall vitality.
*   **Growth Stage**: Seedling, Vegetative, Flowering, Fruiting, HarvestReady.
*   **Water Stress Level**: 0.0 (Hydrated) to 1.0 (Critical).
*   **Heat / Light Stress**: Impact of environmental factors.
*   **Disease Risk Index**: Cumulative risk based on history and diagnostics.

These values are updated based on user care actions, disease prediction results, and historical trends. This allows the system to generate **predictive alerts**, not just reactive warnings.

### 4.2 Intelligent Care Advisor (The Brain) 🧠

Beyond simple schedules, GreenTwin uses a **Species-Specific Knowledge Base** combined with real-time **Hyper-Local Weather Telemetry**.

*   **Context-Aware Advice**: "Mist your Ferns" (Low Humidity) vs "Water your Cactus" (Heatwave).
*   **Daily Tips**: Personalized advice on the dashboard every morning.
*   **Auto-Pilot Scheduler**:
    *   **Rain Detected**: Auto-Skips watering tasks.
    *   **Heat > 35°C**: Creates URGENT priority tasks.

### 4.3 Machine Learning Architecture

GreenTwin uses a plant-specific disease intelligence framework, reflecting real biological differences between plants.

**ML Flow:**
1.  User uploads a leaf image via the app.
2.  Selects plant type.
3.  Backend routes request to the correct plant model.
4.  **CNN** predicts disease class and confidence.
5.  Output updates digital twin state instantly.
6.  Alerts and recommendations are generated.

The platform supports multiple plant models, each independently trained (currently optimized for Tomato plants).

---

## 5. Dataset Details

**Dataset Used**: PlantVillage Dataset (Public agricultural research dataset).

**Supported Species (14 Types):**
*   **Apple**: Scab, Black Rot, Cedar Rust, Healthy
*   **Blueberry**: Healthy
*   **Cherry**: Powdery Mildew, Healthy
*   **Corn**: Gray Leaf Spot, Common Rust, Northern Leaf Blight, Healthy
*   **Grape**: Black Rot, Esca (Black Measles), Leaf Blight, Healthy
*   **Orange**: Huanglongbing (Citrus Greening)
*   **Peach**: Bacterial Spot, Healthy
*   **Pepper, Bell**: Bacterial Spot, Healthy
*   **Potato**: Early Blight, Late Blight, Healthy
*   **Raspberry**: Healthy
*   **Soybean**: Healthy
*   **Squash**: Powdery Mildew
*   **Strawberry**: Leaf Scorch, Healthy
*   **Tomato**: Bacterial Spot, Early Blight, Late Blight, Leaf Mold, Septoria Leaf Spot, Spider Mites, Target Spot, Mosaic Virus, Yellow Leaf Curl Virus, Healthy

---

## 6. Technology Stack

### Frontend (Mobile App)
*   **Framework**: Flutter (Dart) - Cross-platform mobile development.
*   **Design System**: Custom "Forest & Mist" Theme using Material 3 and Google Fonts (Poppins/Lato).
*   **Visualizations**: `fl_chart` for real-time growth tracking.
*   **State Management**: Provider / Managed State for Digital Twin updates.

### Backend
*   **Python**: FastAPI - High-performance async API.
*   **ML Integration**: PyTorch for model inference.
*   **Scheduling**: APScheduler for reminders.
*   **Digital Twin Engine**: Custom Python logic.

### Machine Learning
*   **Python**: PyTorch / MobileNetV2 (Transfer Learning).
*   **Inference**: Confidence-based predictions.

### Database & Storage
*   **Relational Database**: PostgreSQL (Supabase) ☁️ / SQLite (Local).
*   **Persistence**: Persistent plant and user data.

---

## 7. User-Facing Features

| Category | New Features in v2.0 |
| :--- | :--- |
| **Dashboard** | ✅ Digital Twin Cards (Health Rings)<br>✅ Weather Integration<br>✅ Daily Care Tips |
| **Plant Profile** | ✅ Growth Charts (Height over time)<br>✅ Vital Signs Grid (Water/Heat/Disease)<br>✅ History Gallery |
| **Diagnosis** | ✅ AI Disease Scanning<br>✅ Risk Assessment<br>✅ Treatment Recommendations |
| **Automation** | ✅ Smart Reminders<br>✅ Auto-Pilot Mode (Rain Skips)<br>✅ Heat Emergency Alerts |
| **Experience** | ✅ Professional UI<br>✅ Dark/Light Mode Support<br>✅ Glassmorphism Effects |

---

## 8. SDG Alignment

*   **SDG 2 – Zero Hunger**: Reduces crop loss through early intervention; Improves plant health reliability.
*   **SDG 3 – Good Health & Well-Being**: Healthier plants contribute to safer food systems; Reduced chemical misuse through early alerts.

---

## 9. Final Positioning Statement

**GreenTwin** is a complete, intelligent plant care assistant that uses digital twins and machine learning to guide users through plant management, health monitoring, and disease prevention. It is built as a real-world application with scalable intelligence, not a limited demonstration.

---

## 🛠 Setup Instructions

### Prerequisites
*   Python 3.9+
*   Flutter SDK (3.16+)
*   Git

### 1. Clone the Repository
```bash
git clone https://github.com/Start-Sense/Plant-Twin.git
cd Plant-Twin
```

### 2. Backend Setup
The backend powers the Digital Twin engine and ML inference.

Navigate to `backend/`:
```bash
cd backend
```
Create a virtual environment (optional but recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```
Install dependencies:
```bash
pip install -r requirements.txt
```
Run the server:
```bash
uvicorn app.main:app --reload
```
*Server will start at `http://localhost:8000`*

### 3. Frontend Setup (Flutter App)
The mobile application provides the user interface.

Navigate to the Flutter project directory:
```bash
cd plant_twin
```
Install dependencies:
```bash
flutter pub get
```
Run the app:

**For Mobile (Emulator/Device):**
```bash
flutter run
```

**For Web:**
```bash
flutter run -d chrome --web-port=8080
```

---
*Built with 💚 for the Hackathon*
