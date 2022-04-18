#!/usr/bin/env python3
import os
import os.path
import glob
import platform
import yaml
import shutil
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
    private_dotfiles_location = None
    with open(CONFIG_PATH, "r") as f:
        print(f"  Read public config ({CONFIG_PATH})")
        env = yaml.safe_load(f) or {}
        if "private-repo" in env.keys():
            if "use" in env["private-repo"]:
                if env["private-repo"]["use"]:
                    private_dotfiles_location = os.path.expanduser(
                        env["private-repo"]["path"]
                    )
                    private_config_path = os.path.join(
                        private_dotfiles_location,
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

    process_files(os.path.join(SCRIPT_DIR, "files"), final_env)

    if private_dotfiles_location:
        process_files(os.path.join(private_dotfiles_location, "files"), final_env)
    print(
        "Dotfiles populated (Consider running ~/install.sh to install required packages)"
    )


def process_files(files_dir: str, env_dict: dict):
    env = Environment(
        loader=FileSystemLoader(files_dir), trim_blocks=True, lstrip_blocks=True
    )
    if glob.glob(os.path.join(files_dir, "*")):
        print(f"  Processing files in {files_dir}:")
    else:
        print(f"  Processing files in {files_dir} (empty)")
    for path in sorted(Path(files_dir).rglob("*")):
        namespace = str(path)[len(files_dir) + 1 :]
        path_resolved = str(path.resolve())
        path_str = path_resolved[len(files_dir) + 1 :]

        split_path = path_str.split(os.sep)
        file_path = os.sep.join(split_path[1:])

        result_file = os.path.join(os.path.expanduser("~"), file_path)
        if (
            path.is_dir()
            and len(namespace.split(os.sep)) == 1
            and os.listdir(path=path)
        ):
            print(f"    Namespace {namespace}:")
        elif path.is_dir() and len(namespace.split(os.sep)) == 1:
            print(f"    Namespace {namespace} (empty)")
        elif path.is_dir() and len(namespace.split(os.sep)) > 1:
            if not os.path.exists(result_file):
                print("      MakeDir", result_file)
                os.makedirs(result_file, exist_ok=True)
        elif path.is_file() and len(namespace.split(os.sep)) > 1:
            if not os.path.exists(result_file_dir := os.path.dirname(result_file)):
                print("      MakeDir", result_file_dir)
                os.makedirs(os.path.dirname(result_file), exist_ok=True)
            print("      Write", result_file)
            with open(path, "r") as f:
                first_line = f.readline().strip()
                if "jinja2: ignore" in first_line:
                    shutil.copyfile(path_resolved, result_file)
                else:
                    template = env.get_template(path_str)
                    with open(result_file, "w") as f2:
                        f2.write(template.render(env_dict))
