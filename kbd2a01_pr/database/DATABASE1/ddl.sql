SET SQLBLANKLINES ON
CREATE TABLE PROJECTS 
(
  PROJECT_ID NUMBER(6, 0) GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 START WITH 1 MINVALUE 1 NOT NULL 
, NAME VARCHAR2(64) NOT NULL 
, CONSTRAINT PROJ_PK PRIMARY KEY 
  (
    PROJECT_ID 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX IDX_PROJ_PK ON PROJECTS (PROJECT_ID ASC) 
  )
  ENABLE 
);

CREATE TABLE STATES 
(
  STATE_CODE VARCHAR2(3) NOT NULL 
, NAME VARCHAR2(64) NOT NULL 
, CONSTRAINT STATE_PK PRIMARY KEY 
  (
    STATE_CODE 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX IDX_STATE_PK ON STATES (STATE_CODE ASC) 
  )
  ENABLE 
);

CREATE TABLE STATES_IN_PROJECTS 
(
  PROJECT_ID NUMBER(6, 0) NOT NULL 
, STATE_CODE VARCHAR2(3) NOT NULL 
);

CREATE TABLE TASKS 
(
  PROJECT_ID NUMBER(6, 0) NOT NULL 
, TASK_NO NUMBER(6, 0) NOT NULL 
, STATE_CODE VARCHAR2(3) 
, NAME VARCHAR2(64) NOT NULL 
, DESCRIPTION VARCHAR2(2048) 
, HOURS_SPENT NUMBER(6, 2) 
, HOURS_PREDICTED NUMBER(6, 2) 
, PERCENT_DONE NUMBER(3, 0) DEFAULT 0 NOT NULL 
, CREATED_DATE DATE DEFAULT SYSDATE NOT NULL 
, CONSTRAINT TASK_PK PRIMARY KEY 
  (
    PROJECT_ID 
  , TASK_NO 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX IDX_TASK_PK ON TASKS (PROJECT_ID ASC, TASK_NO ASC) 
  )
  ENABLE 
);

CREATE TABLE TASKS_PREDECESSORS 
(
  PROJECT_ID NUMBER(6, 0) NOT NULL 
, TASK_NO NUMBER(6, 0) NOT NULL 
, PREV_TASK_NO NUMBER(6, 0) NOT NULL 
, CONSTRAINT TP_PK PRIMARY KEY 
  (
    PROJECT_ID 
  , TASK_NO 
  , PREV_TASK_NO 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX IDX_TP_PK ON TASKS_PREDECESSORS (PROJECT_ID ASC, TASK_NO ASC, PREV_TASK_NO ASC) 
  )
  ENABLE 
);

CREATE UNIQUE INDEX IDX_SIP_PK ON STATES_IN_PROJECTS (STATE_CODE ASC, PROJECT_ID ASC);

CREATE INDEX IDX_SIP_PROJ_FK ON STATES_IN_PROJECTS (PROJECT_ID ASC);

CREATE INDEX IDX_TASK_SIP_FK ON TASKS (STATE_CODE ASC, PROJECT_ID ASC);

CREATE INDEX IDX_TP_PREV_TASK_FK ON TASKS_PREDECESSORS (PROJECT_ID ASC, PREV_TASK_NO ASC);

ALTER TABLE STATES_IN_PROJECTS
ADD CONSTRAINT SIP_PK PRIMARY KEY 
(
  STATE_CODE 
, PROJECT_ID 
)
USING INDEX IDX_SIP_PK
ENABLE;

ALTER TABLE STATES_IN_PROJECTS
ADD CONSTRAINT SIP_PROJ_FK FOREIGN KEY
(
  PROJECT_ID 
)
REFERENCES PROJECTS
(
  PROJECT_ID 
)
ENABLE;

ALTER TABLE STATES_IN_PROJECTS
ADD CONSTRAINT SIP_STATE_FK FOREIGN KEY
(
  STATE_CODE 
)
REFERENCES STATES
(
  STATE_CODE 
)
ENABLE;

ALTER TABLE TASKS
ADD CONSTRAINT TASK_PROJ_FK FOREIGN KEY
(
  PROJECT_ID 
)
REFERENCES PROJECTS
(
  PROJECT_ID 
)
ENABLE;

