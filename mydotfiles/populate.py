#!/usr/bin/env python3
import os
import os.path
import glob
import platform
import yaml
import json
import shutil
import getpass
import re
import xdgappdirs
import tempfile
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
import typer
from cryptography.fernet import Fernet

from typing import List


app = typer.Typer()


SCRIPT_DIR = os.path.join(os.path.expanduser("~/.dotfiles"))
FILES_DIR = os.path.join(SCRIPT_DIR, "files")
CONFIG_PATH = os.path.join(SCRIPT_DIR, "environment.yml")

KEY_PATH = os.path.expanduser("~/.mydotfiles.key")


@app.command()
def genkey():
    if os.path.exists(KEY_PATH):
        raise ValueError(f"Key already exists: {KEY_PATH}")
    key = Fernet.generate_key()
    with open(KEY_PATH, "wb") as key_file:
        key_file.write(key)
    os.chmod(KEY_PATH, 0o600)


@app.command()
def encryptfile(filenames: List[str], dont_remove_original: bool = typer.Option(False, "-n", "--no-rm", help="Don't remove the original file")):
    for filename in filenames:
        if not os.path.exists(filename):
            raise ValueError(f"File {filename} does not exist")

    for filename in filenames:
        key = load_key()
        if not key:
            raise ValueError("No key configured")
                
        with open(filename, "rb") as file:
            file_data = file.read()

        file_data = key.encrypt(file_data)

        with open(filename + ".encrypted", "wb") as file:
            file.write(file_data)

        shutil.copystat(filename, filename + ".encrypted")
        if not dont_remove_original:
            os.remove(filename)


@app.command()
def decryptfile(filenames: List[str], dont_remove_original: bool = typer.Option(False, "-n", "--no-rm", help="Don't remove the original file")):
    for filename in filenames:
        if not os.path.exists(filename):
            raise ValueError(f"File {filename} does not exist")

    for filename in filenames:
        key = load_key()
        if not key:
            raise ValueError("No key configured")
                
        with open(filename, "rb") as file:
            file_data = file.read()

        file_data = key.decrypt(file_data)

        orig_filename = filename
        filename = re.sub(r"\.encrypted$", "", filename)

        with open(filename, "wb") as file:
            file.write(file_data)

        shutil.copystat(orig_filename, filename)
        if not dont_remove_original:
            os.remove(orig_filename)


def load_key():
    if os.path.exists(KEY_PATH):
        with open(KEY_PATH, "rb") as f:
            return Fernet(f.read())
    return None
    

@app.command()
def populate(dry_run: bool = typer.Option(False, "-n", "--dry-run", help="Don't do anything")):
    print("mydotfiles:")
    _system = platform.system().lower()

    if _system == "darwin":
        _system = "osx"
    print(f"  Running on sytem: {_system.upper()}")

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
            tmpdirname = os.path.expanduser("~")
        new_files = []
        new_files += process_files(os.path.join(SCRIPT_DIR, "files"), tmpdirname, final_env, dry_run)
        if private_dotfiles_location:
            new_files += process_files(
                os.path.join(private_dotfiles_location, "files"), tmpdirname, final_env, dry_run
            )
        if not dry_run:
            copytree(tmpdirname, os.path.expanduser("~"))

        new_files = [f.replace(tmpdirname, "") for f in new_files]
        new_files = [re.sub("^~/", "", f) for f in new_files]
        new_files = [re.sub("^/", "", f) for f in new_files]

        remove_nonexisting_from_target(new_files, os.path.expanduser("~"), dry_run=dry_run)

        if not dry_run:
            write_config(final_env,
                         os.path.join(os.path.expanduser("~"), ".mydotfiles.conf.json"))

    if not dry_run:
        print(
            "Dotfiles populated (Consider running ~/install.sh to install required packages)"
        )

def write_config(env, targetfile):
    print(f"Write used configuration to home dir: {targetfile}")
    with open(targetfile, 'w', encoding='utf-8') as f:
        json.dump(env, f, ensure_ascii=False, indent=4)
    os.chmod(targetfile, 0o600)


def copytree(src, dst):
    print(f"Copy generated files to {dst}")
    shutil.copytree(src, dst, dirs_exist_ok=True)


def remove_nonexisting_from_target(filenames_new, targetdir, dry_run=False):
    datafilename = os.path.join(targetdir, ".mydotfiles-populate-last.txt")
    if os.path.exists(datafilename):
        print("Checking files for removal...")
        filenames_last = []
        with open(datafilename, "r") as f:
            lines = f.read().split("\n")
            for line in lines:
                if line.strip():
                    filenames_last.append(line.strip())
        for file in filenames_last:
            if file not in filenames_new:
                if os.path.exists(os.path.join(targetdir, file)):
                    print(f"  Remove file: '{os.path.join(targetdir, file)}'")
                    if not dry_run:
                        os.remove(os.path.join(targetdir, file))

    if not dry_run:
        with open(datafilename, "w") as f:
            for file in filenames_new:
                f.write(f"{file}\n")
        os.chmod(datafilename, 0o600)


