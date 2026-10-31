# Data Engineering, Analytics, ML and AI Apps

> Last reviewed: October 2026. AI tooling changes monthly — always verify model names, SDK versions and pricing.

## Table of contents
1. Python data stack
2. Data engineering (ingest, transform, orchestrate)
3. Storage for analytics
4. BI and dashboards
5. Notebooks and data apps
6. Classical ML and forecasting
7. Deep learning
8. Model serving and MLOps
9. LLM applications
10. RAG (retrieval-augmented generation)
11. Agents and tool use
12. Evals, safety and cost control
13. Reference stacks

---

## 1. Python data stack
- Environment: **uv** (packages, venvs, Python versions), Ruff, Pyright/mypy, pytest.
- DataFrames: **Polars** (fast, default for new work), pandas (ecosystem, compatibility), DuckDB (SQL over files/frames), PyArrow, Ibis (one API over many backends).
- Validation: Pydantic (objects), Pandera (dataframes), Great Expectations / Soda (data quality).
- Formats: Parquet (default for analytics files), Arrow, Delta Lake / Apache Iceberg (table formats on object storage).
- Excel I/O: openpyxl, fastexcel/calamine (fast reading), xlsxwriter.

## 2. Data engineering
- **Ingestion (EL):** dlt (Python-native, default), Airbyte (connectors, UI), Fivetran (managed), Meltano/Singer; CDC from Postgres: Debezium, PeerDB, Sequin.
- **Transformation (T):** dbt Core/Cloud (SQL models, tests, docs) or SQLMesh (virtual environments, cheaper re-runs).
- **Orchestration:** **Dagster** (asset-based, great dev UX, default), Prefect (Pythonic flows), Apache Airflow (standard in enterprises; Astronomer/MWAA/Composer managed), Kestra (YAML), Mage.
- **Streaming:** Kafka/Redpanda + Flink/RisingWave/Materialize; Bytewax or Quix for Python stream processing.
- Pattern: raw → staging → marts (medallion: bronze/silver/gold). Version everything in git; test data in CI.

## 3. Storage for analytics
| Scale | Choose |
|---|---|
| Small (< tens of GB) | Postgres (+ materialized views), DuckDB files |
| Medium | DuckDB/MotherDuck, ClickHouse, TimescaleDB |
| Large / enterprise | BigQuery, Snowflake, Databricks, ClickHouse Cloud, Redshift, Microsoft Fabric |
| Lakehouse | Parquet + Iceberg/Delta on S3/R2/ADLS, queried by DuckDB/Trino/Spark/Snowflake |

## 4. BI and dashboards
- Microsoft orgs: **Power BI** (DAX, Power Query, Fabric integration, row-level security).
- Open source: **Metabase** (easiest for business users), **Apache Superset** (powerful), **Evidence** (BI as code with SQL + Markdown), Lightdash (dbt-native), Grafana (time series/operations).
- Enterprise alternatives: Tableau, Looker, Qlik.
- Embedded analytics in apps: Metabase/Superset embedding, Cube (semantic layer + API) + custom charts.
- Semantic layer for consistent metrics: dbt Semantic Layer, Cube.

## 5. Notebooks and data apps
- Notebooks: Jupyter/JupyterLab, VS Code notebooks, **marimo** (reactive, git-friendly .py notebooks), Hex/Deepnote (collaborative hosted).
- Data apps: **Streamlit** (fastest), Dash (Plotly, enterprise dashboards), Gradio (ML demos), Panel, NiceGUI, Reflex (full-stack Python), Shiny for Python.
- Deploy: Docker on VPS, Streamlit Community Cloud (public), Hugging Face Spaces (demos), or the organization's data platform (Dataiku, Databricks Apps, Snowflake Streamlit, Posit Connect) to inherit auth and data governance.

## 6. Classical ML and forecasting
- Tabular: scikit-learn (pipelines), **LightGBM** (default gradient boosting), XGBoost, CatBoost (categoricals).
- Hyperparameter tuning: Optuna.
- Explainability: SHAP.
- Time series: **Nixtla statsforecast** (fast ARIMA/ETS/Theta), mlforecast (LightGBM with lags), neuralforecast (NHITS, TFT), Prophet (quick baselines, holidays), sktime/Darts (unified APIs), foundation models (TimeGPT, Chronos, TimesFM, Moirai) for zero-shot baselines — benchmark them against simple models.
- Forecasting practice: rolling-origin backtests, metrics (MAE, MAPE/sMAPE, MASE, WAPE), prediction intervals (conformal prediction), hierarchical reconciliation (hierarchicalforecast), calendar/event features (holidays, Ramadan, school terms, weather, special events).

## 7. Deep learning
- **PyTorch** (default), PyTorch Lightning, Hugging Face Transformers/Datasets/PEFT, JAX for research at scale, Keras 3 (multi-backend).
- Fine-tuning LLMs: Unsloth, Axolotl, TRL, LoRA/QLoRA.
- Compute: Modal, RunPod, Lambda, Vast.ai, Google Colab, cloud GPUs (AWS/GCP/Azure/Oracle/Core42), Kaggle notebooks.

