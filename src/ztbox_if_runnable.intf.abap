interface ZTBOX_IF_RUNNABLE
  public .


  interfaces IF_SERIALIZABLE_OBJECT .

  methods RUN
    returning
      value(R_RESULT) type ref to OBJECT .
endinterface.
