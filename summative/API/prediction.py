from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, conint, confloat
import joblib
import numpy as np

# Load model and scaler
model = joblib.load("../best_dropout_model.pkl")
scaler = joblib.load("../scaler.pkl")

from pydantic import Field

class PredictionInput(BaseModel):
    age_at_enrollment: int = Field(..., ge=15, le=70)
    gender: int = Field(..., ge=0, le=1)
    scholarship_holder: int = Field(..., ge=0, le=1)
    first_sem_grade: float = Field(..., ge=0, le=20)
    second_sem_grade: float = Field(..., ge=0, le=20)
    debtor: int = Field(..., ge=0, le=1)
    tuition_fees_up_to_date: int = Field(..., ge=0, le=1)
    parents_avg_education: float = Field(..., ge=1, le=23)
    financial_stress: int = Field(..., ge=0, le=1)
    low_family_education: int = Field(..., ge=0, le=1)

app = FastAPI(
    title="Student Dropout Prediction API",
    description="Predicts student dropout risk using a trained ML model.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class_names = {0: "Dropout", 1: "Enrolled", 2: "Graduate"}

@app.post("/predict")
def predict(input: PredictionInput):
    features = np.array([[input.age_at_enrollment, input.gender, input.scholarship_holder,
                          input.first_sem_grade, input.second_sem_grade, input.debtor,
                          input.tuition_fees_up_to_date, input.parents_avg_education,
                          input.financial_stress, input.low_family_education]])
    features_scaled = scaler.transform(features)
    pred = model.predict(features_scaled)[0]
    pred_class = int(np.round(pred))
    return {"prediction": class_names.get(pred_class, "Unknown")}