## 8. Model serving and MLOps
- Serving: FastAPI (simple), BentoML, Ray Serve, NVIDIA Triton, TorchServe; ONNX Runtime for portable fast inference; LLM serving: vLLM, SGLang, TGI, Ollama/llama.cpp (local).
- Tracking/registry: MLflow (default, self-host), Weights & Biases, Neptune, Comet.
- Feature store (only at scale): Feast, Tecton.
- Monitoring/drift: Evidently, NannyML, WhyLabs.
- Batch scoring via the orchestrator (Dagster/Prefect) writing results to tables consumed by apps/BI.

## 9. LLM applications
**Choose the integration layer:**
- **Provider SDK directly** (Anthropic, OpenAI, Google Gen AI SDKs) — default; fewest abstractions, newest features first.
- **Vercel AI SDK** (TypeScript) — unified provider API, streaming UI hooks, tool calling, structured output; great with TanStack Start/Next.js.
- **Model routers:** OpenRouter, LiteLLM (self-host proxy), Cloudflare AI Gateway, Vercel AI Gateway — for multi-provider fallback, caching, logging, cost tracking.
- **Frameworks:** LangChain/LangGraph (graphs, many integrations), LlamaIndex (data/RAG focus), Mastra (TS agents/workflows), Pydantic AI (typed Python agents), DSPy (prompt optimization), Haystack. Use when they save real work; avoid deep abstraction for simple apps.
- **Local/open models:** Ollama, LM Studio, vLLM; open-weight families (Llama, Qwen, Mistral, Gemma, DeepSeek) — consider for privacy, cost, on-prem/government data rules.
- **Arabic:** test candidate models on real Arabic (MSA + Gulf dialect) prompts; regional models (e.g., Jais, Falcon, ALLaM) exist — benchmark vs frontier models.

**App patterns:** stream tokens to the UI (SSE); structured outputs with JSON schema/Zod/Pydantic; prompt templates versioned in code; conversation history in Postgres; per-user rate limits and spend caps; background jobs for long tasks; prompt caching to cut cost/latency.

## 10. RAG
1. **Ingest:** parse documents (Unstructured, Docling, LlamaParse, Marker, Azure Document Intelligence, provider PDF support); keep source metadata and permissions.
2. **Chunk:** by structure (headings/sections), ~300–1,000 tokens with overlap; store parent doc references.
3. **Embed:** provider embeddings (OpenAI, Voyage, Cohere, Google) or open (BGE, E5, multilingual/Arabic-capable models); store model name/version with vectors.
4. **Store:** Postgres + pgvector (default), Qdrant for large/dedicated.
5. **Retrieve:** hybrid (BM25/full-text + vectors), metadata filters (tenant, permissions, dates), rerank (Cohere Rerank, Voyage, bge-reranker).
6. **Generate:** cite sources; instruct to say "not found" when context lacks the answer.
7. **Evaluate:** retrieval recall/precision on a labeled question set; answer faithfulness.
Consider simpler options first: long-context models with whole documents, or provider-hosted file search, when data is small.

## 11. Agents and tool use
- Tool calling via provider SDKs; **MCP (Model Context Protocol)** servers to expose tools/data in a reusable way.
- Agent SDKs: Claude Agent SDK, OpenAI Agents SDK, LangGraph, Mastra, Pydantic AI, CrewAI/AutoGen (multi-agent).
- Durable execution for long-running agents: Temporal, Inngest, Trigger.dev, Restate.
- Sandboxed code execution: E2B, Modal sandboxes, Daytona, Cloudflare/Vercel sandboxes, Docker.
- Browser automation: Playwright, Browserbase/Stagehand, Browser Use.
- Guardrails: least-privilege tools, confirmation for destructive actions, prompt-injection defenses, audit logs of tool calls.

## 12. Evals, safety and cost control
- Evals: Promptfoo, Braintrust, LangSmith, Langfuse (open source, self-host; tracing + evals), Arize Phoenix, DeepEval, Ragas (RAG).
- Build a golden test set from real user questions; run evals in CI on prompt/model changes.
- Observability: log prompts, outputs, latency, tokens, cost per request/user (Langfuse, Helicone, provider consoles).
- Cost: choose the smallest model that passes evals; prompt caching; batch APIs for offline jobs; cap max tokens; cache deterministic results.
- Safety: input/output moderation where user-facing; PII redaction before sending to third parties if required; data residency rules for government data (consider local/on-prem models).

## 13. Reference stacks
- **Internal analytics tool:** Python + Polars/DuckDB + Streamlit, data from Postgres/warehouse, deployed on the org data platform or Docker + SSO.
- **Forecasting system:** Dagster (schedules) → dlt ingest → Postgres/Timescale → statsforecast/LightGBM with backtests → MLflow → forecasts table → Power BI/Metabase + FastAPI endpoint.
- **AI chat/RAG SaaS:** TanStack Start + Vercel AI SDK + Better Auth + Postgres/pgvector + Drizzle + R2 (documents) + job queue for ingestion + Langfuse + Redis rate limits + VPS/Cloudflare.
- **AI API microservice:** FastAPI + Pydantic + provider SDK + Postgres + arq/Celery workers + Docker.
