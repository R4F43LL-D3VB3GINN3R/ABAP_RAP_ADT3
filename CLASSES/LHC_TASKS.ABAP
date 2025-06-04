CLASS lhc_Tasks DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Tasks RESULT result.
    METHODS close_task FOR MODIFY
      IMPORTING keys FOR ACTION tasks~close_task.
    METHODS reopen_task FOR MODIFY
      IMPORTING keys FOR ACTION tasks~reopen_task.
    METHODS on_task_progress FOR DETERMINE ON MODIFY
      IMPORTING keys FOR tasks~on_task_progress.

ENDCLASS.

CLASS lhc_Tasks IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD reopen_task.

    READ ENTITY IN LOCAL MODE zdd_r_tasks
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tasks).

    DATA(lv_closedate) = ''.
    DATA(lv_closedby)  = ''.

    READ TABLE lt_tasks INTO DATA(ls_task) INDEX 1.
    IF sy-subrc = 0.
      MODIFY ENTITIES OF zdd_r_tasks IN LOCAL MODE
      ENTITY Tasks
      UPDATE FIELDS ( Done ) WITH VALUE #( (
        %tky-Id_Task         = ls_task-ID_Task
        %tky-ID_Project      = ls_task-ID_Project
        Done                 = '-'
*        CloseDate            = lv_closedate
*        ClosedBy             = lv_closedby
      ) ).
    ENDIF.

  ENDMETHOD.

  METHOD close_task.

    "get project
    READ ENTITY IN LOCAL MODE zdd_r_tasks
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    IF lt_tasks IS NOT INITIAL.
      "close task if the task is open
      LOOP AT lt_tasks INTO DATA(ls_task).
        IF ls_task-Done = abap_true.
          RETURN.
        ELSE.
          MODIFY ENTITIES OF zdd_r_tasks IN LOCAL MODE
          ENTITY Tasks
          UPDATE FIELDS ( Done ) WITH VALUE #( (
            %tky-Id_Task    = ls_task-ID_Task
            %tky-ID_Project = ls_task-ID_Project
            Done            = 'X'
*            CloseDate       = cl_abap_context_info=>get_system_date( )
*            ClosedBy        = cl_abap_context_info=>get_user_technical_name(
          ) ).
        ENDIF.
      ENDLOOP.
    ELSE.
      RETURN.
    ENDIF.

  ENDMETHOD.

  METHOD on_task_progress.

    DATA(lv_count) = 1.
    lv_count = lv_count + 1.

    READ ENTITY IN LOCAL MODE zdd_r_tasks
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    IF lt_tasks IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_tasks ASSIGNING FIELD-SYMBOL(<ls_tasks>).

      "in opened project
      IF <ls_tasks>-Done EQ '-'.

        DATA: lv_closedate TYPE datum.
        DATA: lv_closedby  TYPE datum.
        lv_closedate = '00000000'.
        lv_closedby  = '00000000'.

        "set update to table
        UPDATE ztable_task
        SET closedate = @lv_closedate,
            closedby  = @lv_closedby
        WHERE task_id = @<ls_tasks>-ID_Task.
      ENDIF.

      "in closed project
      IF <ls_tasks>-Done EQ 'X'.

        DATA(lv_closedate2) = cl_abap_context_info=>get_system_date( ).
        DATA(lv_closedby2)  = cl_abap_context_info=>get_user_technical_name( ).

        UPDATE ztable_task
        SET closedate = @lv_closedate2,
            closedby  = @lv_closedby2
        WHERE task_id = @<ls_tasks>-ID_Task.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
