from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session, joinedload
from typing import List
import shutil
import os
import uuid

from app import database
from app.models.plant import Plant
from app.models.plant_state import PlantState
from app.models.disease_record import DiseaseRecord
from app.models.user import User
from app.schemas.plant_schema import PlantCreate, PlantOut
from app.dependencies import get_current_user
from app.ml.inference import inference_service

router = APIRouter(
    prefix="/plants",
    tags=["Plants"]
)

@router.get("/", response_model=List[PlantOut])
def get_plants(db: Session = Depends(database.get_db), current_user: User = Depends(get_current_user)):
    return db.query(Plant).filter(Plant.user_id == current_user.id).all()

@router.post("/", response_model=PlantOut)
async def create_plant(
    name: str = Form(...),
    species: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(database.get_db),
    current_user: User = Depends(get_current_user)
):
    # 1. Save Image
    UPLOAD_DIR = "uploads"
    if not os.path.exists(UPLOAD_DIR):
        os.makedirs(UPLOAD_DIR)
    
    file_extension = file.filename.split(".")[-1]
    filename = f"{uuid.uuid4()}.{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    # 2. Run Initial Inference (Smart Onboarding - Universal)
    # Run analysis for all plants using the new Universal Model
    prediction = inference_service.predict(file_path)
    disease_class = prediction["class"]
    confidence = prediction["confidence"]
    
    print(f"DEBUG: Create Plant Inference -> Class: {disease_class}, Conf: {confidence}")

    # Calculate initial health
    # Calculate initial health using Twin Engine logic
    from app.services.twin_engine import TwinEngine
    
    initial_health = 100.0
    initial_risk = 0.0
    
    if "healthy" not in disease_class.lower() and "mock" not in disease_class.lower():
            print("DEBUG: Disease Detected! Applying Health Penalty.")
            # Use confidence as risk index (min 0.5 to show impact)
            initial_risk = max(0.5, confidence)
            
            # Create a temporary state to calculate health
            temp_state = PlantState(
                water_stress=0.0,
                heat_stress=0.0,
                disease_risk_index=initial_risk
            )
            initial_health = TwinEngine.calculate_health_score(temp_state)
            print(f"DEBUG: Calculated Initial Health: {initial_health}")
    else:
        print("DEBUG: Plant deemed Healthy. Health 100.")

    # 3. Create Plant
    new_plant = Plant(
        name=name,
        species=species,
        user_id=current_user.id,
        image_path=f"uploads/{filename}" # Store relative path for frontend
    )
    db.add(new_plant)
    db.commit()
    db.refresh(new_plant)
    
    # 4. Create Twin State
    new_state = PlantState(
        plant_id=new_plant.id,
        health_score=initial_health,
        disease_risk_index=initial_risk
    )
    db.add(new_state)
    
    # 5. Create Initial Disease Record (History)
    new_record = DiseaseRecord(
        plant_id=new_plant.id,
        predicted_class=disease_class,
        confidence=confidence,
        image_path=f"uploads/{filename}"
    )
    db.add(new_record)
    
    db.commit()
    db.refresh(new_plant)
    
    return new_plant

from app.models.plant_log import PlantLog
from app.schemas.plant_log_schema import PlantLogCreate, PlantLogOut

@router.get("/{plant_id}", response_model=PlantOut)
def get_plant(plant_id: int, db: Session = Depends(database.get_db), current_user: User = Depends(get_current_user)):
    # Eager load plant_state, logs, and disease_records
    plant = db.query(Plant).options(
        joinedload(Plant.plant_state), 
        joinedload(Plant.logs),
        joinedload(Plant.disease_records)
    ).filter(Plant.id == plant_id, Plant.user_id == current_user.id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    return plant

@router.post("/{plant_id}/log", response_model=PlantLogOut)
def log_growth(
    plant_id: int, 
    log_data: PlantLogCreate, 
    db: Session = Depends(database.get_db), 
    current_user: User = Depends(get_current_user)
):
    plant = db.query(Plant).options(joinedload(Plant.plant_state)).filter(Plant.id == plant_id, Plant.user_id == current_user.id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    
    current_health = plant.plant_state.health_score if plant.plant_state else 100.0
    
    new_log = PlantLog(
        plant_id=plant_id,
        height=log_data.height,
        health_score=current_health
    )
    db.add(new_log)
    db.commit()
    db.refresh(new_log)
    return new_log

@router.delete("/{plant_id}")
def delete_plant(plant_id: int, db: Session = Depends(database.get_db), current_user: User = Depends(get_current_user)):
    plant = db.query(Plant).filter(Plant.id == plant_id, Plant.user_id == current_user.id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    
    # Manual logs cascade if needed, but we set cascade in model.
    # We rely on SQLAlchemy cascades for clean cleanup now
    db.delete(plant)
        
    db.commit()
    return {"message": "Plant deleted successfully"}

@router.post("/{plant_id}/water")
def water_plant(plant_id: int, db: Session = Depends(database.get_db), current_user: User = Depends(get_current_user)):
    from app.services.twin_engine import TwinEngine
    
    plant = db.query(Plant).options(joinedload(Plant.plant_state)).filter(Plant.id == plant_id, Plant.user_id == current_user.id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Plant not found")
        
    if plant.plant_state:
        current_stress = plant.plant_state.water_stress
        message = "Plant watered."
        
        # Smart Logic: Check for Overwatering
        if current_stress < 0.2: # Less than 20% stress means it's already hydrated
            # Penalty!
            plant.plant_state.health_score = max(0, plant.plant_state.health_score - 2)
            plant.plant_state.water_stress = 0.0 # Still sets to 0
            message = "Careful! Don't overwater. Health penalty applied (-2)."
        elif current_stress > 0.5: # Dry
            # Bonus!
            plant.plant_state.health_score = min(100, plant.plant_state.health_score + 5)
            plant.plant_state.water_stress = 0.0
            message = "Great job! Plant refreshed. Health bonus applied (+5)."
        else:
            # Normal watering
            plant.plant_state.water_stress = 0.0
            message = "Plant watered successfully."

        db.add(plant.plant_state)
        db.commit()
        db.refresh(plant.plant_state)
        
    return {"message": message, "new_health": plant.plant_state.health_score}

from pydantic import BaseModel

class EnvironmentUpdate(BaseModel):
    temperature: float

@router.post("/{plant_id}/environment")
def update_environment(
    plant_id: int, 
    env_data: EnvironmentUpdate, 
    db: Session = Depends(database.get_db), 
    current_user: User = Depends(get_current_user)
):
    from app.services.twin_engine import TwinEngine
    
    plant = db.query(Plant).options(joinedload(Plant.plant_state)).filter(Plant.id == plant_id, Plant.user_id == current_user.id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Plant not found")
        
    if plant.plant_state:
        plant.plant_state = TwinEngine.update_from_environment(plant.plant_state, env_data.temperature)
        db.add(plant.plant_state)
        db.commit()
        db.refresh(plant.plant_state)
        
    return {
        "message": "Environment updated", 
        "health_score": plant.plant_state.health_score,
        "heat_stress": plant.plant_state.heat_stress
    }
