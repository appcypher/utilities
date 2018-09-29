#!/bin/bash

# PATHS
# Get current working directory
current_dir=`pwd`

# Get the absolute path of where script is running from
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd)"
script_path="$script_dir/run.sh"

# RETURN VARIABLE
ret=""

# ARGUMENTS
args="${@:2}" # All arguments except the first

# DESCRIPTION:
#	Where execution starts
#
main() {
    case $1 in
		*update-branch* )
			update_branch
		;;
		*get-diff-files* )
			get_diff_files
		;;
		*change-branch-name* )
			change_branch_name ${args[0]}
		;;
		*add-link* )
			add_link ${args[0]} ${args[1]}
		;;
		*remove-link* )
			remove_link ${args[0]}
		;;
		*setup-script* )
			setup_script
		;;
	esac

    exit 0
}

# == GIT HELPERS == #

# DESCRIPTION:
#   If inside a git directory, this function updates the
#   current or specified branch with latest changes from remote.
#
# USAGE:
#	run update-branch [-b branch-to-update]
#
update_branch() {
	local return=""
	local update_branch=""
	local current_branch=$(git branch | grep \* | cut -d ' ' -f2)

	# Confirm deletion of local branch
	confirm "delete this local branch: $current_branch"; return=$ret
	if [[ $return != "Y" ]]; then
		exit 0
	fi

	# Check if -b flag was specified
	get_flag_value -b; return=$ret

	if [[ $return != "" ]]; then
		update_branch=$return
	else
		update_branch=$current_branch
	fi

	displayln "Switch to a temporary branch"
	git checkout origin/$update_branch

	displayln "Delete previous local branch"
	git branch -D $update_branch

	displayln "Fetch all branches"
	git fetch --all

	displayln "Switch back to original branch"
	git checkout $update_branch
}

# DESCRIPTION:
#   Get files that changed or got added on your branch in respect to origin/HEAD
#
# USAGE:
#	run get-diff-files
#
get_diff_files() {
	display "Get last commit has"
	local commit_hash=$(git rev-parse HEAD)

	display "Show diff files"
	git --no-pager diff --name-only $commit_hash origin/HEAD
}

# DESCRIPTION:
#   Change the name of a local branch and its corresponding remote branch
#
# USAGE:
#	run change-branch-name new-branch-name
#
change_branch_name() {
	local old_name=$()
	local new_name=$1

	if [[ -z $1 ]]; then
		echo "You need to provide the new name of the branch"
		exit 1
	fi

	displayln "Change local branch name"
	git branch -m $new_name

	displayln "Change remote branch name"
	git push origin :$old_name $new_name

	displayln "Set local branch to track remote branch"
	git push origin -u $new_name
}

# DESCRIPTION:
#   Adds a symbolic link to a specified file in `/usr/local/bin` where it can be
#   available system-wide
#
# USAGE:
#	run add-link link-name file-to-link
#
add_link() {
	if [[ -z $1 ]]; then
		echo "You need to specify link name!"
		exit 1
	fi

	if [[ -z $2 ]]; then
		echo "You need to specify the file you want to create!"
		exit 1
	fi

	displayln "Add a link to specified file in /usr/local/bin"
	ln -s $2 /usr/local/bin/$1
}

# DESCRIPTION:
#   Removes a symbolic link from `/usr/local/bin`
#
# USAGE:
#	run remove-link symbolic-file
#
remove_link() {
	local return=""

	if [[ -z $1 ]]; then
		echo "You need to provide the symbolic file to delete!"
		exit 1
	fi

	# Confirm deletion of local branch
	confirm "delete this symbolic file: /usr/local/bin/$1"; return=$ret
	if [[ $return != "Y" ]]; then
		exit 0
	fi

	displayln "Check that file is a link"
	if [[ ! -L "/usr/local/bin/$1" ]]; then
		echo "What you specified is not a symbolic link!"
		exit 1
	fi

	displayln "Remove link `/usr/local/bin`"
	rm /usr/local/bin/$1
}

# == HELPER FUNCTIONS == #

# DESCRIPTION:
#	Gets the value following a flag
#
get_flag_value() {
	local found=false
	local key=$1
	local count=0

	# For every argument in the list of arguments
	for arg in $args; do
		count=$((count + 1))
		# Check if any of the argument matches the key provided
		if [[ $arg = $key ]]; then
			found=true
			break
		fi
	done

	local args=($args)
	local value=${args[count]}

	# Check if argument specified was found
	if [[ $found = true ]]; then

		# Check if there exists a word after the key
		# And that such word doesn't start with hyphen
		if [[ ! -z $value ]] && [[ $value != "-"* ]]; then
			ret=$value
		else
			ret=""
		fi

	else
		ret=""
	fi
}

# DESCRIPTION:
#	Sets up the cript by making it excutable and available system wide
#
setup_script() {
	display "Make script executable"
	chmod u+x $script_path

	display "Drop a link to it in /usr/local/bin"
	ln -s $script_path /usr/local/bin/run
}

# TODO: return a number that can be checked fo
# DESCRIPTION:
#	Asks the user for confirmation befor proceeding
#
confirm() {
	printf "\n::: Are you sure you want to $1? [Y/n] "

	read response

	if [[ $response = "Y" ]]; then
		ret="Y"
	else
		ret=""
	fi
}

# DESCRIPTION:
#	A custom print function
#
display() {
	printf "::: $1 :::\n"
}


# DESCRIPTION:
#	A custom print function that starts its output with a newline
#
displayln() {
	printf "\n::: $1 :::\n"
}


main $@
