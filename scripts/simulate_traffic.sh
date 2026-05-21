#!/usr/bin/env bash
# simulate_traffic.sh
# Sends mock S3 event payloads to the FastAPI backend to load test the Celery queue.

set -euo pipefail

API_URL="http://localhost:8000/webhook/s3"
NUM_REQUESTS=${1:-5}

echo "Simulating $NUM_REQUESTS S3 upload events to $API_URL..."

for i in $(seq 1 "$NUM_REQUESTS"); do
  SAMPLE_ID="SAMPLE_$(printf "%04d" "$i")"
  
  PAYLOAD=$(cat <<EOF
{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "us-west-2",
      "eventName": "ObjectCreated:Put",
      "s3": {
        "bucket": {
          "name": "illumina-sequencing-landing-zone"
        },
        "object": {
          "key": "runs/230521_A01234_0001_AHFCW2DSX3/${SAMPLE_ID}_R1.fastq.gz"
        }
      }
    }
  ]
}
EOF
)

  echo "Sending event for $SAMPLE_ID..."
  curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$API_URL"
  echo -e "\n"
  sleep 0.5
done

echo "Done simulating traffic. Check the Celery worker logs to see queued jobs processing."
