CLASS zcl_if_tasks_runtest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    "methods to self object
    METHODS constructor.
    METHODS set_tasks.
    METHODS get_data.
    METHODS get_tasks
      RETURNING VALUE(lt_tasks) TYPE ztt_tasks.
    METHODS get_task
      IMPORTING task_id TYPE sysuuid_x16
      EXPORTING ls_task TYPE zst_task.

    "methods crud for cds
    METHODS read_task
      IMPORTING
        task_uuid    TYPE sysuuid_x16
        project_uuid TYPE sysuuid_x16.
    METHODS create_task
      IMPORTING
        quantity TYPE i.
    METHODS update_task
      IMPORTING
        task_uuid    TYPE sysuuid_x16
        project_uuid TYPE sysuuid_x16.
    METHODS delete_task
      IMPORTING
        task_uuid    TYPE sysuuid_x16
        project_uuid TYPE sysuuid_x16.

    "actions
    METHODS close_task
      IMPORTING
        task_uuid    TYPE sysuuid_x16
        project_uuid TYPE sysuuid_x16.
    METHODS reopen_task
      IMPORTING
        task_uuid    TYPE sysuuid_x16
        project_uuid TYPE sysuuid_x16.

    "custom data
    DATA: gt_tasks TYPE ztt_tasks.
    DATA: gs_task TYPE zst_task.
    DATA: gs_result TYPE zst_result.
    DATA: go_projects TYPE REF TO zcl_if_project_runtest.

    "cds data
    DATA: gt_read_tasks TYPE TABLE FOR READ RESULT zdd_r_tasks,
          gs_read_task  LIKE LINE OF gt_read_tasks.
    DATA: gt_create_tasks TYPE TABLE FOR CREATE zdd_r_tasks,
          gs_create_task  LIKE LINE OF gt_create_tasks.
    DATA: gt_update_tasks TYPE TABLE FOR UPDATE zdd_r_tasks,
          gs_update_task  LIKE LINE OF gt_update_tasks.
    DATA: gt_delete_tasks TYPE TABLE FOR DELETE zdd_r_tasks,
          gs_delete_task  LIKE LINE OF gt_delete_tasks.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_if_tasks_runtest IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

*    set_tasks( ).

*    read_task(
*      task_uuid    = '3EAC609FD7601FD08FA5F21E7715BA0E'
*      project_uuid = '72B8924CCC321FD08F90A7FD36E5999E'
*    ).

    create_task( quantity = 1 ).

*    update_task( task_uuid    = '3EAC609FD7601FD08FA5F21E7715BA0E'
*                 project_uuid = '72B8924CCC321FD08F90A7FD36E5999E' ).

*    delete_task(
*      task_uuid    = '3EAC609FD7601FD08FA94DE1CFAEFA0F'
*      project_uuid = '3EAC609FD7601FD08FA94DE1CFAEDA0F'
*    ).

*    close_task(
*      task_uuid    = '3EAC609FD7601FD08FA5F21E7715FA0E'
*      project_uuid = '72B8924CCC321FD08F90A7FD36E4B99E'
*    ).

