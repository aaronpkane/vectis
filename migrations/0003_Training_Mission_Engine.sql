--- TRAINING MISSIONS SCHEMA

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