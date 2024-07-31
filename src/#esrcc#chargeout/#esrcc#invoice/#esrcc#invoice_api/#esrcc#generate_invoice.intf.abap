INTERFACE /esrcc/generate_invoice PUBLIC.

  METHODS:
    generate_invoice IMPORTING invoice_reference_id TYPE sysuuid_c32
                     RETURNING VALUE(pdf_in_raw_format) TYPE cmis_s_content_raw-stream.
ENDINTERFACE.