*    reopen_task(
*       task_uuid    = 'E65FD4A88F001FE09093A342AD56886A'
*       project_uuid = '72B8924CCC321FD08F90A7FD36E4F99E'
*    ).

    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
    out->write( | Operation Code: { gs_result-rc } | ).
    out->write( | Message: { gs_result-mensagem }  | ).
    out->write( | Time: { lv_time }| ).

  ENDMETHOD.

  METHOD reopen_task.

    go_projects->get_project(
      EXPORTING
        project_id = project_uuid
      IMPORTING
        ls_project = DATA(project)
        ls_result  = gs_result
    ).

    "verification for empty content
    IF gs_result-rc EQ 1.
      RETURN.
    ELSE.
      "verification for project opened
      IF project-status EQ abap_true.
        gs_result-rc       = 1.
        gs_result-mensagem = | Project { project-project_id } is already closed |.
        RETURN.
      ELSE.
        "close task
        MODIFY ENTITIES OF zdd_r_tasks
        ENTITY Tasks
        EXECUTE reopen_task FROM VALUE #( ( %tky-ID_Task    = task_uuid
                                            %tky-ID_Project = project_uuid ) )
        FAILED   DATA(ls_action_failed)
        REPORTED DATA(ls_action_reported)
        MAPPED   DATA(ls_action_mapped).

        IF ls_action_failed IS INITIAL.
          COMMIT ENTITIES.
          gs_result-rc       = 0.
          gs_result-mensagem = |'Task { task_uuid } was opened.'|.
        ELSE.
          ROLLBACK ENTITIES.
          gs_result-rc       = 1.
          gs_result-mensagem = |'Not possible to Open Task { task_uuid }.'|.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD close_task.

    go_projects->get_project(
      EXPORTING
        project_id = project_uuid
      IMPORTING
        ls_project = DATA(project)
        ls_result  = gs_result
    ).

    "verification for empty content
    IF gs_result-rc EQ 1.
      RETURN.
    ELSE.
      "verification for project opened
      IF project-status EQ abap_true.
        gs_result-rc       = 1.
        gs_result-mensagem = | Project { project-project_id } is already closed |.
        RETURN.
      ELSE.
        "close task
        MODIFY ENTITIES OF zdd_r_tasks
        ENTITY Tasks
        EXECUTE close_task FROM VALUE #( ( %tky-ID_Task    = task_uuid
                                           %tky-ID_Project = project_uuid ) )
        FAILED   DATA(ls_action_failed)
        REPORTED DATA(ls_action_reported)
        MAPPED   DATA(ls_action_mapped).

        IF ls_action_failed IS INITIAL.
          COMMIT ENTITIES.
          gs_result-rc       = 0.
          gs_result-mensagem = 'Task Closed by CDS.'.
        ELSE.
          ROLLBACK ENTITIES.
          gs_result-rc       = 1.
          gs_result-mensagem = |'Not possible to Close Task { task_uuid }.'|.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD delete_task.

    MODIFY ENTITIES OF zdd_r_tasks
    ENTITY Tasks
    DELETE FROM VALUE #( ( %tky-ID_Task    = task_uuid
                           %tky-ID_Project = project_uuid ) )
    FAILED   DATA(ls_failed_data)
    REPORTED DATA(ls_reported_data)
    MAPPED   DATA(ls_mapped_data).

    IF ls_failed_data IS INITIAL.
      COMMIT ENTITIES.
      gs_result-rc       = 0.
      gs_result-mensagem = 'Task Removed by CDS.'.
    ELSE.
      ROLLBACK ENTITIES.
      gs_result-rc       = 1.
      gs_result-mensagem = 'Impossible to Remove Tasks by CDS.'.
    ENDIF.

  ENDMETHOD.

  METHOD update_task.

    MODIFY ENTITIES OF zdd_r_tasks
    ENTITY Tasks
    UPDATE
    SET FIELDS WITH VALUE #( (
       %tky-ID_Task    = task_uuid
       %tky-ID_Project = project_uuid
       Description     = 'Task Updated'
       Done            = abap_false
       TypeTask        = 'Reparation'
       Priority        = 'High'
       DueDate         = '20250707'
       CreatedBy       = cl_abap_context_info=>get_user_technical_name( )
*       ClosedBy        = ''
       CreationDate    = cl_abap_context_info=>get_system_date( )
