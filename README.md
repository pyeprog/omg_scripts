# tool scripts that might help

## pr_split
Prerequisites:
1. bash
2. python3

Usage:
1. First run the install.sh, `bash install.sh` or `./install.sh`. 
2. cd to your repo
3. `git checkout <branch you wanna push to origin>`
4. `pr_split <branch you wanna merge into>`
5. Check new branch at your origin repo, and make a mr/pr for merging
6. After approval and merge, go back to step 4 to make another mr/pr

This script will create an new branch which includes commits that have at most 500 lines insertion in total and push it to origin.
If a special commit contains more than 500 lines insertion, then a new branch is created by this single commit.

Enjoy:)
