import torch
from torchvision import models, transforms
from PIL import Image
import json
import os
import torch.nn as nn

# Configuration
import pathlib
# backend/app/ml/inference.py -> backend/app/ml -> backend/app -> backend
BASE_DIR = pathlib.Path(__file__).parent.parent.parent.absolute()
# GreenTwin/backend -> GreenTwin
PROJECT_ROOT = BASE_DIR.parent

# Assuming structure: backend/app/ml_models/universal/universal_model.pth
# Wait, let's check where the user said the model is.
# In step 1798 commit: create mode 100644 backend/app/ml_models/universal/classes.json
# So it is inside backend/app/ml_models...
# BUT, my previous code said: os.path.join(PROJECT_ROOT, "ml_models/universal/universal_model.pth")
# PROJECT_ROOT was GreenTwin/.
# So it was looking for GreenTwin/ml_models...
# ERROR: The model is in GreenTwin/backend/app/ml_models!

MODEL_PATH = os.path.join(BASE_DIR, "app/ml_models/universal/universal_model.pth")
CLASSES_PATH = os.path.join(BASE_DIR, "app/ml_models/universal/classes.json")

class DiseaseInference:
    def __init__(self):
        self.device = torch.device("cpu")
        self.model = None
        self.classes = []
        self.transform = transforms.Compose([
            transforms.Resize(256),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
        # Try loading
        self.load_model()

    def load_model(self):
        if not os.path.exists(MODEL_PATH) or not os.path.exists(CLASSES_PATH):
            print("Universal Model or classes file not found. Inference will be mocked.")
            return

        try:
            # Load Classes
            with open(CLASSES_PATH, 'r') as f:
                self.classes = json.load(f)

            # Load Model Architecture (MobileNetV2)
            self.model = models.mobilenet_v2(pretrained=False)
            num_ftrs = self.model.classifier[1].in_features
            self.model.classifier[1] = nn.Linear(num_ftrs, len(self.classes))
            
            # Load Weights
            self.model.load_state_dict(torch.load(MODEL_PATH, map_location=self.device))
            self.model.eval()
            print("Universal Model loaded successfully.")
        except Exception as e:
            print(f"Failed to load universal model: {e}")
            self.model = None

    def predict(self, image_path: str):
        if not self.model:
            # Mock response if model unavailable
            return {"class": "Mock Healthy", "confidence": 0.99}
            
        try:
            image = Image.open(image_path).convert('RGB')
            image_tensor = self.transform(image).unsqueeze(0).to(self.device)
            
            with torch.no_grad():
                outputs = self.model(image_tensor)
                probabilities = torch.nn.functional.softmax(outputs, dim=1)
                confidence, predicted = torch.max(probabilities, 1)
                
                predicted_class = self.classes[predicted.item()]
                conf_score = confidence.item()
                
                # Heuristic Override for False Positives
                # If the image is clearly green/healthy but model predicts severe disease, trust the color.
                final_class = self._apply_color_heuristic(image, predicted_class, conf_score)
                
                return {"class": final_class, "confidence": conf_score, "raw_class": predicted_class}
        except Exception as e:
            print(f"Prediction error: {e}")
            return {"class": "Error", "confidence": 0.0}

    def _apply_color_heuristic(self, image: Image.Image, predicted_class: str, confidence: float) -> str:
        """
        Check if pixel stats contradict the model prediction.
        E.g., If Image is >50% Green, it's unlikely to be 'Late_blight' (which turns leaves brown/black).
        """
        try:
            # 1. Resize for speed
            img_small = image.resize((50, 50))
            pixels = list(img_small.getdata())
            
            green_pixels = 0
            total_pixels = len(pixels)
            
            for p in pixels:
                r, g, b = p[0], p[1], p[2]
                # "Healthy Green" definition: Green is dominant channel
                if g > r and g > b and g > 50:
                    green_pixels += 1
            
            green_ratio = green_pixels / total_pixels
            
            # Debug
            print(f"Heuristic Check: Predicted {predicted_class}, Green Ratio: {green_ratio:.2f}")

            # 2. Logic: If prediction is a severe disease but image is excessively green -> Override
            if "healthy" not in predicted_class.lower():
                # If green ratio is very high (>60%), it's likely a false positive
                # Relaxed from 0.45 to 0.60 to avoid false negatives on diseased leaves
                print(f"DEBUG: Checking Heuristic. Green Ratio: {green_ratio:.2f}, Class: {predicted_class}")
                
                # TEMPORARILY DISABLED HEURISTIC TO DEBUG USER ISSUE
                # if green_ratio > 0.80: 
                #    print(f"OVERRIDE: Detected {green_ratio:.2f} green. Switching to Healthy.")
                #    return "Healthy"
            
            return predicted_class
            
            return predicted_class

        except Exception as e:
            print(f"Heuristic failed: {e}")
            return predicted_class

inference_service = DiseaseInference()
