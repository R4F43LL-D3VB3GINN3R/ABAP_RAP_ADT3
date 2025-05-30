CLASS lhc_Tasks DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Tasks RESULT result.
    METHODS close_task FOR MODIFY
      IMPORTING keys FOR ACTION tasks~close_task.

ENDCLASS.

CLASS lhc_Tasks IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD close_task.

    "get project
    READ ENTITY IN LOCAL MODE zdd_r_tasks
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    "close task if the task is open
    LOOP AT lt_tasks INTO DATA(ls_task).
      IF ls_task-Done = abap_true.
        RETURN.
      ELSE.
        MODIFY ENTITIES OF zdd_r_tasks IN LOCAL MODE
        ENTITY Tasks
        UPDATE
        SET FIELDS WITH VALUE #( (
          %tky-Id_Task = ls_task-ID_Task
          Done         = abap_true
        ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
