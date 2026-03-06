# Skill Design Patterns

Patterns observed from early adopters and internal teams. Use as
reference when designing skills, not prescriptive templates.

## Pattern 1: Sequential Workflow Orchestration

Use when users need multi-step processes in a specific order.

```markdown
## Workflow: Onboard New Customer

### Step 1: Create Account

Call MCP tool: `create_customer`
Parameters: name, email, company

### Step 2: Setup Payment

Call MCP tool: `setup_payment_method`
Wait for: payment method verification

### Step 3: Send Welcome Email

Call MCP tool: `send_email`
Template: welcome_email_template
```

Key techniques:

- Explicit step ordering with dependencies
- Validation at each stage
- Rollback instructions for failures

## Pattern 2: Multi-MCP Coordination

Use when workflows span multiple services.

```markdown
### Phase 1: Design Export (Figma MCP)

1. Export design assets from Figma
2. Generate design specifications

### Phase 2: Asset Storage (Drive MCP)

1. Create project folder in Drive
2. Upload all assets, generate shareable links

### Phase 3: Task Creation (Linear MCP)

1. Create development tasks with asset links

### Phase 4: Notification (Slack MCP)

1. Post handoff summary to #engineering
```

Key techniques:

- Clear phase separation
- Data passing between MCP calls
- Validation before moving to next phase
- Centralized error handling

## Pattern 3: Iterative Refinement

Use when output quality improves with iteration.

```markdown
## Iterative Report Creation

### Initial Draft

1. Fetch data via MCP
2. Generate first draft
3. Save to temporary file

### Quality Check

1. Run validation: `scripts/check_report.py`
2. Identify issues (missing sections, formatting errors)

### Refinement Loop

1. Address each issue
2. Regenerate affected sections
3. Re-validate until quality threshold met
```

Key techniques:

- Explicit quality criteria
- Validation scripts for deterministic checks
- Clear stopping condition

## Pattern 4: Context-Aware Tool Selection

Use when the same outcome requires different tools depending on context.

```markdown
## Smart File Storage

### Decision Tree

1. Check file type and size
2. Determine best storage:
   - Large files (>10MB): Use cloud storage MCP
   - Collaborative docs: Use Notion/Docs MCP
   - Code files: Use GitHub MCP
   - Temporary files: Use local storage

### Execute Storage

Based on decision, call appropriate MCP tool with
service-specific metadata.
```

Key techniques:

- Clear decision criteria
- Fallback options
- Transparency about choices made

## Pattern 5: Domain-Specific Intelligence

Use when the skill adds specialized knowledge beyond tool access.

```markdown
## Payment Processing with Compliance

### Before Processing (Compliance Check)

1. Fetch transaction details via MCP
2. Apply compliance rules:
   - Check sanctions lists
   - Verify jurisdiction allowances
   - Assess risk level
3. Document compliance decision

### Processing

IF compliance passed:

- Call payment processing MCP tool
- Apply appropriate fraud checks
  ELSE:
- Flag for review, create compliance case

### Audit Trail

- Log all compliance checks and decisions
- Generate audit report
```

Key techniques:

- Domain expertise embedded in logic
- Compliance gates before action
- Comprehensive audit documentation
