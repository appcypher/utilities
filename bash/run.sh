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

# COLORS
red='\033[0;31m'
green='\033[0;32m'
none='\033[0m'

# DESCRIPTION:
#	Where execution starts
#
main() {
    case $1 in
		update-branch )
			update_branch
		;;
		get-diff-files )
			get_diff_files
		;;
		change-branch-name )
			change_branch_name ${args[0]}
		;;
		add-link )
			add_link ${args[0]} ${args[1]}
		;;
		remove-link )
			remove_link ${args[0]}
		;;
		setup-script )
			setup_script
		;;
		tell )
			tell_when_done $args
		;;
		concat-files )
			concat_files ${args[@]}
		;;
		--help|help|-h )
			help
		;;
	esac

    exit 0
}

# == GIT HELPERS == #

help() {
	echo ""
	echo "================================================================================="
	echo "======================== RUN UTILITIES =========================================="
	echo "================================================================================="
	echo "[USAGE] : run [comand] [...args]"
	echo "[COMMAND] :"
	echo " > help                               - print this help message"
	echo " > update-branch -b [name]            - update a branch with changes from remote"
	echo " > get-diff-files                     - get file changed in current branch"
	echo " > change-branch-name [name]          - change the name of branch"
	echo " > add-link [name] [file]             - make file accessible system-wide"
	echo " > remove-link [name]                 - remove link to file"
	echo " > tell                               - tell when command is done"
	echo " > setup-script                       - set up this command"
	echo " > concat-files [dir] [pattern] [out] - concatenate matching files"
	echo "================================================================================="
	echo ""
}


# DESCRIPTION:
#   If inside a git directory, this function updates the
#   current or specified branch with latest changes from remote.
#
# USAGE:
#	run update-branch [-b branch-to-update]
#
update_branch() {
	local update_branch=""
	local current_branch=$(git branch | grep \* | cut -d ' ' -f2)

	# Confirm deletion of local branch
	if confirm "delete this local branch: $current_branch"; then
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
	if [[ -z $1 ]]; then
		echo "You need to provide the symbolic file to delete!"
		exit 1
	fi

	if confirm "delete this symbolic file: /usr/local/bin/$1"; then
		echo "Exiting"
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

# DESCRIPTION:
# 	Tells when command is done.
#
# USAGE:
#	run tell sleep 5
#
tell_when_done() {
	$@ # Run the command

	local status=$? # Get the exit code

	if [[ $status -eq 0 ]]; then
		echo -e "+ ${green}exit code: $status"
		for i in {1..10};
		do
			say "Command run successfully"
			say "The command is ${args[0]}"
			sleep 2
		done
	else
		echo -e "+ ${red}exit code: $status"
		for i in {1..10};
		do
			say "Command stopped running"
			say "The command that stopped is ${args[0]}"
			say "The exit code is $status"
			sleep 2
		done
		exit $status
	fi
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

# DESCRIPTION:
#   Concatenates all files matching a pattern in a directory
#   and writes them to an output file with headers
#
# USAGE:
#   run concat-files [directory] [pattern] [output]
#   Examples:
#   run concat-files                    # Uses defaults: ./src "*.rs" ./combined.txt
#   run concat-files ./code "*.go"      # Custom dir and pattern
#   run concat-files src "*.rs" out.txt # All parameters custom
#
concat_files() {
    local dir=${1:-"./src"}        # Default to ./src if not provided
    local pattern=${2:-"*.rs"}     # Default to *.rs if not provided
    local output=${3:-"combined.txt"} # Default output file

    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        echo -e "${red}Error: Directory '$dir' does not exist${none}"
        exit 1
    fi

    # Create/clear output file
    > "$output"

    # Find matching files and process each one
    find "$dir" -type f -name "$pattern" | while read -r file; do
        # Get relative path from input directory
        local rel_path=${file#"$dir/"}

        # Add header
        echo "=====================================================" >> "$output"
        echo "File: $rel_path" >> "$output"
        echo "=====================================================" >> "$output"
        echo "" >> "$output"

        # Add file contents
        cat "$file" >> "$output"
        echo "" >> "$output"
        echo "" >> "$output"
    done

    local count=$(find "$dir" -type f -name "$pattern" | wc -l)
    echo -e "${green}Successfully concatenated $count files to $output${none}"
}

# DESCRIPTION:
#	Asks the user for confirmation befor proceeding
#
confirm() {
	printf "\n::: Are you sure you want to $1? [Y/n] "

	read response

	if [[ $response = "Y" ]]; then
		return 1
	else
		return 0
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

