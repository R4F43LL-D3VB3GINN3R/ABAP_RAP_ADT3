CLASS zcl_if_project_runtest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    METHODS constructor.

    METHODS get_projects
      RETURNING VALUE(lt_projects) TYPE ztt_projects.

    METHODS set_projects.

    METHODS get_project
      IMPORTING
        project_id TYPE sysuuid_x16
      EXPORTING
        ls_project TYPE zst_project
        ls_result  TYPE zst_result.

    METHODS get_data.

    METHODS generate_uuid
      RETURNING VALUE(uuid) TYPE sysuuid_x16.

    METHODS get_project_id
      RETURNING VALUE(project_id) TYPE sysuuid_x16.

    DATA: gs_result TYPE zst_result.
    DATA: gs_project TYPE zst_project.
    DATA: gt_projects TYPE ztt_projects.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_if_project_runtest IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

*    set_projects( ).

    out->write( | Operation Code: { gs_result-rc } | ).
    out->write( | Message: { gs_result-mensagem }  | ).

  ENDMETHOD.

  METHOD constructor.

    get_data( ).

  ENDMETHOD.

  METHOD get_data.

    CLEAR gt_projects.

    SELECT *
    FROM ztable_projects
    INTO CORRESPONDING FIELDS OF TABLE @gt_projects.

  ENDMETHOD.

  METHOD get_projects.

    lt_projects = gt_projects.

  ENDMETHOD.

  METHOD get_project.

    DATA(projects) = get_projects( ).

    "get project into projects
    READ TABLE projects INTO DATA(project) WITH KEY project_id = project_id.
    IF sy-subrc EQ 0.
      ls_result-rc       = 0.
      ls_result-mensagem = | Produto { project_id } recebido |.
      ls_project         = project.
      gs_result          = ls_result.
    ELSE.
      ls_result-rc       = 1.
      ls_result-mensagem = | Não foi possível encontra um projeto com id { project_id } |.
      gs_result          = ls_result.
    ENDIF.

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

    "output operations
    IF lt_projects IS NOT INITIAL.
      gs_result-rc       = '0'.
      gs_result-mensagem = 'Projects generated with sucessfull.'.
    ELSE.
      gs_result-rc       = '1'.
      gs_result-mensagem = 'Impossible to generate projects.'.
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

  METHOD get_project_id.

    "table and table index
    DATA(projects) = get_projects( ).
    DATA lv_index TYPE i.

    "generate randomic index for table
    DATA seed TYPE i.
    seed = cl_abap_random=>seed( ).

    DATA: go_random_key TYPE REF TO cl_abap_random_int.
    DATA(lv_max_range) = lines( projects ).
    DATA(lv_min_range) = 1.

    TRY.
        CALL METHOD cl_abap_random_int=>create
          EXPORTING
            seed = seed
            min  = lv_min_range
            max  = lv_max_range
          RECEIVING
            prng = go_random_key.
      CATCH cx_root INTO DATA(gx_error).
        gs_result-rc       = 1.
        gs_result-mensagem = |Erro: { gx_error->get_text( ) }|.
    ENDTRY.
    lv_index = go_random_key->get_next( ).

    "send project id
    READ TABLE projects INTO DATA(project) INDEX lv_index.
    project_id = project-project_id.

  ENDMETHOD.

ENDCLASS.
