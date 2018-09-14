A folder containing all bash scripts I use often

## run.sh

This script makes certain repetitive tasks a single command effort.

The script can be setup to be availaible system-wide by running:
> ```bash
> bash /path/to/run.sh setup-script
> ```

### FEATURES
#### GIT HELPERS
* Updating a branch.

    WARNING!: This deletes the local branch including all the changes made to it

    * You can update the current branch with latest updates from `remote`
        > ```bash
        > run update-branch
        > ```

    * You can also specify which branch you wish to update with the `-b` flag
        > ```bash
        > run update-branch -b develop
        > ```

