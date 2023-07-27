# tetrio-install
TETR.io installer script that supports system wide or per user installation.

## Usage
```
tetrio-install [OPTIONS]

Options:
    -h, --help		Print this help message.

    -s, --system	Install system wide

    -l, --local		Install for current user
```
## Requirements
`wget`

`dash` or comparable POSIX `/bin/sh`

## Installation
```
wget https://raw.githubusercontent.com/Paradigm0001/tetrio-install/main/tetrio-install.sh
chmod 755 ./tetrio-install.sh
./tetrio-install -l
```
### OR
```
git clone https://github.com/Paradigm0001/tetrio-install
cd ./tetrio-install
chmod 755 ./tetrio-install.sh
./tetrio-install -l
```

### TODO/Ideas:
Impliment an uninstall argument. (Not really necessary)
Impliment an update argument. (Requires keeping track of or checking current TETR.io version)
