A folder containing all bash scripts I use often

## run.sh

This script makes certain repetitive tasks a single command effort.

### SETUP
* Clone the repository: 
	> ```bash
	> git clone https://github.com/appcypher/utilities.git
	> ```

* Setup  the script to be availaible system-wide:
	> ```bash
	> bash utilities/bash/run.sh setup-script
	> ```

* But, you can always run the script via the bash command:
	> ```bash
	> bash utilities/bash/run.sh [arguments]
	> ```

### FEATURES
##### GIT HELPERS
* Updating a branch.

    WARNING!: This deletes the local branch including all the changes made to it

    You can update the current branch with latest updates from `remote`

    > ```bash
    > run update-branch
    > ```

    You can also specify which branch you wish to update with the `-b` flag

    > ```bash
    > run update-branch -b develop
    > ```

* Getting changed files.

    You can get the files that changed or got added on your branch with respect to origin/HEAD

    > ```bash
    > run get-diff-files
    > ```

* Changing the name of the current local branch and its corresponding remote branch

    > ```bash
    > run change-branch-name new-branch-name
    > ```

##### FILE HELPERS

* Adding Adds a symbolic link to a specified file in `/usr/local/bin` where it can be available system-wide

    > ```bash
    > run add-link link-name file-to-link
    > ```

* Removes a symbolic link from `/usr/local/bin`

    > ```bash
    > run remove-link symbolic-file
    > ```

##### USEFUL BASH FUNCTIONS
* Getting the running script's path

    > ```bash
    > script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd)"
    > ```

* Getting the value following a specified flag

    If a script accepts a `-b` flag, say

    > ```bash
    > run update-branch -b develop
    > ```

    The `-b` flag value can be gotten like so

    > ```bash
    > # Checking if -b flag is specified
    > local return=""
    >
	> get_flag_value -b; return=$ret
    >
    > if [[ $return != "" ]]; then
	>     update_branch=$return
	> fi
    > ```

* Getting confirmation on action before proceeding

    If there is a destructive operation that you'd like to notify the user about, you can use the `confirm` function

    > ```bash
    > confirm "delete this folder"
    > ```

    A prompt shows that asks the user to

