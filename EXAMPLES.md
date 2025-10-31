# Examples and Use Cases

This guide provides practical examples of using the Claude Context MCP server for various development tasks.

## Table of Contents

- [Getting Started](#getting-started)
- [Basic Usage](#basic-usage)
- [Web Development](#web-development)
- [Backend Development](#backend-development)
- [DevOps and Infrastructure](#devops-and-infrastructure)
- [Code Review and Refactoring](#code-review-and-refactoring)
- [Learning a New Codebase](#learning-a-new-codebase)
- [Debugging](#debugging)
- [Advanced Queries](#advanced-queries)

## Getting Started

### Your First Index

```
You: Index this codebase

Claude: I'll index your codebase now...
[Indexing starts]

You: Check the indexing status

Claude: Indexing is complete! Processed 523 files.
```

### Your First Search

```
You: Find the main entry point of the application

Claude: [Returns relevant code snippets from main.js, index.js, or app.py]
```

## Basic Usage

### Finding Specific Functionality

**Example 1: Authentication**
```
You: Find authentication middleware

Claude: [Returns authentication-related code]
   - src/middleware/auth.js (lines 15-45)
   - src/utils/jwt-helper.js (lines 8-30)
   - src/routes/protected.js (lines 5-12)
```

**Example 2: Database Operations**
```
You: Show me database connection logic

Claude: [Returns database initialization code]
   - src/config/database.js
   - src/models/connection.js
```

**Example 3: API Endpoints**
```
You: Find all REST API endpoints

Claude: [Returns route definitions]
   - src/routes/users.js
   - src/routes/products.js
   - src/routes/auth.js
```

## Web Development

### React Application

**Finding Components**
```
You: Find all React components that use hooks

Claude: [Returns components with useState, useEffect, etc.]
```

**State Management**
```
You: Show me Redux store configuration

Claude: [Returns store setup and reducers]
```

**Routing**
```
You: Find route definitions and navigation logic

Claude: [Returns Router components and navigation code]
```

### Vue.js Application

**Component Discovery**
```
You: Find Vue components with computed properties

Claude: [Returns Vue components with computed sections]
```

**Vuex Store**
```
You: Show me Vuex actions and mutations

Claude: [Returns state management code]
```

### Angular Application

**Services**
```
You: Find all Angular services

Claude: [Returns @Injectable classes]
```

**Routing**
```
You: Show me routing configuration

Claude: [Returns routing modules]
```

## Backend Development

### Node.js/Express

**API Structure**
```
You: Find Express route handlers

Claude: [Returns app.get, app.post, router definitions]
```

**Middleware**
```
You: Show me error handling middleware

Claude: [Returns error handler functions]
```

**Database Queries**
```
You: Find database query methods

Claude: [Returns Model.find(), db.query(), etc.]
```

### Python/Django

**Views and ViewSets**
```
You: Find all Django views

Claude: [Returns view functions and class-based views]
```

**Models**
```
You: Show me database models and their relationships

Claude: [Returns Django models with ForeignKey, ManyToMany]
```

**Serializers**
```
You: Find DRF serializers

Claude: [Returns Django REST Framework serializer classes]
```

### Python/FastAPI

**Endpoints**
```
You: Find FastAPI route handlers

Claude: [Returns @app.get, @app.post decorated functions]
```

**Pydantic Models**
```
You: Show me request/response models

Claude: [Returns BaseModel classes]
```

## DevOps and Infrastructure

### Docker

**Finding Dockerfiles**
```
You: Show me Docker configurations

Claude: [Returns Dockerfile, docker-compose.yml]
```

**Container Orchestration**
```
You: Find Kubernetes manifests

Claude: [Returns .yaml deployment files]
```

### CI/CD

**Pipeline Configuration**
```
You: Find CI/CD pipeline definitions

Claude: [Returns .github/workflows, .gitlab-ci.yml, Jenkinsfile]
```

**Deployment Scripts**
```
You: Show me deployment automation

Claude: [Returns deploy scripts and configurations]
```

### Infrastructure as Code

**Terraform**
```
You: Find Terraform resource definitions

Claude: [Returns .tf files with resources]
```

**CloudFormation**
```
You: Show me AWS CloudFormation templates

Claude: [Returns .yaml/.json templates]
```

## Code Review and Refactoring

### Finding Code Smells

**Duplicate Code**
```
You: Find similar or duplicate code patterns

Claude: [Identifies repeated logic across files]
```

**Complex Functions**
```
You: Show me functions with high complexity

Claude: [Returns long functions, nested logic]
```

**Unused Code**
```
You: Find potentially unused functions or imports

Claude: [Identifies rarely referenced code]
```

### Refactoring Opportunities

**Extracting Common Logic**
```
You: Find code that could be extracted into a utility function

Claude: [Identifies repeated patterns]

You: Create a utility function for these common operations

Claude: [Generates utility function and suggests replacements]
```

**Improving Architecture**
```
You: Show me tightly coupled components

Claude: [Identifies dependencies]

You: Suggest a better separation of concerns

Claude: [Proposes architectural improvements]
```

## Learning a New Codebase

### Understanding Architecture

**Step 1: Entry Points**
```
You: Index this codebase
[Wait for completion]

You: Show me the main entry points and initialization code

Claude: [Returns main.js, index.py, App.tsx, etc.]
```

**Step 2: Core Components**
```
You: What are the main modules or packages in this project?

Claude: [Analyzes structure and explains key components]
```

**Step 3: Data Flow**
```
You: Show me how data flows through the application

Claude: [Traces data from input to output]
```

### Feature Understanding

**Authentication Flow**
```
You: How does user authentication work in this codebase?

Claude: [Explains authentication implementation]

You: Find login and registration handlers

Claude: [Returns relevant code with explanations]
```

**Payment Processing**
```
You: Find code related to payment processing

Claude: [Returns payment integration code]

You: Explain how payments are handled

Claude: [Walks through the payment flow]
```

## Debugging

### Finding Error Sources

**Error Handling**
```
You: Find all error handlers and try-catch blocks

Claude: [Returns error handling code]
```

**Logging**
```
You: Show me where errors are logged

Claude: [Returns logger calls, console.error, etc.]
```

**Validation**
```
You: Find input validation logic

Claude: [Returns validation functions]
```

### Tracing Issues

**Finding a Bug**
```
You: Users report that password reset emails aren't being sent.
     Find code related to password reset email functionality.

Claude: [Returns password reset and email sending code]

You: Are there any error handlers that might silently fail?

Claude: [Identifies potential failure points]

You: Check if email configuration is properly loaded

Claude: [Shows email configuration code]
```

### Testing

**Finding Tests**
```
You: Find unit tests for the authentication module

Claude: [Returns test files]
```

**Coverage Gaps**
```
You: What functionality doesn't have tests?

Claude: [Analyzes code and test coverage]
```

## Advanced Queries

### Complex Searches

**Multi-Concept Searches**
```
You: Find async functions that interact with the database and handle errors

Claude: [Returns complex queries matching all criteria]
```

**Pattern Matching**
```
You: Show me decorator patterns or middleware implementations

Claude: [Identifies design patterns]
```

**Security Analysis**
```
You: Find code that handles user input without validation

Claude: [Identifies potential security issues]
```

### Cross-Referencing

**Dependencies**
```
You: Find all code that depends on the User model

Claude: [Returns imports and usages]
```

**Impact Analysis**
```
You: If I change the authentication function signature,
     what code will be affected?

Claude: [Identifies all callers and dependencies]
```

### Documentation Generation

**API Documentation**
```
You: Find all public API endpoints and describe their purpose

Claude: [Lists endpoints with descriptions]

You: Generate OpenAPI documentation for these endpoints

Claude: [Creates OpenAPI spec]
```

**Code Comments**
```
You: Find complex functions that lack documentation

Claude: [Returns undocumented code]

You: Generate JSDoc comments for these functions

Claude: [Creates documentation]
```

## Real-World Scenarios

### Scenario 1: Adding a New Feature

**Task:** Add a "favorites" feature to a blog application

```
You: Index this codebase
[Complete]

You: Find how blog posts are currently stored and retrieved

Claude: [Shows post models and queries]

You: Show me where posts are displayed to users

Claude: [Returns post rendering components]

You: Find existing similar features like "likes" or "bookmarks"

Claude: [Returns similar implementations]

You: Create a favorites feature following the same pattern

Claude: [Generates code based on existing patterns]
```

### Scenario 2: Performance Optimization

**Task:** Optimize slow API endpoint

```
You: Find the /api/products endpoint implementation

Claude: [Returns endpoint code]

You: What database queries are executed in this endpoint?

Claude: [Shows all queries]

You: Are there any N+1 query problems?

Claude: [Identifies inefficient queries]

You: Show me how other endpoints handle eager loading

Claude: [Returns examples of optimized queries]

You: Optimize this endpoint using the same approach

Claude: [Refactors code for better performance]
```

### Scenario 3: Security Audit

**Task:** Review authentication security

```
You: Find all authentication and authorization code

Claude: [Returns auth implementation]

You: Check if passwords are properly hashed

Claude: [Shows password handling code]

You: Find any hardcoded secrets or API keys

Claude: [Searches for potential security issues]

You: Are there any SQL injection vulnerabilities?

Claude: [Analyzes query construction]

You: Show me JWT token validation logic

Claude: [Returns token validation code]
```

### Scenario 4: Migration Planning

**Task:** Migrate from REST to GraphQL

```
You: Find all REST API endpoints

Claude: [Lists all endpoints]

You: What data do these endpoints return?

Claude: [Analyzes response structures]

You: Create a GraphQL schema for these endpoints

Claude: [Generates GraphQL schema]

You: Implement resolvers based on existing endpoint logic

Claude: [Creates resolver implementations]
```

## Tips for Effective Searching

### Be Specific
❌ "Show me code"
✅ "Find authentication middleware functions"

### Use Domain Language
❌ "Find the thing that saves data"
✅ "Find database repository classes"

### Combine Concepts
✅ "Find async functions that handle file uploads and validate input"

### Ask Follow-ups
```
You: Find user registration code
Claude: [Returns registration]
You: Now show me where validation happens
Claude: [Returns validation]
You: What happens after successful registration?
Claude: [Traces the flow]
```

### Iterate Your Queries
```
You: Find error handlers
[Too many results]

You: Find error handlers in the API layer
[Better results]

You: Find error handlers in the API layer that send email notifications
[Specific results]
```

## Next Steps

- Experiment with different query patterns
- Index multiple projects and compare approaches
- Use the MCP for code reviews and onboarding
- Share effective queries with your team

## Resources

- [Usage Guide](./USAGE.md)
- [Configuration Options](./docs/CONFIGURATION.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)
