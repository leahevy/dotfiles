#!/usr/bin/env python3
import os
import os.path
import glob
import platform
import sys
import yaml
import shutil
import getpass
import re
import xdgappdirs
import tempfile
from distutils.dir_util import copy_tree
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
import typer


SCRIPT_DIR = os.path.join(os.path.expanduser("~/.dotfiles"))
FILES_DIR = os.path.join(SCRIPT_DIR, "files")
CONFIG_PATH = os.path.join(SCRIPT_DIR, "environment.yml")


def populate(dry_run: bool = typer.Option(False, "-n", "--dry-run", help="Don't do anything")):
    print("mydotfiles:")
    _system = platform.system().lower()

    if _system == "darwin":
        _system = "osx"
    print(f"  Running on sytem: {_system}")

    global_env = {
        "global": {
            "os": _system,
            "user": {
                "name": getpass.getuser(),
                "home": os.path.expanduser("~"),
            },
            "env": dict(os.environ),
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

    # Treat any argument to run in dry run
    if dry_run:
        print("DRY RUN")

    with tempfile.TemporaryDirectory() as tmpdirname:
        if dry_run:
            tmpdirname = "~/"
        process_files(os.path.join(SCRIPT_DIR, "files"), tmpdirname, final_env, dry_run)
        if private_dotfiles_location:
            process_files(
                os.path.join(private_dotfiles_location, "files"), tmpdirname, final_env, dry_run
            )
        if not dry_run:
            copy_tree(tmpdirname, os.path.expanduser("~"))

    if not dry_run:
        print(
            "Dotfiles populated (Consider running ~/install.sh to install required packages)"
        )


def process_files(files_dir: str, target_dir: str, env_dict: dict, dry_run: bool):
    files_dir = os.path.realpath(files_dir)
    env = Environment(
        loader=FileSystemLoader(files_dir), trim_blocks=True, lstrip_blocks=True
    )
    if glob.glob(os.path.join(files_dir, "*")):
        print(f"  Processing files in {files_dir}:")
    else:
        print(f"  Processing files in {files_dir} (empty)")
    for full_path in sorted(Path(files_dir).rglob("*")):
        full_path = str(full_path.resolve())
        path_in_files_dir = full_path[len(files_dir) + len(os.sep) :]
        path_split = path_in_files_dir.split(os.sep)
        if path_in_files_dir.startswith("_special"):
            if len(path_split) < 2:
                continue  # Do not handle special folder directly
            elif len(path_split) == 2:
                namespace = os.path.join(*path_split[:2])
                path_rest = ""
            else:
                namespace = os.path.join(*path_split[:2])
                path_rest = os.path.join(*path_split[2:])
        elif len(path_split) == 1:
            namespace = path_split[0]
            path_rest = ""
        elif not path_split:
            raise ValueError("Invalid file context")
        else:
            namespace = os.path.join(*path_split[:1])
            path_rest = os.path.join(*path_split[1:])

        result_dir = target_dir

        if namespace == os.path.join("_special", "user_config_dir"):
            result_dir = str(xdgappdirs.user_config_dir())
        elif namespace.startswith("_special"):
            raise ValueError(f"Invalid special path: {namespace}")

        result_file = os.path.join(result_dir, path_rest)

        if not path_rest and os.listdir(path=full_path):
            print(f"    Namespace {namespace}:")
        elif not path_rest:
            print(f"    Namespace {namespace} (empty)")
        elif Path(full_path).is_dir():
            if not os.path.exists(result_file):
                print("      MakeDir", result_file)
                if not dry_run:
                    os.makedirs(result_file, exist_ok=True)
        elif Path(full_path).is_file():
            result_file_dir = os.path.dirname(result_file)
            if not os.path.exists(result_file_dir):
                print("      MakeDir", result_file_dir)
                if not dry_run:
                    os.makedirs(os.path.dirname(result_file), exist_ok=True)
            print(f"      Write {result_file} (source={full_path})")
            should_be_copied = False
            with open(full_path, "r") as f:
                try:
                    first_line = f.readline().strip()
                    should_be_copied = re.match(r".*jinja2:\s*ignore.*", first_line)
                    remove_first_line = True
                except UnicodeDecodeError:
                    should_be_copied = True  # Probably binary file
                    remove_first_line = False
            if should_be_copied:
                if not dry_run:
                    shutil.copyfile(full_path, result_file)
                    if remove_first_line:
                        with open(result_file, 'r') as fin:
                            data = fin.read().splitlines(True)
                        with open(result_file, 'w') as fout:
                            fout.writelines(data[1:])
            else:
                template = env.get_template(path_in_files_dir)
                if not dry_run:
                    with open(result_file, "w") as f2:
                        f2.write(template.render(env_dict))
            if not dry_run:
                shutil.copystat(full_path, result_file)
        else:
            raise ValueError(f"Unknown file type {full_path}")
        continue


def main():
    typer.run(populate)


if __name__ == "__main__":
    main()
