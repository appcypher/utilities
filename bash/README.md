A folder containing all bash scripts I use often

## run.sh

This script makes certain repetitive tasks a single command effort.

The script can be setup to be availaible system-wide by running:
> ```bash
> bash /path/to/run.sh setup-script
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

* Get changed files.

    You get the files that changed or got added on your branch in respect to origin/HEAD

    > ```bash
    > run get-diff-files
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

