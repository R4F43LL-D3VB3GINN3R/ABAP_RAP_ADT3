CLASS zcl_if_project_runtest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    METHODS set_projects
      EXPORTING
        result TYPE zst_result.

    METHODS generate_uuid
      RETURNING VALUE(uuid) TYPE sysuuid_x16.

    DATA: gs_result TYPE zst_result.
    DATA: gv_actnum TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_if_project_runtest IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.



  ENDMETHOD.

  METHOD set_projects.

    DATA: ls_project TYPE ztable_projects.
    DATA: lt_projects TYPE TABLE OF ztable_projects.

    "set number of projects
    DATA: lt_index TYPE TABLE OF i.
    lt_index = VALUE #( ( 1 ) ( 2 ) ( 3 ) ( 4 ) ( 5 )
                        ( 6 ) ( 7 ) ( 8 ) ( 9 ) ( 10 ) ).

    "fill database table with projects
    DELETE FROM ztable_projects.
    LOOP AT lt_index INTO DATA(index).
      ls_project-project_id = generate_uuid( ).
      ls_project-name       = | project { index } |.
      ls_project-status     = abap_false.
      APPEND ls_project TO lt_projects.
    ENDLOOP.
    MODIFY ztable_projects FROM TABLE @lt_projects.

    IF sy-subrc EQ 0.
      result-rc       = '0'.
      result-mensagem = 'Projects gerated with sucessfull.'.
    ENDIF.

  ENDMETHOD.

  METHOD generate_uuid.

    DATA: lo_system_uuid TYPE REF TO if_system_uuid.

    lo_system_uuid = cl_uuid_factory=>create_system_uuid( ).

    TRY.
        uuid = lo_system_uuid->create_uuid_x16( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