ALTER TABLE TASKS
ADD CONSTRAINT TASK_SIP_FK FOREIGN KEY
(
  STATE_CODE 
, PROJECT_ID 
)
REFERENCES STATES_IN_PROJECTS
(
  STATE_CODE 
, PROJECT_ID 
)
ENABLE;

ALTER TABLE TASKS
ADD CONSTRAINT TASK_STATE_FK FOREIGN KEY
(
  STATE_CODE 
)
REFERENCES STATES
(
  STATE_CODE 
)
ENABLE;

ALTER TABLE TASKS_PREDECESSORS
ADD CONSTRAINT TP_PREV_TASK_FK FOREIGN KEY
(
  PROJECT_ID 
, PREV_TASK_NO 
)
REFERENCES TASKS
(
  PROJECT_ID 
, TASK_NO 
)
ENABLE;

ALTER TABLE TASKS_PREDECESSORS
ADD CONSTRAINT TP_TASK_FK FOREIGN KEY
(
  PROJECT_ID 
, TASK_NO 
)
REFERENCES TASKS
(
  PROJECT_ID 
, TASK_NO 
)
ON DELETE CASCADE ENABLE;

ALTER TABLE TASKS
ADD CONSTRAINT PERCENT_DONE_CHK CHECK 
(PERCENT_DONE <= 100 AND PERCENT_DONE >= 0)
ENABLE;

ALTER TABLE TASKS_PREDECESSORS
ADD CONSTRAINT TASK_DIFFERENT_CHK CHECK 
(PREV_TASK_NO != TASK_NO)
ENABLE;

COMMENT ON TABLE PROJECTS IS 'Represents a project that contains tasks.';

COMMENT ON TABLE STATES IS 'Represents a state that a task can be in, like "In progress", "New" or "Done".';

COMMENT ON TABLE STATES_IN_PROJECTS IS 'Represents a state that is available and can be used in specified project.';

COMMENT ON TABLE TASKS IS 'Represents a task that is contained in project.';

COMMENT ON TABLE TASKS_PREDECESSORS IS 'A rule that describes transition between one project to another. Represents a situation in which one task has to be finished before the other one can be started.';

COMMENT ON COLUMN PROJECTS.PROJECT_ID IS 'Id of the project';

COMMENT ON COLUMN PROJECTS.NAME IS 'Display name of the project';

COMMENT ON COLUMN STATES.STATE_CODE IS 'Code of the state';

COMMENT ON COLUMN STATES.NAME IS 'Display name of the state';

COMMENT ON COLUMN STATES_IN_PROJECTS.PROJECT_ID IS 'Id of the associated project.';

COMMENT ON COLUMN STATES_IN_PROJECTS.STATE_CODE IS 'Id of the associated state.';

COMMENT ON COLUMN TASKS.PROJECT_ID IS 'Id of the associated project.';

COMMENT ON COLUMN TASKS.TASK_NO IS 'Number of task that is unique for given project.';

COMMENT ON COLUMN TASKS.STATE_CODE IS 'Id of the associated state in which task currently is.';

COMMENT ON COLUMN TASKS.NAME IS 'Display name of the task.';

COMMENT ON COLUMN TASKS.DESCRIPTION IS 'Long description of the task.';

COMMENT ON COLUMN TASKS.HOURS_SPENT IS 'Number of hours spent working on the task.';

COMMENT ON COLUMN TASKS.HOURS_PREDICTED IS 'Number of hours that probably will be spent working on this task.';

COMMENT ON COLUMN TASKS.PERCENT_DONE IS 'Percentage of completeness of this task.';

COMMENT ON COLUMN TASKS.CREATED_DATE IS 'Date on which this task was created.';

COMMENT ON COLUMN TASKS_PREDECESSORS.PROJECT_ID IS 'Id of the project to which this rule applies.';

COMMENT ON COLUMN TASKS_PREDECESSORS.TASK_NO IS 'Id of the associated next task''s number.';

COMMENT ON COLUMN TASKS_PREDECESSORS.PREV_TASK_NO IS 'Id of the associated previous task''s number.';
