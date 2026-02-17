from app.ml.inference import inference_service, MODEL_PATH, CLASSES_PATH
import os

print(f"DEBUG: Calculated Model Path: {MODEL_PATH}")
print(f"DEBUG: Calculated Classes Path: {CLASSES_PATH}")

# Create a dummy file or use an existing one if possible
# Let's verify the model loading first
print(f"Model Loaded: {inference_service.model is not None}")
print(f"Classes: {inference_service.classes}")

# if model is loaded, we can't easily test a real image without having one valid path.
# But we can check if it returns Mock Healthy immediately.
if not inference_service.model:
    print("CRITICAL: Model failed to load. returning Mock Healthy.")
else:
    print("Model is ready.")
