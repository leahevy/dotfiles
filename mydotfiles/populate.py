#!/usr/bin/env python3
import os
import os.path
import platform
import yaml
from pathlib import Path
from jinja2 import Environment, FileSystemLoader


SCRIPT_DIR = os.path.join(os.path.expanduser("~/.dotfiles"))
FILES_DIR = os.path.join(SCRIPT_DIR, "files")
CONFIG_PATH = os.path.join(SCRIPT_DIR, "environment.yml")


def main():
    print("mydotfiles:")
    _system = platform.system().lower()

    if _system == "darwin":
        _system = "osx"
    print(f"  Running on sytem: {_system}")

    global_env = {
        "global": {
            "os": _system,
        }
    }

    private_env = {}
    with open(CONFIG_PATH, "r") as f:
        print(f"  Read public config ({CONFIG_PATH})")
        env = yaml.safe_load(f) or {}
        if "private-repo" in env.keys():
            if "use" in env["private-repo"]:
                if env["private-repo"]["use"]:
                    private_config_path = os.path.join(
                        os.path.expanduser(env["private-repo"]["path"]),
                        "environment.yml",
                    )
                    with open(
                        private_config_path,
                        "r",
                    ) as f:
                        print(f"  Read private config ({private_config_path})")
                        private_env = yaml.safe_load(f)

    def merge_dicts_deep(source, destination):
        for key, value in source.items():
            if isinstance(value, dict):
                node = destination.setdefault(key, {})
                merge_dicts_deep(value, node)
            else:
                destination[key] = value
        return destination

    final_env = merge_dicts_deep(merge_dicts_deep(private_env, env), global_env)

    env = Environment(
        loader=FileSystemLoader(FILES_DIR), trim_blocks=True, lstrip_blocks=True
    )

    print("  Processing files:")
    for path in Path(os.path.join(SCRIPT_DIR, "files")).rglob("*"):
        namespace = str(path)[len(FILES_DIR) + 1 :]
        if path.is_dir() and len(namespace.split(os.sep)) == 1:
            print(f"    Namespace {namespace}:")
        if path.is_file():
            path_str = str(path.resolve())
            path_str = path_str[len(FILES_DIR) + 1 :]

            split_path = path_str.split(os.sep)
            file_path = os.sep.join(split_path[1:])

            template = env.get_template(path_str)

            result_file = os.path.join(os.path.expanduser("~"), file_path)
            print("      Write", result_file)
            with open(result_file, "w") as f:
                f.write(template.render(final_env))
