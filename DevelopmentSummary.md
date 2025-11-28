# **VECTIS Development Summary**

*A living design document for the development of VECTIS — the universal competency and compliance engine.*

---

## **Core Product Thesis (Locked)**

> **VECTIS gives organizations real-time clarity into true capability, while automatically enforcing all compliance requirements through a built-in, inspection-ready training framework.**

This thesis governs every architectural and design decision.

---

# **Design Principles (Non-Negotiable)**

VECTIS must adhere to the following constraints across all engines and workflows:

### **1. Neutral Terminology**

No baked-in military, corporate, or educational jargon.

### **2. Modular Competency Frameworks**

Competencies composed of tasks/subtasks, reusable across domains.

### **3. Flexible Verification Rules**

Evaluations may be scored, pass/fail, rubric-based, or evidence-based.

### **4. Configurable Roles & Permissions**

Organizations define their own hierarchy and authority chains.

### **5. Pluggable Evaluation Criteria**

Evaluation structures attach to tasks, competencies, or training events.

### **6. Exportable, Integration-Ready Data Models**

Structured for API export, BI tools, HRIS/LMS integration, and calendar sync.

### **7. Universal KPIs**

Readiness, capability, recency, throughput — useful across all industries.

### **8. Compliance Logic = Competency Logic**

Compliance is a first-class rule engine, not a reporting layer.

---

# **The 8 Engines of VECTIS**

These engines represent the core logical subsystems of the platform.

---

## **1. Competency Model Engine**

Defines all capability structures.

**Elements:**

* Competency
* Task / Subtask
* ProficiencyLevel
* Prerequisites & dependency chains
* Recency models (time-sensitive mastery requirements)
* RoleProfiles (bundles of required competencies)

---

## **2. Compliance & Policy Engine**

Responsible for rules governing compliance.

**Elements:**

* ComplianceRule
* PolicyCycle
* Expiration windows
* Renewal requirements
* Audit logs
* ProgramStatus

---

##**
*A living design document for the development of VECTIS — the universal competency and compliance engine.*

---

## **Core Product Thesis (Locked)**

> **VECTIS gives organizations real-time clarity into true capability, while automatically enforcing all compliance requirements through a built-in, inspection-ready training framework.**

This thesis governs every architectural and design decision.

---

# **Design Principles (Non‑Negotiable)**

VECTIS must adhere to the following constraints across all engines and workflows:

### **1. Neutral Terminology**

No baked-in military, corporate, or educational jargon.

### **2. Modular Competency Frameworks**

Competencies composed of tasks/subtasks, reusable across domains.

### **3. Flexible Verification Rules**

Evaluations may be scored, pass/fail, rubric-based, or evidence-based.

### **4. Configurable Roles & Permissions**

Organizations define their own hierarchy and authority chains.

### **5. Pluggable Evaluation Criteria**

Evaluation structures attach to tasks, competencies, or training events.

### **6. Exportable, Integration-Ready Data Models**

Structured for API export, BI tools, HRIS/LMS integration, and calendar sync.

### **7. Universal KPIs**

Readiness, capability, recency, throughput — useful across all industries.

### **8. Compliance Logic = Competency Logic**

Compliance is a first-class rule engine, not a reporting layer.

---

# **The 8 Engines of VECTIS**

These engines represent the core logical subsystems of the platform.

---

## **1. Competency Model Engine**

Defines all capability structures.

**Elements:**

* Competency
* Task / Subtask
* ProficiencyLevel
* Prerequisites & dependency chains
* Recency models (time-sensitive mastery requirements)
* RoleProfiles (bundles of required competencies)

This engine defines *what it means* to be qualified.

---

## **2. Compliance & Policy Engine**

Responsible for rules governing compliance.

**Elements:**

* ComplianceRule
* PolicyCycle
* Expiration windows
* Renewal requirements
* Audit logs
* ProgramStatus (unit / org-level compliance health)

