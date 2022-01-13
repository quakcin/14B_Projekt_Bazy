CREATE OR REPLACE PROCEDURE DELETE_OLD_SESSION
IS
BEGIN
    DELETE FROM sesje WHERE expr <= sysdate;
END;
/

begin

    DBMS_SCHEDULER.CREATE_JOB (
         job_name           => 'CALC_JOB',
         job_type           => 'STORED_PROCEDURE',
         job_action         => 'DELETE_OLD_SESSION',
         start_date         => current_timestamp,
         repeat_interval    => 'FREQ=hourly;',
         enabled            => true);

end;
/