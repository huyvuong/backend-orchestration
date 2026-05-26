import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_s3_webhook_accepted():
    mock_event = {
        "Records": [
            {
                "eventName": "ObjectCreated:Put",
                "s3": {
                    "bucket": {"name": "test-bucket"},
                    "object": {"key": "runs/run123/SAMPLE1_R1.fastq.gz"}
                }
            }
        ]
    }
    
    response = client.post("/webhook/s3", json=mock_event)
    assert response.status_code == 202
    assert response.json()["status"] == "accepted"

def test_s3_webhook_invalid_payload():
    mock_event = {"bad_payload": True}
    response = client.post("/webhook/s3", json=mock_event)
    assert response.status_code == 422 # Validation Error from Pydantic
