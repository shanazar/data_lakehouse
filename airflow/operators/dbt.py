from dbt.cli.main import dbtRunner, dbtRunnerResult


class dbtOperator:

    def __init__(self, project: str) -> None:
        self.project = project
        self.project_dir = f"/usr/local/airflow/dbt/{project}/"
        self.log_path = f"/usr/local/airflow/dbt/{project}/log/"
        self.profiles_dir = f'/usr/local/airflow/dbt/{project}/profiles/'
        self.target_path = f'/usr/local/airflow/dbt/{project}/target/'

    def run(self, models: [], full_refresh = False):
        args = [
            "--log-path", self.log_path,
            "--log-level", "info",
            "run",
            "--select", f'tag:{",tag:".join(models)}',
            "--project-dir", self.project_dir,
            "--profiles-dir", self.profiles_dir,
            '--target', self.project,
            "--target-path", self.target_path,
            "--profile", 'airflow']

        if full_refresh:
            args.append('--full-refresh')

        dbt = dbtRunner()
        res: dbtRunnerResult = dbt.invoke(args)
        if res is None:
            return
        for r in res.result:
            if r.status in ['pass', 'success']:
                pass
            elif r.status == 'fail':
                raise Exception(f'DBT run failed with: {r.message}')

    def seed(self, models: [], full_refresh = False):
        args = [
            "--log-path", self.log_path,
            "--log-level", "info",
            "seed",
            "--select", f'tag:{",tag:".join(models)}',
            "--project-dir", self.project_dir,
            "--profiles-dir", self.profiles_dir,
            '--target', self.project,
            "--target-path", self.target_path,
            "--profile", 'airflow']

        if full_refresh:
            args.append('--full-refresh')

        dbt = dbtRunner()
        res: dbtRunnerResult = dbt.invoke(args)
        if res is None:
            return
        for r in res.result:
            if r.status in ['pass', 'success']:
                pass
            elif r.status == 'fail':
                raise Exception(f'DBT run failed with: {r.message}')

    def build(self, models: [], full_refresh=False):
        args = [
            "--log-path", self.log_path,
            "--log-level", "info",
            "build",
            "--select", f'tag:{",tag:".join(models)}',
            "--project-dir", self.project_dir,
            "--profiles-dir", self.profiles_dir,
            "--target-path", self.target_path,
            "--profile", "default"]

        if full_refresh:
            args.extend('--full-refresh')

        dbt = dbtRunner()
        res: dbtRunnerResult = dbt.invoke(args)
        if res is None:
            return
        for r in res.result:
            if r.status in ['pass', 'success']:
                pass
            elif r.status == 'fail':
                raise Exception(f'DBT run failed with: {r.message}')