CREATE OR REPLACE PACKAGE tasks_rpt AS
  PROCEDURE html;
  PROCEDURE rpt (proj_id NUMBER);
END tasks_rpt;

CREATE OR REPLACE PACKAGE BODY tasks_rpt AS
  PROCEDURE print_data (value VARCHAR2) IS
    BEGIN
      htp.p('<div>');
      htp.p(value);
      htp.p('</div>');
    END print_data;

  PROCEDURE print_new_header(header VARCHAR2) IS
    BEGIN
      htp.p('<div style="float:left;margin-left:40px;">');
      htp.header(4, header);
    END print_new_header;

  PROCEDURE close_header IS
    BEGIN
      htp.p('</div>');
    END;

  PROCEDURE show_projects IS
    CURSOR cur IS
      SELECT *
      FROM PROJECTS;
    v_project cur%ROWTYPE;
    BEGIN
      FOR v_project in cur
      LOOP
        print_data('project id: ' || v_project.PROJECT_ID);
        print_data('title: ' || v_project.NAME);
      END LOOP;
    END show_projects;

  PROCEDURE html IS
    BEGIN
      htp.p('Projects');
      htp.formOpen('tasks_rpt.rpt', 'POST');
      htp.p('Project id');
      htp.formText('proj_id', 6, 6);
      htp.formSubmit;
      htp.formClose;
      show_projects();
    END html;

  PROCEDURE rpt (proj_id NUMBER) IS
    CURSOR cur_task(param_proj_id NUMBER) IS
      SELECT STATES.NAME as STATE_NAME, STATES.STATE_CODE as STATE_CODE,
             TASKS.TASK_NO as TASK_NO, TASKS.NAME as TASK_NAME
        FROM STATES_IN_PROJECTS
        INNER JOIN STATES ON STATES_IN_PROJECTS.STATE_CODE = STATES.STATE_CODE
        LEFT JOIN TASKS ON STATES_IN_PROJECTS.STATE_CODE = TASKS.STATE_CODE
                           AND STATES_IN_PROJECTS.PROJECT_ID = TASKS.PROJECT_ID
        WHERE STATES_IN_PROJECTS.PROJECT_ID = param_proj_id
        ORDER BY STATES.STATE_CODE, TASKS.TASK_NO;

    v_task cur_task%ROWTYPE;
    temp_state_code STATES.STATE_CODE%TYPE;
    temp_project_name PROJECTS.NAME%TYPE;

    BEGIN
      SELECT NAME INTO temp_project_name FROM PROJECTS WHERE PROJECT_ID = proj_id;
      htp.header(2, 'Project ' || temp_project_name);
      FOR v_task in cur_task(proj_id)
      LOOP
        IF temp_state_code is NULL THEN
          temp_state_code := v_task.STATE_CODE;
          print_new_header(v_task.STATE_NAME);
        ELSIF temp_state_code <> v_task.STATE_CODE THEN
          close_header();
          temp_state_code := v_task.STATE_CODE;
          print_new_header(v_task.STATE_NAME);
        END IF;
        print_data(v_task.TASK_NO || ' - ' || v_task.TASK_NAME);
      END LOOP;
    END rpt;

END tasks_rpt;
/
