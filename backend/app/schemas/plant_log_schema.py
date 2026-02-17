from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class PlantLogBase(BaseModel):
    height: float

class PlantLogCreate(PlantLogBase):
    pass

class PlantLogOut(PlantLogBase):
    id: int
    plant_id: int
    health_score: float
    image_path: Optional[str] = None
    recorded_at: datetime

    class Config:
        from_attributes = True
