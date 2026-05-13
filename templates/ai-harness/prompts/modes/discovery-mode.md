# Discovery Mode

Analyze documentation from:

.ai-harness/docs/00-project-context/
.ai-harness/docs/10-feature-requests/
.ai-harness/docs/20-change-requests/

Also analyze:
- repository architecture
- stack
- backend/frontend structure
- test setup
- conventions
- integrations
- risks

Output:
.ai-harness/runtime/discovery-report.md

The discovery report must include:
- list of documentation files read
- source summary per file
- current architecture
- requested features
- inferred domains
- existing test setup
- risks
- missing information
- contradictions
- recommended spec boundaries

If a documentation file cannot be read, stop and create:

.ai-harness/runtime/human-needed.md