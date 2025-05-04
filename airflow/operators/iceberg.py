from typing import Any

import yaml
from pyiceberg.catalog import load_catalog

class icebergOperator:

    def __init__(self, project: str) -> None:
        self.configuration = {}
        with open('/usr/local/airflow/include/configuration.yaml', 'r') as file:
            self.configuration = yaml.safe_load(file)[project]
        self.catalog = load_catalog(type="rest", **self.flatten_yaml(self.configuration))

    def get_catalog(self):
        return self.catalog

    def flatten_yaml(self, data, parent_key='', sep='.'):
        """
        Recursively flatten a nested dictionary.
        """
        items = []
        for k, v in data.items():
            new_key = f"{parent_key}{sep}{k}" if parent_key else k
            if isinstance(v, dict):
                items.extend(self.flatten_yaml(v, new_key, sep=sep).items())
            else:
                items.append((new_key, v))
        return dict(items)

    def evolve_table_schema(self, new_schema, table_name: str) -> list[Any]:
        target_table = self.catalog.load_table(table_name)
        with target_table.update_schema() as update:
            update.union_by_name(new_schema)