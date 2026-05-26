import logging
from pythonjsonlogger import jsonlogger
import sys

def setup_logger(name: str) -> logging.Logger:
    """Configures structured JSON logging for distributed observability."""
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)

    # Prevent adding handlers multiple times if instantiated multiple times
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        
        # Include critical context for debugging distributed systems
        formatter = jsonlogger.JsonFormatter(
            '%(asctime)s %(levelname)s %(name)s %(message)s %(sample_id)s %(run_id)s %(batch_job_id)s',
            timestamp=True
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        
    return logger

log = setup_logger("orchestrator")
