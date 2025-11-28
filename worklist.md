### Phase 0 — Finalize MVP Scope (1–2 weeks)

Lock:

[X] MVP users

- *System Admin (MVP, minimal)*

*Manages baseline competency catalog*

*Creates the unit and seeds admin users*

*Not involved in daily workflows*

 *(You are the System Admin during MVP.)*

- *Unit Admin*

*Manages members*

*Assigns positions*

*Assigns RoleProfiles*

*Manages instructors*

*Oversight but does not create missions or evaluations*

- *Training Manager*

*Plans and runs all training*

*Builds missions/events*

*Approves evaluations*

*Runs readiness/compliance reports*

*Manages mission schedules*

*Can add/remove competencies for a member’s duty assignment*

- *Instructor*

*Conducts training*

*Marks attendance*

*Submits evaluations/evidence*

*Views their own missions*

*Views training assignments*

- *Member*

*Sees their training, events, qualification status*

*Receives notifications*

*Has no editing permissions*

[X] MVP capabilities

*Robust backend architecture with logging, migrations, auditing, transactions, and isolated modules.*

*Full RBAC security*

*Role hierarchy + context-aware permissions (unit-scoped access).*

*Enforcement at API + UI levels*

*Define competencies, tasks, task ordering, proficiency levels, and recency requirements.*

*Build missions*

*Auto-generate evaluation tasks per event.*

*Ability to attach evidence.*

*Attendance tracking (complete / incomplete / no-show).*

*Instructor assignment rules*

*Run events*

*Log evaluations*

*Produce compliance & readiness reports*

*Expiring competencies*

*Out-of-compliance individuals*

*Role coverage index*

*Unit readiness score*

*Mission progress*

*Add members*

*Assign roles/competencies to members (Training Manager)*

*A member can only be assigned roles tied to their unit.*

*Admin must not assign competencies manually (system derives them).*

*Assign roles/competencies to units (Administrators)*

*Analytics dashboard to visualize readiness*

*Sync training events/missions with member Outlook/Teams calendar*

*ICS email attachments*


[X] Non-goals

*No complex integration beyond Outlook/Teams calendar sync*

*No modular dashboard (what we set is the view users will have)8

*No mobile app in MVP*

*No full competency editor with drag-and-drop*

*No curriculum builder beyond missions and events.*

*No multi-org structure*

*No instructor certification engine*

[] UX flows

[] Validation criteria

---

### Phase 1 — Architecture + Backend Base (3–4 weeks)

[] Framework setup

[] RBAC skeleton

[] DB connection, migrations

[] Logging + error handling

[] Unit/integration test harness

---

### Phase 2 — Competency Engine (3–4 weeks)

[] DB schema

[] CRUD

[] RoleProfiles

[] Required competencies & tasks

[] Recency model foundation

---

### Phase 3 — Identity & Org Engine (2–3 weeks)

[] Users

[] Positions

[] Org units

[] Assignment logic

---

### Phase 4 — Training Missions Engine (4–6 weeks)

[] Mission planner

[] Event generator

[] Participants + instructors

[] Event timeline view

[] Mission launch logic

[] Calendar sync (MVP level)

---

### Phase 5 — Evaluations + Evidence (4–5 weeks)

[] Evaluation forms

[] Evidence uploads

[] Digital signatures

[] Verification flow

[] Progress-tracking logic

---

### Phase 6 — Compliance Engine (3–5 weeks)

[] Expiration logic

[] Compliance status

[] Inspection views

[] Compliance KPIs

---

### Phase 7 — Readiness Dashboards (2–4 weeks)

[] Individual readiness

[] Role coverage

[] Mission status

[] Expirations

[] Unit-level readiness

---

### Phase 8 — Workflow Engine (3–4 weeks)

[] Expiration notifications

[] Evaluation reminders

[] Mission progress alerts

---

### Phase 9 — UI/UX Buildout (4–6 weeks)

[] TM dashboards

[] Instructor mobile workflows

[] Unit/role views

[] Evaluation forms

[] Mission planner

---

### Phase 10 — QA, Hardening, & Deployment (3–6 weeks)

[] Bug fixes

[] Stress testing

[] Audit trails

[] Staging → prod

[] Initial pilot onboarding
