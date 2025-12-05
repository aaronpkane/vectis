 --COMPETENCY ENGINE DATABASE SCHEMA

 Schema |             Name              | Type  |    Owner
--------+-------------------------------+-------+--------------
 public | competencies                  | table | vectis_admin
 public | competency_recency_policies   | table | vectis_admin
 public | member_competency_assignments | table | vectis_admin
 public | org_units                     | table | vectis_admin
 public | recency_models                | table | vectis_admin
 public | role_profile_competencies     | table | vectis_admin
 public | role_profiles                 | table | vectis_admin
 public | tasks                         | table | vectis_admin
 public | user_org_memberships          | table | vectis_admin
 public | users                         | table | vectis_admin
 (10 rows)

CREATE TABLE competencies (
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_competencies_is_active ON competencies (is_active);

CREATE TABLE tasks (
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

CREATE TABLE role_profiles (
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE role_profile_competencies (
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

CREATE TABLE recency_models (
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

CREATE TABLE competency_recency_policies (
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

CREATE TABLE org_units (
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

CREATE TABLE users (
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

CREATE TABLE user_org_memberships (
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

CREATE TABLE member_competency_assignments (
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
