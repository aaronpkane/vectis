 -- LIST OF RELATIONS
 
 Schema |                 Name                 |   Type   |    Owner
--------+--------------------------------------+----------+--------------
 public | competencies                         | table    | vectis_admin
 public | competencies_id_seq                  | sequence | vectis_admin
 public | competency_recency_policies          | table    | vectis_admin
 public | competency_recency_policies_id_seq   | sequence | vectis_admin
 public | member_competency_assignments        | table    | vectis_admin
 public | member_competency_assignments_id_seq | sequence | vectis_admin
 public | org_units                            | table    | vectis_admin
 public | org_units_id_seq                     | sequence | vectis_admin
 public | recency_models                       | table    | vectis_admin
 public | recency_models_id_seq                | sequence | vectis_admin
 public | role_profile_competencies            | table    | vectis_admin
 public | role_profile_competencies_id_seq     | sequence | vectis_admin
 public | role_profiles                        | table    | vectis_admin
 public | role_profiles_id_seq                 | sequence | vectis_admin
 public | tasks                                | table    | vectis_admin
 public | tasks_id_seq                         | sequence | vectis_admin
 public | training_event_attendance            | table    | vectis_admin
 public | training_event_attendance_id_seq     | sequence | vectis_admin
 public | training_event_instructors           | table    | vectis_admin
 public | training_event_instructors_id_seq    | sequence | vectis_admin
 public | training_event_tasks                 | table    | vectis_admin
 public | training_event_tasks_id_seq          | sequence | vectis_admin
 public | training_events                      | table    | vectis_admin
 public | training_events_id_seq               | sequence | vectis_admin
 public | training_mission_competencies        | table    | vectis_admin
 public | training_mission_competencies_id_seq | sequence | vectis_admin
 public | training_mission_instructors         | table    | vectis_admin
 public | training_mission_instructors_id_seq  | sequence | vectis_admin
 public | training_mission_members             | table    | vectis_admin
 public | training_mission_members_id_seq      | sequence | vectis_admin
 public | training_missions                    | table    | vectis_admin
 public | training_missions_id_seq             | sequence | vectis_admin
 public | user_org_memberships                 | table    | vectis_admin
 public | user_org_memberships_id_seq          | sequence | vectis_admin
 public | users                                | table    | vectis_admin
 public | users_id_seq                         | sequence | vectis_admin
(36 rows)
 
 --COMPETENCY ENGINE DATABASE SCHEMA

