-- COMPETENCY ENGINE SCHEMA

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