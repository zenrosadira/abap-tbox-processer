class ZTBOX_CL_PROCESSER definition
  public
  create public .

public section.

  interfaces IF_SERIALIZABLE_OBJECT .
  interfaces ZTBOX_IF_RUNNABLE .

  methods NEW_JOB
    importing
      !METHOD_NAME type SEOCPDNAME .
  methods NEW_TASK
    importing
      !METHOD_NAME type SEOCPDNAME .
  methods UPDATE_TASK
    importing
      !METHOD_NAME type SEOCPDNAME .
  class-methods EXECUTE
    importing
      !RUNNABLE type ZTBOX_PROCESSER_XML_CS_DE
    returning
      value(R_RESULT) type STRING .
  class-methods GET_XML
    importing
      !INSTANCE type ref to ZTBOX_CL_PROCESSER
    returning
      value(R_XML) type ZTBOX_PROCESSER_XML_CS_DE .
  methods CONSTRUCTOR
    importing
      !I_INSTANCE type ref to OBJECT .
  methods TASK_DONE
    importing
      !P_TASK type SYSUUID_C32 .
  methods PERFORM_TASKS
    importing
      !I_TASKS type STRING_TABLE .
  class-methods EXCEPTION
    returning
      value(R_EXCEPTION) type STRING .
protected section.
private section.

  types:
    BEGIN OF ty_task,
           name      TYPE string,
           guid      TYPE sysuuid_c32,
           completed TYPE flag,
         END OF ty_task .
  types:
    ty_tasks TYPE TABLE OF ty_task WITH DEFAULT KEY .

  data _METHOD_NAME type SEOCPDNAME .
  class-data _EXCEPTION type STRING .
  data _INSTANCE type ref to OBJECT .
  data _TASKS type TY_TASKS .

  methods _EXECUTE_TASK
    importing
      !I_TASK_ID type SYSUUID_C32 .
  methods _CREATE_TASK_ID
    returning
      value(R_RES) type SYSUUID_C32 .
  class-methods _DESERIALIZE
    importing
      !I_XML type ZTBOX_PROCESSER_XML_CS_DE
    returning
      value(R_OBJECT) type ref to ZTBOX_IF_RUNNABLE .
  class-methods _SERIALIZE
    importing
      !I_OBJECT type ref to OBJECT
    returning
      value(R_XML) type STRING .
ENDCLASS.



CLASS ZTBOX_CL_PROCESSER IMPLEMENTATION.


  METHOD update_task.

    _method_name = method_name.

    DATA(serialized) = get_xml( me ).

    CALL FUNCTION 'ZTBOX_FM_PROCESSER_UT' IN UPDATE TASK
      EXPORTING
        runnable = serialized.

  ENDMETHOD.


  METHOD execute.

    DATA(object) = _deserialize( runnable ).

    CHECK object IS BOUND.

    DATA(result) = object->run(  ).

    r_result = _serialize( result ).

  ENDMETHOD.


  METHOD get_xml.

    TRY.

        CALL TRANSFORMATION id
          SOURCE runnable = instance
          RESULT XML r_xml.

      CATCH cx_transformation_error INTO DATA(x_trans).
        _exception = x_trans->get_text( ).

    ENDTRY.

  ENDMETHOD.


  METHOD ztbox_if_runnable~run.

    CHECK _method_name  IS NOT INITIAL.
    CHECK _instance     IS BOUND.

    TRY.

        CALL METHOD _instance->(_method_name).

      CATCH cx_root INTO DATA(x_root).
        _exception = x_root->get_text( ).
        RETURN.

    ENDTRY.

    r_result = _instance.

  ENDMETHOD.


  METHOD constructor.

    _instance = i_instance.

  ENDMETHOD.


  METHOD exception.

    r_exception = _exception.

  ENDMETHOD.


  METHOD NEW_JOB.

    _method_name = method_name.

    DATA(serialized) = get_xml( me ).

    DATA job_name  TYPE btcjob.
    DATA job_id    TYPE btcjobcnt.

    job_name = method_name.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = job_name
      IMPORTING
        jobcount         = job_id
      EXCEPTIONS
        error_message    = -1
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    CHECK sy-subrc EQ 0.

    SUBMIT ztbox_job_processer AND RETURN WITH p_xml = serialized VIA JOB job_name NUMBER job_id.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = job_id
        jobname              = job_name
        strtimmed            = abap_true
      EXCEPTIONS
        error_message        = -1
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        invalid_target       = 8
        OTHERS               = 9.

  ENDMETHOD.


  METHOD new_task.

    _method_name = method_name.

    DATA(serialized) = get_xml( me ).

    DATA(task_id) = _create_task_id( ).

    CALL FUNCTION 'ZTBOX_FM_PROCESSER_RFC' STARTING NEW TASK task_id
      EXPORTING
        runnable = serialized.

  ENDMETHOD.


  METHOD perform_tasks.

    _tasks = VALUE #( FOR task IN i_tasks
      ( name = task
        guid = _create_task_id( ) ) ).

    LOOP AT _tasks ASSIGNING FIELD-SYMBOL(<task>).

      _method_name = <task>-name.

      _execute_task( <task>-guid ).

      WAIT FOR ASYNCHRONOUS TASKS UNTIL <task>-completed EQ abap_true.

    ENDLOOP.

  ENDMETHOD.


  METHOD task_done.

    READ TABLE _tasks ASSIGNING FIELD-SYMBOL(<task>) WITH KEY guid = p_task.
    <task>-completed = abap_true.

    DATA(result) = VALUE string( ).

    RECEIVE RESULTS FROM FUNCTION 'ZTBOX_FM_PROCESSER_RFC'
        IMPORTING
            ev_result = result.

    CHECK result IS NOT INITIAL.

    CALL TRANSFORMATION id
      SOURCE XML result
      RESULT result = _instance.

  ENDMETHOD.


  METHOD _create_task_id.

    TRY.
        r_res = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
    ENDTRY.

  ENDMETHOD.


  METHOD _deserialize.

    TRY.

        CALL TRANSFORMATION id
        SOURCE XML i_xml
        RESULT runnable = r_object.

      CATCH cx_st_error INTO DATA(x_st).
        _exception = x_st->get_text( ).
        RETURN.

    ENDTRY.

  ENDMETHOD.


  METHOD _execute_task.

    DATA(serialized) = get_xml( me ).

    CALL FUNCTION 'ZTBOX_FM_PROCESSER_RFC' STARTING NEW TASK i_task_id CALLING task_done ON END OF TASK
      EXPORTING
        runnable = serialized.

  ENDMETHOD.


  METHOD _serialize.

    CHECK i_object IS BOUND.

    CALL TRANSFORMATION id
      SOURCE result = i_object
      RESULT XML r_xml.

  ENDMETHOD.
ENDCLASS.
