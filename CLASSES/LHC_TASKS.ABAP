CLASS lhc_Tasks DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Tasks RESULT result.
    METHODS close_task FOR MODIFY
      IMPORTING keys FOR ACTION tasks~close_task.
    METHODS reopen_task FOR MODIFY
      IMPORTING keys FOR ACTION tasks~reopen_task.

ENDCLASS.

CLASS lhc_Tasks IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD reopen_task.

    READ ENTITY IN LOCAL MODE zdd_r_tasks
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tasks).

    READ TABLE lt_tasks INTO DATA(ls_task) INDEX 1.
    IF sy-subrc = 0.
      MODIFY ENTITIES OF zdd_r_tasks IN LOCAL MODE
      ENTITY Tasks
      UPDATE
      SET FIELDS WITH VALUE #( (
        %tky-Id_Task         = ls_task-ID_Task
        %tky-ID_Project      = ls_task-ID_Project
        Done                 = ' '
        Description          = |Task reopened at { sy-datum } { sy-uzeit }|
        %control-Done        = if_abap_behv=>mk-on
        %control-Description = if_abap_behv=>mk-on
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
          UPDATE
          SET FIELDS WITH VALUE #( (
            %tky-Id_Task    = ls_task-ID_Task
            %tky-ID_Project = ls_task-ID_Project
            Done            = abap_true
            CloseDate       = cl_abap_context_info=>get_system_date( )
            ClosedBy        = cl_abap_context_info=>get_user_technical_name( )
          ) ).
        ENDIF.
      ENDLOOP.
    ELSE.
      RETURN.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
