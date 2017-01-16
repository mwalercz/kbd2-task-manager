CREATE OR REPLACE PACKAGE tasks_rpt AS
  /* html procedure renders projects form, where we can pick which report we want to see */
  /* rpt procedure renders report about tasks in given project. Tasks are grouped by state */
  /* links: http://ora1.elka.pw.edu.pl:8080/kbd/tasks_rpt.html */
  /* http://ora1.elka.pw.edu.pl:8080/kbd/tasks_rpt.rpt?proj_id=1 */
  /* proj_id examples: 1 or 2 */
  PROCEDURE html;
  PROCEDURE rpt (proj_id NUMBER DEFAULT 1);
END tasks_rpt;

CREATE OR REPLACE PACKAGE BODY tasks_rpt AS

  PROCEDURE close_div IS
    /* There is no htp/htf procedure to close div */
    BEGIN
      htp.prn('</div>');
    END;

  PROCEDURE print_data (value VARCHAR2) IS
    /* prints one task */
    BEGIN
      htp.div;
      htp.prn(value);
      close_div();
    END print_data;

  PROCEDURE print_new_header(header VARCHAR2) IS
    /* prints state header */
    BEGIN
      htp.div(NULL, 'style="float:left;margin-left:40px;"');
      htp.header(4, header);
    END print_new_header;

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
      htp.header(2, 'Projects');
      htp.formOpen('tasks_rpt.rpt', 'POST');
      htp.prn('Project id');
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

    temp_task cur_task%ROWTYPE;
    temp_state_code STATES.STATE_CODE%TYPE;
    temp_project_name PROJECTS.NAME%TYPE;

    BEGIN
      SELECT NAME INTO temp_project_name FROM PROJECTS WHERE PROJECT_ID = proj_id;
      htp.header(2, 'Project ' || temp_project_name);
      FOR temp_task in cur_task(proj_id)
      LOOP
        IF temp_state_code is NULL THEN
          temp_state_code := temp_task.STATE_CODE;
          print_new_header(temp_task.STATE_NAME);
        ELSIF temp_state_code <> temp_task.STATE_CODE THEN
          close_div();
          temp_state_code := temp_task.STATE_CODE;
          print_new_header(temp_task.STATE_NAME);
        END IF;
        print_data(temp_task.TASK_NO || ' - ' || temp_task.TASK_NAME);
      END LOOP;
    END rpt;

END tasks_rpt;
/
