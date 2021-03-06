# .dotfiles
These are my dotfiles.

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/evyli/evalsys/graphs/commit-activity)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![made-with-python](https://img.shields.io/badge/Made%20with-Python-1f425f.svg)](https://www.python.org/)
[![Linux](https://svgshare.com/i/Zhy.svg)](https://svgshare.com/i/Zhy.svg)
[![macOS](https://svgshare.com/i/ZjP.svg)](https://svgshare.com/i/ZjP.svg)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

The repository should be cloned to `~/.dotfiles`.

To install the required packages run `~/.dotfiles/install.sh`.

It can be simply used by installing the python package with `pip install -e .` which will install all dependencies.

Then run `mydotfiles populate` to install the dotfiles.

It requires additionally a private dotfile folder (`~/.dotfiles-private` per default, but changeable) with private or machine dependent settings.

These settings (`~/.dotfiles-private/environment.yaml`) are:
```
private:
  git:
    name: <Your git commit name>
    mail: <Your git commit email>
    signingkey: "0x<Your git gnupg key id>"
  gnupg:
    keyid: "0x<Your default key id>"
  user:
    name: <Your name>
    mail: <Your email>
  dirs:
    cloud: <Path to your cloud storage folder>
    src: <Path to your root source code folder>
    projects: <Path to your folder inside <src> where the projects are stored>
    website: <Path to your repository of your website, if applicable>
```

## License
Copyright (C)  2022 Leah Lackner

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.