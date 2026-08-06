# Enterprise Auto Garage Ecosystem -- Agentic Audit Prompt

> **Role**
>
> You are an autonomous enterprise software auditing system composed of:
>
> -   Enterprise Automotive Software Architect
> -   Principal Flutter Engineer
> -   Senior Java Spring Boot Architect
> -   Database Architect
> -   DevOps Engineer
> -   Security Engineer
> -   Product Manager
> -   UI/UX Director
> -   QA Automation Lead
> -   Performance Engineer
> -   Business Analyst
> -   Investor & Technical Due Diligence Reviewer
>
> Your mission is to perform an exhaustive audit of the complete Auto
> Garage platform.

------------------------------------------------------------------------

# Project Context

## Applications

1.  Customer App (Flutter)
2.  Staff App (Flutter)
    -   Service Advisor
    -   Workshop Supervisor
    -   Technician
3.  Owner App (Flutter)

## Backend

-   Java
-   Spring Boot
-   REST APIs

## Goal

Audit the entire system as if it is about to launch as an enterprise
SaaS platform competing with Tekmetric, Shopmonkey, AutoLeap, GaragePlug
and similar workshop management systems.

Do **not** stop at code quality.

Evaluate:

-   Business logic
-   Architecture
-   User experience
-   Security
-   Scalability
-   Enterprise readiness
-   Production readiness
-   Investor readiness

------------------------------------------------------------------------

# Audit Rules

-   Review every folder.
-   Review every file.
-   Review every package.
-   Review every class.
-   Review every method.
-   Review every screen.
-   Review every API.
-   Review every database entity.
-   Review every workflow.
-   Never assume anything is correct.
-   Explain every finding.
-   Suggest improvements with implementation ideas.
-   Assign:
    -   Severity (Critical / High / Medium / Low)
    -   Business Impact
    -   Technical Impact
    -   Complexity
    -   Priority (P0--P3)

------------------------------------------------------------------------

# 1. Architecture Audit

Evaluate:

-   Folder structure
-   Package structure
-   Feature-first organization
-   Clean Architecture
-   SOLID
-   DRY
-   KISS
-   Dependency inversion
-   Shared components
-   Design system
-   Configuration management
-   Environment management
-   Error handling
-   Offline readiness
-   Feature flags
-   Logging
-   Analytics
-   Crash reporting
-   Scalability
-   Maintainability

Provide a score out of 100.

------------------------------------------------------------------------

# 2. Flutter Frontend Audit

Inspect every application.

Evaluate:

-   Navigation
-   Routing
-   Provider architecture
-   Widget hierarchy
-   State management
-   Rebuild performance
-   Memory leaks
-   Responsiveness
-   Theme consistency
-   Material 3 usage
-   Typography
-   Spacing
-   Accessibility
-   Skeleton loaders
-   Empty states
-   Error states
-   Offline behavior
-   Animations
-   Micro interactions
-   Form validation
-   Search
-   Filters
-   Pagination
-   Image caching
-   Component reuse
-   Naming
-   Folder structure
-   UI consistency
-   2026 design quality

For every screen identify:

-   Missing UX
-   Missing loading states
-   Missing validations
-   Visual inconsistencies
-   Opportunities for reusable widgets

------------------------------------------------------------------------

# 3. Java Spring Boot Backend Audit

Review:

## Architecture

-   Package structure
-   Controllers
-   Services
-   Repositories
-   DTOs
-   Entities
-   MapStruct
-   Utility classes
-   Dependency Injection
-   Configuration
-   Profiles

## APIs

-   REST design
-   Naming
-   Pagination
-   Filtering
-   Sorting
-   Status codes
-   Response wrappers
-   Error responses
-   Versioning
-   Swagger/OpenAPI

## Security

-   Spring Security
-   JWT
-   RBAC
-   Permissions
-   Refresh tokens
-   Password encryption
-   CORS
-   CSRF
-   Rate limiting

## Persistence

-   Hibernate
-   JPA
-   Entity relationships
-   Lazy/Eager loading
-   Transactions
-   Locking
-   Query optimization
-   N+1 detection
-   Index recommendations

## Production

-   Docker
-   Kubernetes readiness
-   Actuator
-   Micrometer
-   Health checks
-   Structured logging
-   Monitoring
-   Secrets management

## Testing

-   Unit tests
-   Integration tests
-   MockMvc
-   Testcontainers
-   Coverage

------------------------------------------------------------------------

# 4. Database Audit

Evaluate:

-   Normalization
-   Keys
-   Constraints
-   Indexes
-   Soft delete
-   Audit logs
-   Activity history
-   Vehicle history
-   Service history
-   Invoice history
-   Payment history
-   Warranty
-   Inventory
-   Supplier management
-   Branch support
-   Multi-tenancy readiness

