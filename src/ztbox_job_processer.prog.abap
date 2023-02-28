*&---------------------------------------------------------------------*
*& Report ZTBOX_JOB_PROCESSER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztbox_job_processer.

PARAMETERS: p_xml TYPE ztbox_processer_xml_cs_de.

ztbox_cl_processer=>execute( p_xml ).
