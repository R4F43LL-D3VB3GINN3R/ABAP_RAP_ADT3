CLASS zcl_if_tasks_runtest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    METHODS constructor.

    METHODS set_tasks.

    METHODS get_data.

    METHODS get_tasks.

    DATA: gt_tasks TYPE ztt_tasks.
    DATA: gs_task TYPE zst_task.
    DATA: gs_result TYPE zst_result.
    DATA: go_projects TYPE REF TO zcl_if_project_runtest.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_if_tasks_runtest IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    set_tasks( ).

    out->write( | Operation Code: { gs_result-rc } | ).
    out->write( | Message: { gs_result-mensagem }  | ).

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
  ENDMETHOD.

  METHOD get_tasks.
  ENDMETHOD.

ENDCLASS.