Suggest missing tables and relationships.

------------------------------------------------------------------------

# 5. Workflow Audit

Validate the complete lifecycle:

Customer

↓

Booking

↓

Advisor

↓

Inspection

↓

Estimate

↓

Supervisor

↓

Technician Assignment

↓

Repair

↓

Quality Check

↓

Invoice

↓

Payment

↓

Delivery

↓

Feedback

↓

Owner Dashboard

For each stage identify:

-   Creator
-   Editor
-   Approver
-   Viewer
-   Notifications
-   Escalations
-   Rollback
-   Reopen conditions
-   Edge cases

Generate Mermaid diagrams.

------------------------------------------------------------------------

# 6. Role Connection Matrix

Audit communication among:

-   Customer
-   Advisor
-   Supervisor
-   Technician
-   Owner

Review:

-   Permissions
-   Visibility
-   Internal notes
-   Mentions
-   Attachments
-   Photos
-   Videos
-   Voice notes
-   Timeline
-   Audit history
-   Notifications
-   Escalations

Generate a complete role interaction matrix.

------------------------------------------------------------------------

# 7. Customer Experience

Evaluate:

-   Authentication
-   OTP
-   Vehicle onboarding
-   Booking
-   Live tracking
-   Estimate approval
-   Notifications
-   Invoice
-   Payments
-   Ratings
-   Service reminders
-   Warranty
-   Loyalty
-   Referrals

List missing enterprise features.

------------------------------------------------------------------------

# 8. Staff Experience

Evaluate each role separately.

Service Advisor

Workshop Supervisor

Technician

Review:

-   Dashboard
-   Queue
-   Assignments
-   Inspections
-   Checklists
-   Parts
-   Attachments
-   Time tracking
-   Productivity
-   Communication
-   KPIs

------------------------------------------------------------------------

# 9. Owner Experience

Evaluate:

-   Revenue
-   Profitability
-   Inventory
-   Employee KPIs
-   Workshop utilization
-   Customer retention
-   Branch comparison
-   CRM
-   Reports
-   Forecasting
-   Business intelligence

------------------------------------------------------------------------

# 10. Security Audit

Review:

-   Authentication
-   Authorization
-   Secrets
-   Encryption
-   HTTPS
-   SQL Injection
-   XSS
-   CSRF
-   File uploads
-   JWT lifecycle
-   Session management
-   Audit logs

------------------------------------------------------------------------

# 11. Performance Audit

Frontend:

-   Startup
-   FPS
-   Widget rebuilds
-   Memory
-   Battery

Backend:

-   API latency
-   Thread pools
-   Slow queries
-   Cache opportunities

Database:

-   Indexes
-   Locks
-   Query plans

------------------------------------------------------------------------

# 12. DevOps Audit

Review:

-   Git workflow
-   CI/CD
-   Docker
-   Deployment
-   Monitoring
-   Logging
-   Backups
-   Disaster recovery
-   Environment separation

------------------------------------------------------------------------

# 13. QA Audit

Evaluate:

-   Unit tests
-   Widget tests
-   Integration tests
-   API tests
-   E2E
-   Regression
-   Performance
-   Security
-   Chaos testing

------------------------------------------------------------------------

# 14. Competitor Gap Analysis

Compare against:

-   Tekmetric
-   Shopmonkey
-   AutoLeap
-   GaragePlug
-   AutoFluent

Identify missing enterprise capabilities.

------------------------------------------------------------------------

# 15. Production Readiness

Provide scores (0--100):

-   Architecture
-   Frontend
-   Backend
-   Database
-   APIs
-   Security
-   Performance
-   DevOps
-   QA
-   Workflow
-   Role Management
-   Inventory
-   CRM
-   Reporting
-   Scalability
-   Maintainability
-   Enterprise Readiness
-   Investor Readiness
-   Overall

------------------------------------------------------------------------

# Final Deliverables

Produce:

1.  Executive Summary
2.  Architecture Report
3.  Flutter Report
4.  Java Backend Report
5.  Database Report
6.  API Report
7.  Customer Workflow Report
8.  Staff Workflow Report
9.  Owner Workflow Report
10. Role Matrix
11. Mermaid Workflow Diagrams
12. Missing Features Catalogue
13. UI/UX Improvements
14. Security Report
15. Performance Report
16. DevOps Report
17. QA Report
18. Competitor Comparison
19. Enterprise Scorecard
20. Production Readiness Report
21. Investor Due Diligence Report
22. Prioritized Backlog (P0--P3)
23. 30-Day Plan
24. 90-Day Roadmap
25. Final Launch Recommendation

Continue across multiple volumes if the repository exceeds the available
context window. Preserve cross-references and maintain cumulative
findings.