*       CloseDate       = ''
    ) )
    FAILED   DATA(ls_update_failed)
    REPORTED DATA(ls_update_reported)
    MAPPED   DATA(ls_update_mapped).

    IF ls_update_failed IS INITIAL.
      COMMIT ENTITIES.
      gs_result-rc       = 0.
      gs_result-mensagem = 'Task Updated by CDS.'.
    ELSE.
      ROLLBACK ENTITIES.
      gs_result-rc       = 1.
      gs_result-mensagem = 'Impossible to Update Tasks by CDS.'.
    ENDIF.

  ENDMETHOD.

  METHOD create_task.

    CLEAR: gs_create_task,
           gt_create_tasks,
           gt_tasks.

    "retrieve database to set the current index
    get_data( ).
    get_tasks( ).
    DATA(total_lines) = lines( gt_tasks ).

    "prepate table with tasks generated
    DO quantity TIMES.
      total_lines = total_lines + 1.
      gs_create_task-%cid         = go_projects->generate_uuid( ).
      gs_create_task-ID_Task      = gs_create_task-%cid.
      gs_create_task-ID_Project   = go_projects->get_project_id( ).
      gs_create_task-Description  = | Task { total_lines } |.
      gs_create_task-Done         = ''.
      gs_create_task-TypeTask     = 'Reparation'.
      gs_create_task-Priority     = 'Low'.
      gs_create_task-DueDate      = '20251231'.
      gs_create_task-CreatedBy    = cl_abap_context_info=>get_user_technical_name( ).
      gs_create_task-ClosedBy     = ''.
      gs_create_task-CreationDate = cl_abap_context_info=>get_system_date( ).
      gs_create_task-CloseDate    = '00000000'.

      gs_create_task-%control-ID_Task      = if_abap_behv=>mk-on.
      gs_create_task-%control-ID_Project   = if_abap_behv=>mk-on.
      gs_create_task-%control-Description  = if_abap_behv=>mk-on.
      gs_create_task-%control-Done         = if_abap_behv=>mk-on.
      gs_create_task-%control-TypeTask     = if_abap_behv=>mk-on.
      gs_create_task-%control-Priority     = if_abap_behv=>mk-on.
      gs_create_task-%control-DueDate      = if_abap_behv=>mk-on.
      gs_create_task-%control-CreatedBy    = if_abap_behv=>mk-on.
      gs_create_task-%control-ClosedBy     = if_abap_behv=>mk-on.
      gs_create_task-%control-CreationDate = if_abap_behv=>mk-on.
      gs_create_task-%control-CloseDate    = if_abap_behv=>mk-on.
      APPEND gs_create_task TO gt_create_tasks.
    ENDDO.

    "create tasks into database
    MODIFY ENTITIES OF zdd_r_tasks
      ENTITY Tasks
      CREATE FROM gt_create_tasks
      FAILED   DATA(ls_create_failed)
      REPORTED DATA(ls_create_reported)
      MAPPED   DATA(ls_create_mapped).

    IF ls_create_failed IS INITIAL.
      COMMIT ENTITIES.
      gs_result-rc       = 0.
      gs_result-mensagem = 'Task Created by CDS.'.
    ELSE.
      ROLLBACK ENTITIES.
      gs_result-rc       = 1.
      gs_result-mensagem = 'Impossible to Create Tasks by CDS.'.
    ENDIF.
  ENDMETHOD.

  METHOD read_task.

    CLEAR gt_read_tasks.

    READ ENTITIES OF zdd_r_tasks
    ENTITY Tasks
    ALL FIELDS WITH VALUE #( (
     ID_Task    = task_uuid
     ID_Project = project_uuid ) )
    RESULT gt_read_tasks.

    "output operations
    IF gt_read_tasks IS NOT INITIAL.
      gs_result-rc       = 0.
      gs_result-mensagem = 'Tasks Loaded.'.
    ELSE.
      gs_result-rc       = 1.
      gs_result-mensagem = 'Impossible to Load Tasks.'.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    go_projects = NEW zcl_if_project_runtest( ).

    get_data( ).

  ENDMETHOD.

  METHOD set_tasks.

    "set number of projects
    DATA: lt_index TYPE TABLE OF i.
    DATA: lv_num TYPE i VALUE 1.
    DO 25 TIMES.
      APPEND lv_num TO lt_index.
      lv_num = lv_num + 1.
    ENDDO.

    "fill database table with tasks
    DATA: ls_task TYPE ztable_task.
    DATA: lt_tasks TYPE TABLE OF ztable_task.
    DATA: lv_date TYPE datum.

    DELETE FROM ztable_task.
    LOOP AT lt_index INTO DATA(index).
      ls_task-project_id   = go_projects->get_project_id( ).
      ls_task-task_id      = go_projects->generate_uuid( ).
      ls_task-description  = | Task { index } |.
      ls_task-done         = abap_false.
      ls_task-typetask     = 'Reparation'.
      ls_task-priority     = 'Low'.
      ls_task-due_date     = '20251231'.
      ls_task-createdby    = cl_abap_context_info=>get_user_technical_name( ).
      ls_task-closedby     = ''.
      ls_task-creationdate = cl_abap_context_info=>get_system_date( ).
*      gs_create_task-CloseDate    = ''.
      APPEND ls_task TO lt_tasks.
    ENDLOOP.
    MODIFY ztable_task FROM TABLE @lt_tasks.

    "output operations
    IF lt_tasks IS NOT INITIAL.
      gs_result-rc       = '0'.
      gs_result-mensagem = 'Tasks generated with sucessfull.'.

    ELSE.
      gs_result-rc       = '1'.
      gs_result-mensagem = 'Impossible to generate tasks.'.
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    CLEAR gt_tasks.

    SELECT *
    FROM ztable_task
    INTO CORRESPONDING FIELDS OF TABLE @gt_tasks.
    SORT gt_tasks BY description ASCENDING.

  ENDMETHOD.

  METHOD get_tasks.

    lt_tasks = gt_tasks.

  ENDMETHOD.

  METHOD get_task.

    READ TABLE gt_tasks INTO gs_task WITH KEY task_id = task_id.
    IF sy-subrc EQ 0.
      ls_task = gs_task.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
