class ZTBOX_CL_PROCESSER definition
  public
  abstract
  create public .

public section.

  interfaces IF_SERIALIZABLE_OBJECT .
  interfaces ZTBOX_IF_RUNNABLE .

  methods START_JOB
    importing
      !METHOD_NAME type SEOCPDNAME .
  methods UPDATE_TASK
    importing
      !METHOD_NAME type SEOCPDNAME .
  class-methods EXECUTE
    importing
      !RUNNABLE type ZTBOX_PROCESSER_XML_CS_DE .
  class-methods GET_XML
    importing
      !INSTANCE type ref to ZTBOX_CL_PROCESSER
    returning
      value(R_XML) type ZTBOX_PROCESSER_XML_CS_DE .
protected section.
private section.

  data _METHOD_NAME type SEOCPDNAME .
  class-data _EXCEPTION type STRING .
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

    DATA instance TYPE REF TO ztbox_if_runnable.

    CHECK runnable IS NOT INITIAL.

    TRY.

        CALL TRANSFORMATION id
        SOURCE XML runnable
        RESULT runnable = instance.

      CATCH cx_st_error INTO DATA(x_st).
        _exception = x_st->get_text( ).
        RETURN.

    ENDTRY.

    CHECK instance IS BOUND.

    TRY.

        instance->run(  ).

      CATCH cx_root INTO DATA(o_root).

        _exception = o_root->get_text( ).

    ENDTRY.

  ENDMETHOD.


  METHOD start_job.

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

    CHECK _method_name IS NOT INITIAL.

    TRY.

        CALL METHOD (_method_name).

      CATCH cx_root INTO DATA(x_root).
        _exception = x_root->get_text( ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
