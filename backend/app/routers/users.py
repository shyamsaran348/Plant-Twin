from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, Dict

from app import database
from app.models.user import User
from app.models.plant import Plant
from app.dependencies import get_current_user
from app.schemas.user_schema import UserOut

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

class LocationUpdate(BaseModel):
    latitude: float
    longitude: float

class GardenStats(BaseModel):
    total_plants: int
    flowering: int
    vegetables: int
    herbs: int
    streak_days: int # Mocked for now, or calculated from logs
    garden_status: str # Good/Average/Bad based on avg health

class UserProfile(UserOut):
    garden_stats: GardenStats

@router.get("/me", response_model=UserProfile)
def get_current_user_profile(
    db: Session = Depends(database.get_db),
    current_user: User = Depends(get_current_user)
):
    plants = db.query(Plant).filter(Plant.user_id == current_user.id).all()
    
    total = len(plants)
    flowering = 0
    vegetables = 0
    herbs = 0
    
    total_health = 0.0
    
    for plant in plants:
        # Simple categorization based on species name (mock logic)
        species_lower = plant.species.lower()
        if any(x in species_lower for x in ['rose', 'lily', 'flower', 'orchid', 'jasmine']):
            flowering += 1
        elif any(x in species_lower for x in ['tomato', 'pepper', 'spinach', 'carrot', 'potato']):
            vegetables += 1
        elif any(x in species_lower for x in ['basil', 'mint', 'thyme', 'oregano', 'tulsi']):
            herbs += 1
        else:
            # Default fallback for unclassified
            flowering += 1 

        if plant.plant_state:
            total_health += plant.plant_state.health_score
            
    avg_health = total_health / total if total > 0 else 100.0
    
    garden_status = "Good"
    if avg_health < 50:
        garden_status = "Needs Attention"
    elif avg_health < 80:
        garden_status = "Average"
        
    stats = GardenStats(
        total_plants=total,
        flowering=flowering,
        vegetables=vegetables,
        herbs=herbs,
        streak_days=12, # Mocked for Hackathon
        garden_status=garden_status
    )
    
    # Create response by copying user data and adding stats
    return UserProfile(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        garden_type=current_user.garden_type,
        garden_stats=stats
    )

@router.post("/location")
def update_location(
    loc_data: LocationUpdate, 
    db: Session = Depends(database.get_db), 
    current_user: User = Depends(get_current_user)
):
    try:
        current_user.latitude = loc_data.latitude
        current_user.longitude = loc_data.longitude
        db.commit()
        return {"message": "Location updated successfully"}
    except Exception as e:
        print(f"Error updating location: {e}")
        raise HTTPException(status_code=500, detail="Failed to update location")
