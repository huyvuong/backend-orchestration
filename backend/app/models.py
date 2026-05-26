from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from .database import Base

class Sample(Base):
    __tablename__ = "samples"

    id = Column(Integer, primary_key=True, index=True)
    sample_id = Column(String, index=True, nullable=False)
    run_id = Column(String, index=True, nullable=False)
    bucket = Column(String, nullable=False)
    s3_key = Column(String, nullable=False)
    status = Column(String, nullable=False, default="PENDING")
    batch_job_id = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
