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
		*setup-script* )
			setup_script
		;;
	esac

    exit 0
}

# == GIT HELPERS == #

# DESCRIPTION:
#	If inside a git directory, this function updates the
#   current or specified branch with latest changes from remote.
#
# USAGE:
#	do update-branch [-b branch-to-update] [-s switch-branch]
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

	display "Switch to a temporary branch"
	git checkout origin/$update_branch

	display "Delete previous local branch"
	git branch -D $update_branch

	display "Fetch all branches"
	git fetch --all

	display "Switch back to original branch"
	git checkout $update_branch
}

# == USEFUL FUNCTIONS == #

# DESCRIPTION:
#	Gets the value following a flag
#
get_flag_value() {
	local found=false
	local key=$1
	local count=0

	# Look for the argument in the list of arguments
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
	printf "\n::: $1 :::\n"
}


main $@
