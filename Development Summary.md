# VECTIS Development Summary

*A living design document for the development of VECTIS — the universal competency and compliance engine.*

*CONTACT: aaronpkane@yahoo.com*

---

## **Core Product Thesis (Locked)**

> **VECTIS gives organizations real-time clarity into true capability, while automatically enforcing all compliance requirements through a built-in, inspection-ready training framework.**

This system is not a task tracker. It is a capability computation engine.

---

# **Design Principles (Non-Negotiable)**

### **Neutral Terminology**

No domain-specific jargon in the underlying model.

### **Modular Competency Structure**

Competencies composed of tasks.

Reusable across domains.

### **Flexible Verification Logic**

Pass/fail, scored, and evidence-supported evaluations.

### **Configurable Roles & Permissions (RBAC placeholder)**

Roles attach to unit memberships, not users globally.

### **Exportable, Integration-Ready Data**

Clean API boundaries; ICS calendar support for MVP.

### **Universal Readiness & Compliance KPIs**

Compliance is always computed, never manually entered.

### **Compliance Logic = Competency Logic**

Recency and evaluation data determine compliance.

---

#Critical Cross-Engine Conventions

## **1. Naming Conventions**

To prevent schema drift:

- Use is_mandatory only inside a structural model
  Example: tasks within a competency; role_profile_competencies.

- Use is_required only for assignment/relationship logic
  Example: member_competency_assignments; mission members; event-task requirements.

- Use status for workflow/lifecycle states
  Example: missions, events, users.

- Use consistent timestamps:

`created_at`

`updated_at`

`started_at / ended_at`

`check_in_at / check_out_at`

*This consistency prevents ambiguity as engines expand.*

## **2. Foreign Key Philosophy**

VECTIS enforces strict referential integrity:

- Use `ON DELETE CASCADE` when dependent data should vanish with the parent (memberships, attendance, mission links).

- Use `ON DELETE SET NULL` only where historical context must survive loss of relationship.

- Never allow orphaned competencies, evaluations, mission records, or membership references.

*This prevents data corruption and keeps logic deterministic at scale.*

## **3. Domain-Layer-First Rule**

VECTIS is built in phases:

- Phase 1: Domain backbone (Competencies → Memberships → Missions → Evaluations)

- Phase 2: RBAC, API, Audit Logging, Separation Mechanics

- Phase 3: Compliance, Workflow, KPIs, Integrations

No API or RBAC work begins until all Phase 1 domain engines are stable.
*This avoids API redesign churn and ensures clean separation of concerns.*

---

# **The 8 Engines of VECTIS**

---

## **1. Competency Model Engine — v1 Complete**

### **Tables:**

- `competencies`

- `tasks`

- `recency_models`

- `competency_recency_policies`

- `role_profiles`

- `role_profile_competencies`


### **Key Behaviors:**

- Task ordering enforced via UNIQUE (competency_id, sequence_order).

- Task codes unique per competency via UNIQUE (competency_id, code).

- Recency rules decoupled from competency definition.

- Role profiles drive automatic assignment seeding for new members.

### **Status: Schema complete. No RBAC/API yet.**

---

## **2. Identity, Roles & Org Graph Engine — v1 Complete**

### **Tables:**

- `org_units`

- `users`

- `user_org_memberships`

- `member_competency_assignments`

- `role_profile_id added to memberships`


### **Key Principles:**

- Membership is a first-class record with date-bounded history.

- Assignments attach to memberships, not users.

- Supports transfers, separations, and accurate historical reporting.

- Role profile → membership → competency auto-assignment is fully defined.

### **Onboarding Flow (SQL Pattern):**

1. Insert user

2. Insert membership referencing org_unit + role_profile

3. Auto-seed competencies:

```sql
INSERT INTO member_competency_assignments (
membership_id,
competency_id,
source,
is_required,
assigned_by_user_id
)
SELECT
{membership_id},
rpc.competency_id,
'role_profile',
COALESCE(rpc.is_mandatory, TRUE),
{admin_user_id}
FROM role_profile_competencies rpc
WHERE rpc.role_profile_id = {role_profile_id}
ON CONFLICT (membership_id, competency_id) DO NOTHING;
```

#### **Status: Schema and logic complete. RBAC/API deferred.**

---

## **3. Compliance & Policy Engine — Pending**

Will compute:

- Compliance state (current / grace / expired)

- Recency-based enforcement

- Unit readiness and competency coverage metrics

- *Depends on Evaluations Engine.*

---

## **4. Evidence & Verification Engine — Pending**

Will store:

- Task evaluations (pass/fail/score)

- Evidence uploads

- Verification workflows

- Not yet implemented.

---

## **5. Readiness, KPIs & Analytics Engine — Pending**

Will provide:

- Unit capability snapshots

- Mission progress analytics

- Requirement coverage

- Inspection-ready reporting

- *Depends on Evaluations + Missions.*

---

## **6. Workflow & Events Engine — Pending**

Will handle:

- Recency expiration notifications

- Evaluation reminders

- Mission deadlines

- Event-driven notifications

- *Depends on Missions + Evaluations.*

---

## **7. Integration & Data Layer — Planned (MVP)**

Includes:

- ICS calendar sync using training_events

- Import/export utilities

- API-ready domain model boundaries

---

## **8. Training Mission Engine — In Progress**

### **Migration 0003_Training_Mission_Engine.sql will introduce:**

#### **Mission-Level Tables:**

`training_missions`

`training_mission_competencies`

`training_mission_members`

`training_mission_instructors`


#### **Event-Level Tables:**

`training_events`

`training_event_instructors`

`training_event_attendance`

`training_event_tasks`

#### **Purpose:**

- Missions represent structured, capability-driven training campaigns.

- Events deliver mission components.

- Attendance + event-task linkage → evaluations → compliance.

#### **Status: Schema drafted, not yet applied.**

---

## **Cross-Cutting Architecture (Deferred Until Phase 2)**

### **RBAC**

- Membership-scoped roles: System Admin, Unit Admin, Training Manager, Instructor, Member.

### **API Layer**

- REST endpoints for all major entities and workflows

- Permission enforcement via RBAC

- JWT authentication & refresh

### **Audit Logging**

- `audit_events` table

- API-driven logging for all writes

- Optional triggers for critical tables

### **Soft Separation**

- `users.status` (active/inactive/separated)

- Memberships close via ended_at

None implemented yet — intentionally deferred.

---

## **Migration Files**

### Current Migration Files:

- `0001_Competency_Engine.sql`

- `0002_Identity_Memberships_Engine.sql`

### Next Migration File:

- `0003_Training_Mission_Engine.sql`

Every new table or major alteration must be introduced via a new migration file.

---

## **Current State Snapshot**

### **Phase 1 — Domain Backbone**

- Competency Engine: COMPLETE

- Identity & Membership Engine: COMPLETE

- Training Mission Engine: IN PROGRESS

### **Phase 2 — Architecture**

- RBAC: pending

- API: pending

- Audit Logging: pending

- Separation Mechanics: pending

### **Phase 3 — Compliance, Workflow, Analytics**

- Evaluations: pending

- Compliance Engine: pending

- Workflow Engine: pending

- KPI/Readiness Engine: pending

---

## **Next Action**

- Create migration `0003_Training_Mission_Engine.sql` and implement all mission/event tables.

Once applied, we'll define the Training Mission Engine’s core flows:

- Create mission → assign competencies → enroll members

- Create event → map tasks → auto-enroll attendance

This will complete Training Mission Engine v1.