def process_files(files_dir: str, target_dir: str, env_dict: dict, dry_run: bool) -> List[str]:
    new_files = []
    files_dir = os.path.realpath(files_dir)
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
            home_dir = os.path.expanduser("~")
            user_config_dir = xdgappdirs.user_config_dir()
            if not user_config_dir.startswith(home_dir):
                raise ValueError(f"Cannot create special files in user config dir: {user_config_dir}")
            result_dir = user_config_dir.replace(home_dir, result_dir)
        elif namespace.startswith("_special"):
            raise ValueError(f"Invalid special path: {namespace}")

        result_file = os.path.join(result_dir, path_rest)

        if not path_rest and os.listdir(path=full_path):
            print(f"    Namespace {namespace}:")
        elif not path_rest:
            print(f"    Namespace {namespace} (empty)")
        elif Path(full_path).is_symlink():
            result_file_dir = os.path.dirname(result_file)
            if not os.path.exists(result_file_dir):
                print("      MakeDir", result_file_dir)
                if not dry_run:
                    os.makedirs(os.path.dirname(result_file), exist_ok=True)
                    shutil.copystat(os.path.dirname(full_path), os.path.dirname(result_file))

                    shutil.copystat(os.path.dirname(full_path), os.path.dirname(result_file))
            linkto = os.readlink(full_path)
            print(f"      Create symlink {result_file} (source={full_path}, link_dest={linkto})")
            if not dry_run:
                os.symlink(linkto, result_file)
        elif Path(full_path).is_dir():
            if not os.path.exists(result_file):
                print("      MakeDir", result_file)
                if not dry_run:
                    os.makedirs(result_file, exist_ok=True)
                    shutil.copystat(full_path, result_file)
        elif Path(full_path).is_file():
            result_file_dir = os.path.dirname(result_file)
            if not os.path.exists(result_file_dir):
                print("      MakeDir", result_file_dir)
                if not dry_run:
                    os.makedirs(os.path.dirname(result_file), exist_ok=True)
                    shutil.copystat(os.path.dirname(full_path), os.path.dirname(result_file))

            print(f"      Write {result_file} (source={full_path})")
            isbinary = False
            if result_file.endswith(".encrypted"):
                result_file = re.sub(r"\.encrypted$", "", result_file)
                unencrypted_path = re.sub(r"\.encrypted$", "", full_path)
                try:
                    decryptfile([full_path], dont_remove_original=True)
                    try:
                        with open(unencrypted_path, "r") as unencrypted_file:
                            file_data = unencrypted_file.read()
                    except UnicodeDecodeError:
                        isbinary = True
                        with open(unencrypted_path, "rb") as unencrypted_file:
                            file_data = unencrypted_file.read()
                finally:
                    try:
                        os.remove(unencrypted_path)
                    except:
                        pass
            else:
                try:
                    with open(full_path, "r") as orig_file:
                        file_data = orig_file.read()
                except UnicodeDecodeError:
                    isbinary = True
                    with open(full_path, "rb") as orig_file:
                        file_data = orig_file.read()
            new_files.append(result_file)

            should_be_copied = True
            remove_first_line = False
            if not isbinary:
                file_data_lines = file_data.split("\n")
                if len(file_data_lines) > 0:
                    first_line = file_data_lines[0].strip()
                    should_be_copied = re.match(r".*jinja2:\s*ignore.*", first_line)
                    remove_first_line = True

            if should_be_copied:
                if not dry_run:
                    flags = "wb" if isbinary else "w"
                    with open(result_file, flags) as result_file_handler:
                        result_file_handler.write(file_data)
                    if remove_first_line:
                        with open(result_file, 'r') as fin:
                            data = fin.read().splitlines(True)
                        with open(result_file, 'w') as fout:
                            fout.writelines(data[1:])
            else:
                with tempfile.TemporaryDirectory() as tmpdirname:
                    templatepath = os.path.join(tmpdirname, os.path.basename(full_path))
                    with open(templatepath, "w") as templatepath_file:
                        templatepath_file.write(file_data)

                    env = Environment(
                        loader=FileSystemLoader(tmpdirname), trim_blocks=True, lstrip_blocks=True
                    )

                    template = env.get_template(os.path.basename(templatepath))
                    if not dry_run:
                        with open(result_file, "w") as f2:
                            f2.write(template.render(env_dict))

            if not dry_run:
                shutil.copystat(full_path, result_file)
        else:
            raise ValueError(f"Unknown file type {full_path}")
        continue
    return new_files


def main():
    app()


if __name__ == "__main__":
    main()
