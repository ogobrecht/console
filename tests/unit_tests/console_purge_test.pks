create or replace package console_purge_test as
--%suite(Console purge and purge job)
--%rollback(manual)

--%beforeall(console_test_helpers.enable_all_logging)
--%beforeeach(console_test_helpers.truncate_console_logs, console.purge_job_drop)
--%afterall(console.purge_job_drop)


--%context(Purge)

--%test(Purge logs)
procedure purge_old_logs;

--%test(Purge logs but keep permanent entries)
procedure keep_permanent_logging;

--%test(Purge deletes by level)
procedure purge_deletes_by_level;

--%test(Purge respects minimum age in days)
procedure purge_respects_min_days;

--%test(Purge all deletes everything)
procedure purge_all_deletes_everything;

--%test(Purge all keeps permanent entries)
procedure purge_all_keeps_permanent;

--%test(Purge rejects invalid minimum level too high)
--%throws(-20777)
procedure purge_rejects_level_too_high;

--%test(Purge rejects invalid minimum level too low)
--%throws(-20777)
procedure purge_rejects_level_too_low;

--%test(Purge accepts level error as boundary)
procedure purge_accepts_level_error;

--%test(Purge accepts level trace as boundary)
procedure purge_accepts_level_trace;

--%endcontext


--%context(Purge Job Lifecycle)

--%test(Purge job create creates job)
procedure purge_job_create_creates_job;

--%test(Purge job create skips if job exists)
procedure purge_job_create_skips_if_exists;

--%test(Purge job create with custom parameters)
procedure purge_job_create_with_custom_parameters;

--%test(Purge job disable disables job)
procedure purge_job_disable_disables_job;

--%test(Purge job enable enables job)
procedure purge_job_enable_enables_job;

--%test(Purge job drop removes job)
procedure purge_job_drop_removes_job;

--%test(Purge job run executes job)
procedure purge_job_run_executes_job;

--%endcontext


--%context(Purge Job without existing job)

--%test(Purge job drop without existing job)
procedure purge_job_drop_without_existing_job;

--%test(Purge job enable without existing job)
procedure purge_job_enable_without_existing_job;

--%test(Purge job disable without existing job)
procedure purge_job_disable_without_existing_job;

--%test(Purge job run without existing job)
procedure purge_job_run_without_existing_job;

--%endcontext

end console_purge_test;
/
