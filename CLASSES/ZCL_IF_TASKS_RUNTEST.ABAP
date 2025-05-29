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
    METHODS read_task.

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

    read_task( ).

    out->write( | Operation Code: { gs_result-rc } | ).
    out->write( | Message: { gs_result-mensagem }  | ).

  ENDMETHOD.

  METHOD read_task.

    CLEAR gt_read_tasks.

    READ ENTITIES OF zdd_r_tasks
    ENTITY Tasks
    ALL FIELDS WITH VALUE #( (
     ID_Task    = '72B8924CCC321FD08F918F8748F7199E'
     ID_Project = '72B8924CCC321FD08F90A7FD36E5399E' ) )
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

    DELETE FROM ztable_task.
    LOOP AT lt_index INTO DATA(index).
      ls_task-project_id  = go_projects->get_project_id( ).
      ls_task-task_id     = go_projects->generate_uuid( ).
      ls_task-description = | Task { index } |.
      ls_task-done        = abap_false.
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

    SELECT *
    FROM ztable_task
    INTO CORRESPONDING FIELDS OF TABLE @gt_tasks.

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