CREATE TABLE competencies ( -- Master list of competencies
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_competencies_is_active ON competencies (is_active);

CREATE TABLE tasks ( -- Tasks associated with competencies
    id              BIGSERIAL PRIMARY KEY,
    competency_id   BIGINT NOT NULL REFERENCES competencies(id) ON DELETE CASCADE,
    code            VARCHAR(50) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    sequence_order  INTEGER NOT NULL DEFAULT 0,
    is_mandatory    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_tasks_competency_code UNIQUE (competency_id, code),
    CONSTRAINT uq_tasks_competency_sequence UNIQUE (competency_id, sequence_order)
);

CREATE INDEX idx_tasks_competency_id ON tasks (competency_id);

CREATE TABLE role_profiles ( -- Role profiles at organization
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE role_profile_competencies ( -- Competencies required for each role profile
    id                          BIGSERIAL PRIMARY KEY,
    role_profile_id             BIGINT NOT NULL REFERENCES role_profiles(id) ON DELETE CASCADE,
    competency_id               BIGINT NOT NULL REFERENCES competencies(id) ON DELETE RESTRICT,
    is_mandatory                BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_rpc_role_competency UNIQUE (role_profile_id, competency_id)
);

CREATE INDEX idx_rpc_role_profile_id ON role_profile_competencies (role_profile_id);
CREATE INDEX idx_rpc_competency_id ON role_profile_competencies (competency_id);

CREATE TABLE recency_models ( -- Models defining recency/frequency policies
    id                  BIGSERIAL PRIMARY KEY,
    code                VARCHAR(50) NOT NULL UNIQUE,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    valid_for_days      INTEGER,
    grace_period_days   INTEGER NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_recency_valid_for_days
        CHECK (valid_for_days IS NULL OR valid_for_days > 0),
    CONSTRAINT chk_recency_grace_period
        CHECK (grace_period_days >= 0)
);

CREATE TABLE competency_recency_policies ( -- Recency policies per competency
    id                      BIGSERIAL PRIMARY KEY,
    competency_id           BIGINT NOT NULL REFERENCES competencies(id) ON DELETE CASCADE,
    recency_model_id        BIGINT NOT NULL REFERENCES recency_models(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One policy per (competency, proficiency_level) pair
CREATE UNIQUE INDEX uq_crp_competency_level
    ON competency_recency_policies (competency_id);

-- Ensure only one \"default\" (no-level) policy per competency
CREATE UNIQUE INDEX uq_crp_competency_default
    ON competency_recency_policies (competency_id);

CREATE INDEX idx_crp_recency_model_id
    ON competency_recency_policies (recency_model_id);

-- IDENTITY AND MEMBERSHIP SCHEMA

CREATE TABLE org_units ( -- Organizational units (hierarchical)
    id              BIGSERIAL PRIMARY KEY,
    parent_id       BIGINT REFERENCES org_units(id) ON DELETE SET NULL,
    code            VARCHAR(50) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    unit_type       VARCHAR(50) NOT NULL, -- e.g. 'station', 'sector', 'department', etc.
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_org_units_code UNIQUE (code)
);

CREATE INDEX idx_org_units_parent_id ON org_units (parent_id);

CREATE TABLE users ( -- System users / members
    id              BIGSERIAL PRIMARY KEY,
    external_id     VARCHAR(100),          -- for future SSO / HR integration
    email           VARCHAR(255),
    service_number  VARCHAR(50),
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    status          VARCHAR(30) NOT NULL DEFAULT 'active', -- 'active', 'inactive', 'separated'
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_service_number UNIQUE (service_number)
);

CREATE TABLE user_org_memberships ( -- User memberships in org units
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    org_unit_id     BIGINT NOT NULL REFERENCES org_units(id) ON DELETE CASCADE,
    is_primary      BOOLEAN NOT NULL DEFAULT TRUE,
    started_at      DATE NOT NULL DEFAULT CURRENT_DATE,
    ended_at        DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Only one *active* membership per (user, org_unit)
CREATE UNIQUE INDEX uq_user_org_active_membership
    ON user_org_memberships (user_id, org_unit_id)
    WHERE ended_at IS NULL;

CREATE INDEX idx_user_org_memberships_user
    ON user_org_memberships (user_id);

CREATE INDEX idx_user_org_memberships_org
    ON user_org_memberships (org_unit_id);

CREATE TABLE member_competency_assignments ( -- Competency assignments to members
    id                  BIGSERIAL PRIMARY KEY,
    membership_id       BIGINT NOT NULL
                        REFERENCES user_org_memberships(id) ON DELETE CASCADE,
    competency_id       BIGINT NOT NULL
                        REFERENCES competencies(id) ON DELETE CASCADE,
    source              VARCHAR(30) NOT NULL,  -- 'role_profile', 'manual', 'import'
    is_required         BOOLEAN NOT NULL DEFAULT TRUE,
    status              VARCHAR(30) NOT NULL DEFAULT 'assigned', -- 'assigned','waived','archived'
    assigned_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_by_user_id BIGINT REFERENCES users(id),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_membership_competency UNIQUE (membership_id, competency_id)
);

CREATE INDEX idx_member_comp_assign_membership
    ON member_competency_assignments (membership_id);

CREATE INDEX idx_member_comp_assign_competency
    ON member_competency_assignments (competency_id);

BEGIN;

-- Use this to create a sample user and assign role profile competencies automatically
INSERT INTO users (first_name, last_name, email, service_number)
VALUES ('Jane', 'Doe', 'jane.doe@example.com', 'SN-1234')
RETURNING id;

INSERT INTO user_org_memberships (user_id, org_unit_id, role_profile_id, is_primary, started_at)
VALUES (10, 1, 2, TRUE, CURRENT_DATE)
RETURNING id;

INSERT INTO member_competency_assignments (
    membership_id,
    competency_id,
    source,
    is_required,
    assigned_by_user_id
)
SELECT
    25 AS membership_id,
    rpc.competency_id,
    'role_profile' AS source,
    COALESCE(rpc.is_required, TRUE) AS is_required,
    1 AS assigned_by_user_id
FROM role_profile_competencies rpc
WHERE rpc.role_profile_id = 2
ON CONFLICT (membership_id, competency_id) DO NOTHING;

COMMIT;

-- Training Missions Engine DATABASE SCHEMA

CREATE TABLE training_missions ( -- Training missions assigned to org units
    id                  BIGSERIAL PRIMARY KEY,
    org_unit_id         BIGINT NOT NULL
                        REFERENCES org_units(id) ON DELETE CASCADE,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    status              VARCHAR(30) NOT NULL DEFAULT 'planned',
    -- 'planned', 'active', 'completed', 'cancelled'

    start_date          DATE,
    end_date            DATE,

    created_by_user_id  BIGINT REFERENCES users(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_training_missions_org_unit 
    ON training_missions (org_unit_id);

CREATE INDEX idx_training_missions_status
    ON training_missions (status);

CREATE TABLE training_mission_competencies ( -- Competencies targetted by each training mission
    id              BIGSERIAL PRIMARY KEY,
    mission_id      BIGINT NOT NULL
                    REFERENCES training_missions(id) ON DELETE CASCADE,
    competency_id   BIGINT NOT NULL
                    REFERENCES competencies(id) ON DELETE CASCADE,
    is_primary      BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT uq_mission_competency
        UNIQUE (mission_id, competency_id)
);

CREATE INDEX idx_tm_competencies_mission
    ON training_mission_competencies (mission_id);

CREATE INDEX idx_tm_competencies_competency
    ON training_mission_competencies (competency_id);

CREATE TABLE training_mission_members ( -- Members enrolled in training missions
    id                  BIGSERIAL PRIMARY KEY,
    mission_id          BIGINT NOT NULL
                        REFERENCES training_missions(id) ON DELETE CASCADE,
    membership_id       BIGINT NOT NULL
                        REFERENCES user_org_memberships(id) ON DELETE CASCADE,

    source              VARCHAR(30) NOT NULL DEFAULT 'manual',
    -- 'role_profile', 'manual', 'import'

    is_required         BOOLEAN NOT NULL DEFAULT TRUE,
    status              VARCHAR(30) NOT NULL DEFAULT 'enrolled',
    -- 'invited', 'enrolled', 'completed', 'dropped'

    enrolled_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,

    CONSTRAINT uq_mission_membership
        UNIQUE (mission_id, membership_id)
);

CREATE INDEX idx_tm_members_mission
    ON training_mission_members (mission_id);

CREATE INDEX idx_tm_members_membership
    ON training_mission_members (membership_id);

CREATE TABLE training_mission_instructors ( -- Instructors assigned to training missions
    id                  BIGSERIAL PRIMARY KEY,
    mission_id          BIGINT NOT NULL
                        REFERENCES training_missions(id) ON DELETE CASCADE,
    membership_id       BIGINT NOT NULL
                        REFERENCES user_org_memberships(id) ON DELETE CASCADE,
    role                VARCHAR(50) NOT NULL DEFAULT 'instructor',
    -- 'lead', 'assistant', 'observer', etc.

    CONSTRAINT uq_mission_instructor
        UNIQUE (mission_id, membership_id)
);

CREATE INDEX idx_tm_instructors_mission
    ON training_mission_instructors (mission_id);

CREATE INDEX idx_tm_instructors_membership
    ON training_mission_instructors (membership_id);

CREATE TABLE training_events ( -- Scheduled training events for missions
    id                  BIGSERIAL PRIMARY KEY,
    mission_id          BIGINT NOT NULL
                        REFERENCES training_missions(id) ON DELETE CASCADE,
    org_unit_id         BIGINT NOT NULL
                        REFERENCES org_units(id) ON DELETE CASCADE,

    title               VARCHAR(255) NOT NULL,
    description         TEXT,
    location            VARCHAR(255),

    starts_at           TIMESTAMPTZ NOT NULL,
    ends_at             TIMESTAMPTZ NOT NULL,

    status              VARCHAR(30) NOT NULL DEFAULT 'scheduled',
    -- 'scheduled', 'in_progress', 'completed', 'cancelled'

    max_participants    INTEGER,
    created_by_user_id  BIGINT REFERENCES users(id),

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_training_events_mission
    ON training_events (mission_id);

CREATE INDEX idx_training_events_org_unit
    ON training_events (org_unit_id);

CREATE INDEX idx_training_events_starts_at
    ON training_events (starts_at);

CREATE TABLE training_event_instructors ( -- Instructors assigned to training events
    id                  BIGSERIAL PRIMARY KEY,
    event_id            BIGINT NOT NULL
                        REFERENCES training_events(id) ON DELETE CASCADE,
    membership_id       BIGINT NOT NULL
                        REFERENCES user_org_memberships(id) ON DELETE CASCADE,
    role                VARCHAR(50) NOT NULL DEFAULT 'instructor',
    -- 'lead', 'assistant', etc.

    CONSTRAINT uq_event_instructor
        UNIQUE (event_id, membership_id)
);

CREATE INDEX idx_te_instructors_event
    ON training_event_instructors (event_id);

CREATE INDEX idx_te_instructors_membership
    ON training_event_instructors (membership_id);

CREATE TABLE training_event_attendance ( -- Attendance records for training events
    id                  BIGSERIAL PRIMARY KEY,
    event_id            BIGINT NOT NULL
                        REFERENCES training_events(id) ON DELETE CASCADE,
    membership_id       BIGINT NOT NULL
                        REFERENCES user_org_memberships(id) ON DELETE CASCADE,

    attendance_status   VARCHAR(30) NOT NULL DEFAULT 'invited',
    -- 'invited', 'confirmed', 'attended', 'no_show', 'excused', 'cancelled'

    check_in_at         TIMESTAMPTZ,
    check_out_at        TIMESTAMPTZ,

    CONSTRAINT uq_event_attendance
        UNIQUE (event_id, membership_id)
);

CREATE INDEX idx_te_attendance_event
    ON training_event_attendance (event_id);

CREATE INDEX idx_te_attendance_membership
    ON training_event_attendance (membership_id);

CREATE TABLE training_event_tasks ( -- Tasks covered in each training event
    id                  BIGSERIAL PRIMARY KEY,
    event_id            BIGINT NOT NULL
                        REFERENCES training_events(id) ON DELETE CASCADE,
    task_id             BIGINT NOT NULL
                        REFERENCES tasks(id) ON DELETE CASCADE,

    is_required         BOOLEAN NOT NULL DEFAULT TRUE,
    evaluation_required BOOLEAN NOT NULL DEFAULT TRUE,
    -- if FALSE, it’s more of a practice/demo linkage

    CONSTRAINT uq_event_task
        UNIQUE (event_id, task_id)
);

CREATE INDEX idx_te_tasks_event
    ON training_event_tasks (event_id);

CREATE INDEX idx_te_tasks_task
    ON training_event_tasks (task_id);
