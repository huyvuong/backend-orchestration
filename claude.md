# Claude AI Instructions & System Context

This repository utilizes an AI-assisted development workflow. When interacting with this codebase using Anthropic's Claude (either via Claude Code CLI, Claude Projects, or the web UI), please adhere to the following rules to maintain system quality.

## Global Rules
1. **No Silent Failures**: All exceptions in Python must be caught, logged using structured JSON logging, and either retried (via Celery) or escalated to the DLQ.
2. **Infrastructure**: When modifying AWS resources, always update the corresponding Terraform state definitions in `infrastructure/`. Never suggest manual AWS Console changes.
3. **Shell Scripting**: All bash scripts must be POSIX-compliant, use `set -euo pipefail`, and pass `shellcheck` without warnings.
4. **Testing**: Any new API endpoint or Celery task must include a corresponding `pytest` in `backend/tests/`.

## Python (FastAPI & Celery)
- Use `ruff` for formatting and linting. 
- Use type hints (`pydantic` schemas) extensively.
- For all backend logs, use the custom JSON logger defined in `backend/app/logger.py`. Key fields (e.g., `sample_id`, `run_id`, `batch_job_id`) must always be attached to the log context to enable distributed tracing.

## Nextflow
- All processes must be containerized (Docker/Singularity).
- Ensure resource requests (cpus, memory, time) are externalized to the `nextflow.config` profiles (`aws_batch.config` and `slurm.config`), rather than hardcoded in `main.nf`.

*By strictly following these instructions, we ensure the orchestrator remains robust, observable, and easy to maintain.*
