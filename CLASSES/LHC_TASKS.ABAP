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
    METHODS on_empty_values FOR DETERMINE ON MODIFY
      IMPORTING keys FOR tasks~on_empty_values.

ENDCLASS.

CLASS lhc_Tasks IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD reopen_task.

    READ ENTITY IN LOCAL MODE zdd_r_tasks
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    CHECK lt_tasks IS NOT INITIAL.
    READ TABLE lt_tasks INTO DATA(ls_task) INDEX 1.
    CHECK sy-subrc = 0.
    MODIFY ENTITIES OF zdd_r_tasks IN LOCAL MODE
    ENTITY Tasks
    UPDATE FIELDS ( Done ) WITH VALUE #( (
      %tky-Id_Task         = ls_task-ID_Task
      %tky-ID_Project      = ls_task-ID_Project
      Done                 = '-'
    ) ).

  ENDMETHOD.

  METHOD close_task.

    "get project
    READ ENTITY IN LOCAL MODE zdd_r_tasks
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    CHECK lt_tasks IS NOT INITIAL.
    LOOP AT lt_tasks INTO DATA(ls_task).
      CHECK ls_task-Done EQ abap_true.

      MODIFY ENTITIES OF zdd_r_tasks IN LOCAL MODE
      ENTITY Tasks
      UPDATE FIELDS ( Done ) WITH VALUE #( (
        %tky-Id_Task    = ls_task-ID_Task
        %tky-ID_Project = ls_task-ID_Project
        Done            = 'X'
      ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD on_task_progress.

    READ ENTITY IN LOCAL MODE zdd_r_tasks
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    CHECK lt_tasks IS NOT INITIAL.
    LOOP AT lt_tasks ASSIGNING FIELD-SYMBOL(<ls_tasks>).

      "in opened project
      IF <ls_tasks>-Done EQ '-'.
        UPDATE ztable_task
        SET closedate = '00000000',
            closedby  = '00000000'
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

  METHOD on_empty_values.

    READ ENTITY IN LOCAL MODE zdd_r_tasks
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    CHECK lt_tasks IS NOT INITIAL.
    LOOP AT lt_tasks INTO DATA(ls_tasks).
      "DESCRIPTION
      "-----------
      IF ls_tasks-description IS INITIAL.
        SELECT * FROM ztable_task INTO TABLE @DATA(tasks).
        DATA(total_lines) = lines( tasks ).
        total_lines = total_lines + 1.
        ls_tasks-description = | Task { total_lines } |.
      ENDIF.
      "DONE
      "-----------
      IF ls_tasks-done EQ 'X'.
        ls_tasks-done = ' '.
      ENDIF.
      "DUE DATE
      "-----------
      IF ls_tasks-DueDate IS INITIAL.
        ls_tasks-DueDate = '99991231'.
      ENDIF.
      "CLOSEDATE
      "-----------
      IF ls_tasks-CloseDate IS NOT INITIAL.
        ls_tasks-CloseDate = '00000000'.
      ENDIF.
      "CLOSEDBY
      "-----------
      IF ls_tasks-ClosedBy IS NOT INITIAL.
        ls_tasks-ClosedBy = ''.
      ENDIF.
      "CREATEDBY
      "-----------
      IF ls_tasks-CreatedBy IS INITIAL.
        ls_tasks-CreatedBy = cl_abap_context_info=>get_user_technical_name( ).
      ENDIF.
      "CREATIONDATE
      "-----------
      IF ls_tasks-CreationDate IS INITIAL.
        ls_tasks-CreationDate = cl_abap_context_info=>get_system_date( ).
      ENDIF.
      "PRIORITY
      "-----------
      IF ls_tasks-Priority IS INITIAL.
        ls_tasks-Priority = 'Low'.
      ENDIF.
      "TYPETASK
      "-----------
      IF ls_tasks-TypeTask IS INITIAL.
        ls_tasks-TypeTask = 'Reparation'.
      ENDIF.

      MODIFY ENTITIES OF zdd_r_tasks IN LOCAL MODE
      ENTITY tasks
      UPDATE FIELDS ( Done
                      DueDate
                      CloseDate
                      ClosedBy
                      CreatedBy
                      CreationDate
                      Priority
                      TypeTask )
      WITH VALUE #( ( %tky-Id_Task    = ls_tasks-ID_Task
                      %tky-ID_Project = ls_tasks-ID_Project ) ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
