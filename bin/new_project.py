#!/usr/bin/env python3
import argparse
import os
import sys

def validate_name(name:str) -> None:
    if "-" in name:
        print(f"{name} cannot have a '-' character.")
        sys.exit(1)
    if " " in name:
        print(f"{name} cannot have a ' ' character.")
        sys.exit(1)
    if os.path.isdir(name):
        print(f"{name} already exists!")
        sys.exit(1)

def create_project(name: str, use_rust: bool) -> None:
    os.system(f"git clone https://github.com/alexandrepoulin/python_project_starter {name}")
    os.chdir(name)
    os.system("git remote remove origin")
    if use_rust:
        os.system(f"sed -i 's/$MYPROJECT/{name}/g' rust/Cargo.toml")
        os.system("rm pyproject_norust.toml")
    else:
        os.system("rm pyproject.toml")
        os.system("rm -rf rust")
        os.system("mv pyproject_norust.toml pyproject.toml")
    os.system(f"sed -i 's/$MYPROJECT/{name}/g' pyproject.toml")
    os.system(f"sed -i 's/$MYPROJECT/{name}/g' tests/test_all.py")
    os.system(f"sed -i 's/$MYPROJECT/{name}/g' src/project_starter/__main__.py")
    os.rename("src/project_starter",f"src/{name}")
    

def main():
    parser = argparse.ArgumentParser(
                    prog='new_project',
                    description='Create a new project with from the template project_name in the current directory',
                )
    parser.add_argument("project_name", type=str, help='Name of the project')
    parser.add_argument("-r", "--rust", action='store_true', help='Create a maturin based project for to use Rust')
    args = parser.parse_args()
    name = args.project_name
    validate_name(name)
    create_project(name, args.rust)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
