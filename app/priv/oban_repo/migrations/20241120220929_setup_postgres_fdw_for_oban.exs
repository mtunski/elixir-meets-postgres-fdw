defmodule App.ObanRepo.Migrations.SetupPostgresFdwForOban do
  use Ecto.Migration

  def up do
    Ecto.Migrator.with_repo(App.Repo, fn app_repo ->
      app_repo.transaction(fn ->
        app_repo.query!("LOCK TABLE schema_migrations IN SHARE UPDATE EXCLUSIVE MODE")
        app_repo.query!("SELECT version FROM schema_migrations")

        user = System.get_env("USER")

        app_repo.query!("CREATE EXTENSION postgres_fdw")

        app_repo.query!("""
        CREATE SERVER oban
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host 'localhost', port '5434', dbname 'oban')
        """)

        app_repo.query!("""
        CREATE USER MAPPING FOR "#{user}"
        SERVER oban
        OPTIONS (user '#{user}', password '""')
        """)

        app_repo.query!("DROP TABLE oban_jobs")

        app_repo.query!("""
        IMPORT FOREIGN SCHEMA public LIMIT TO (oban_jobs)
          FROM SERVER oban INTO public
        """)

        execute(
          "CREATE VIEW oban_jobs_id_seq_view AS SELECT nextval('oban_jobs_id_seq') as nextval"
        )

        app_repo.query!("""
        CREATE FOREIGN TABLE oban_jobs_id_seq_view (nextval bigint)
        SERVER oban OPTIONS (table_name 'oban_jobs_id_seq_view')
        """)

        app_repo.query!("""
        CREATE FUNCTION oban_jobs_id_seq_nextval() RETURNS bigint AS
        'SELECT nextval FROM oban_jobs_id_seq_view' LANGUAGE SQL
        """)

        app_repo.query!(
          "ALTER TABLE ONLY oban_jobs ALTER COLUMN id SET DEFAULT oban_jobs_id_seq_nextval()"
        )

        app_repo.query!(
          "ALTER TABLE ONLY oban_jobs ALTER COLUMN state SET DEFAULT 'available'::oban_job_state"
        )

        app_repo.query!(
          "ALTER TABLE ONLY oban_jobs ALTER COLUMN queue SET DEFAULT 'default'::text"
        )

        app_repo.query!("ALTER TABLE ONLY oban_jobs ALTER COLUMN args SET DEFAULT '{}'::jsonb")

        app_repo.query!(
          "ALTER TABLE ONLY oban_jobs ALTER COLUMN errors SET DEFAULT ARRAY[]::jsonb[]"
        )

        app_repo.query!("ALTER TABLE ONLY oban_jobs ALTER COLUMN attempt SET DEFAULT 0")
        app_repo.query!("ALTER TABLE ONLY oban_jobs ALTER COLUMN max_attempts SET DEFAULT 20")

        app_repo.query!(
          "ALTER TABLE ONLY oban_jobs ALTER COLUMN inserted_at SET DEFAULT timezone('UTC'::text, now())"
        )

        app_repo.query!(
          "ALTER TABLE ONLY oban_jobs ALTER COLUMN scheduled_at SET DEFAULT timezone('UTC'::text, now())"
        )

        app_repo.query!("ALTER TABLE ONLY oban_jobs ALTER COLUMN priority SET DEFAULT 0")

        app_repo.query!(
          "ALTER TABLE ONLY oban_jobs ALTER COLUMN tags SET DEFAULT ARRAY[]::character varying[]"
        )

        app_repo.query!("ALTER TABLE ONLY oban_jobs ALTER COLUMN meta SET DEFAULT '{}'::jsonb")

        app_repo.query!(
          "ALTER TABLE oban_jobs ADD CONSTRAINT attempt_range CHECK (attempt >= 0 AND attempt <= max_attempts)"
        )

        app_repo.query!("ALTER TABLE oban_jobs VALIDATE CONSTRAINT attempt_range")

        app_repo.query!(
          "ALTER TABLE oban_jobs ADD CONSTRAINT non_negative_priority CHECK (priority >= 0) NOT VALID"
        )

        app_repo.query!("ALTER TABLE oban_jobs VALIDATE CONSTRAINT non_negative_priority")

        app_repo.query!(
          "ALTER TABLE oban_jobs ADD CONSTRAINT positive_max_attempts CHECK (max_attempts > 0)"
        )

        app_repo.query!("ALTER TABLE oban_jobs VALIDATE CONSTRAINT positive_max_attempts")

        app_repo.query!(
          "ALTER TABLE oban_jobs ADD CONSTRAINT queue_length CHECK (char_length(queue) > 0 AND char_length(queue) < 128)"
        )

        app_repo.query!("ALTER TABLE oban_jobs VALIDATE CONSTRAINT queue_length")

        app_repo.query!(
          "ALTER TABLE oban_jobs ADD CONSTRAINT worker_length CHECK (char_length(worker) > 0 AND char_length(worker) < 128)"
        )

        app_repo.query!("ALTER TABLE oban_jobs VALIDATE CONSTRAINT worker_length")
      end)
    end)
  end

  def down do
  end
end
