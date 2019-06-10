# tool scripts that might help

## pr_split
Prerequisites:
1. bash
2. python3

Usage:
1. First run the install.sh, `bash install.sh` or `./install.sh`. 
2. cd to your repo
3. `git checkout <branch you wanna push to origin>`
4. `pr_split <branch you wanna merge into>` or `pr_split <branch you wanna merge into> --per 300` to specify line insertion upper bound.
5. Check new branch at your origin repo, and make mr/pr(s) for merging.
    5.1 You will find multiple branch with postfix <cur commit num>/<total commit num> alike on the remote server.
    5.2 Create mr/pr in the manner of base <- 2/14, 2/14 <- 6/14, 6/14 <- 14/14.
    5.3 After each mr/pr(s) approved, merge them in reverse order as above. E.g. 6/14 <- 14/14, 2/14 <- 6/14, base <- 2/14. Otherwise, conflict will occur.


This script will create an new branch which includes commits that have at most N lines insertion in total and push it to origin.
If a special commit contains more than 500 lines insertion, then a new branch is created by this single commit.

Enjoy:)