Compliance is automatically derived from competency progress.

---

## **3. Identity, Roles & Org Graph Engine**

Defines the human and organizational structure.

**Elements:**

* User
* OrgUnit
* Position
* PermissionSet
* AssignedRoleProfile

Supports any hierarchical structure (military, corporate, educational).

---

## **4. Evidence & Verification Engine**

The trust layer.

**Elements:**

* EvaluationEvent
* Evidence (files, photos, signatures, notes)
* VerificationStep
* Verifier
* Digital attestation
* Re-verification triggers

Ensures that qualification is defendable under inspection.

---

## **5. Readiness, KPIs & Analytics Engine**

Transforms raw capability data into actionable insight.

**KPIs Include:**

* Individual readiness
* Role coverage
* Recency decay
* Time-to-qualify
* Evaluation throughput
* Compliance risk

Real-time dashboards for leadership.

---

## **6. Workflow & Events Engine**

Automation and task orchestration.

**Elements:**

* Trigger (time, event, rule-based)
* WorkflowRule
* Task
* Notification
* Escalation

Reduces human error by managing evaluations, renewals, and required actions.

---

## **7. Integration & Data Layer**

Ensures interoperability and external system support.

**Elements:**

* ImportMapping
* Export templates
* Calendar sync adapters (Outlook, Google)
* LMS/HRIS connectors
* Data warehouse export
* ModelVersioning

Designed for enterprise-grade extensibility.

---

## **8. Training Mission Engine (New)**

A structured training campaign system.

A **Training Mission** is a multi-event, multi-week planned qualification effort.

### **Training Mission Structure**

* mission_id
* competency_id or role_profile_id
* title, description
* start/end dates
* instructors
* participants
* event_list
* mission_status (planned → launched → in-progress → completed)
* auto-calendar-sync flag

### **Training Event Structure**

* event_id
* mission_id
* task_id(s)
* instructor
* participants
* start/end time
* location
* evaluation_required?
* evidence_required?
* event_status

### **Evaluation Record Structure**

* evaluation_id
* event_id
* participant_id
* task_id
* outcome (pass/fail/score)
* evidence attachments
* verifier + signature
* verification_status

### **Key Behaviors**

* A TM can create a mission for a competency.
* VECTIS generates all related Training Events.
* Participants and instructors receive notifications.
* Events sync externally but are not “calendar logic.”
* After each event, attendance & evaluation update competency and compliance.

The Training Mission Engine is a central differentiator and now part of the core system.

---

# **Daily Workflow: Training Manager Perspective**

A Training Manager (TM) with 160 personnel uses VECTIS as follows:

### **1. Log in → Unit Readiness Dashboard**

Shows:

* Capability gaps
* Compliance risk
* Expiring competencies
* Pending evaluations
* Mission progress
* Role coverage deficits

### **2. Handle Critical Items**

* Renewals
* Expirations
* Required evaluations
* Instructor assignments

### **3. Launch or Manage Training Missions**

* Build mission (tasks → events → participants)
* Launch
* Calendar sync
* Auto-generated evaluation tasks

### **4. Process Evaluations**

* Review instructor submissions
* Verify evidence
* Approve or reject
* Competency & compliance update automatically

### **5. Generate Readiness / Inspection Reports**

* Full compliance breakdown
* Role coverage
* Expiring quals
* Missing evidence

### **End State**

TM never manipulates raw data; VECTIS enforces accuracy by design.

---

# **Status Tracker**

### **Completed**

* Core product thesis
* Design constraints
* Eight-engine architecture
* Daily operational workflow
* Training Mission Engine added

### **In Progress**

* Detailed engine specifications
* Competency Model Engine definition (next)

### **Next Step**

Define the **Competency Model Engine** at the field level:

* Competency
* Task
* ProficiencyLevel
* RequirementSet
* RoleProfile
* RecencyModel

This will anchor the rest of the architecture.

---

This document will continue to evolve as VECTIS takes shape.
