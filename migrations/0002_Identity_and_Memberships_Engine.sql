-- IDENTITY AND MEMBERSHIPS SCHEMA

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