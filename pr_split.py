#!/usr/bin/python3
# Author: Pye Douglas
# Data: 2019.5.30
# Description: This script is used for spliting your giant pr/mr into several small pr/mr.
# Usage:
# 1. run install.sh
# 2. cd into your repo, checkout your branch that you want to push and merge, then python3 pr_split.py <target_merge_base>

from __future__ import print_function
from __future__ import division
from __future__ import unicode_literals
from __future__ import absolute_import

import os
import sys
import subprocess


def is_git_available():
    return 0 == subprocess.call("git branch -a", shell=True)


def fetch():
    return 0 == subprocess.call("git fetch --all", shell=True)


def get_new_commit_list(from_, to_):
    # from oldest to latest
    return (
        os.popen("git rev-list origin/{}..{}".format(from_, to_)).read().split()[::-1]
    )


def get_cur_branch_name():
    return os.popen("git branch -a | grep '*' | cut -c3-").read()


def get_changed_line_count(base):
    extract_num = lambda info_str: info_str.split()[0]
    stat_result = (
        os.popen("git diff --stat origin/{}..HEAD".format(base)).read().split("\n")[-2]
    )
    str_info_list = stat_result.split(",")
    for str_info in str_info_list:
        if "insert" in str_info.lower():
            insertion_line_count = extract_num(str_info)
            return int(insertion_line_count)
    return 0  # means no insertion found


def sync_branch_with_origin(branch):
    fetch()
    cur_branch_name = get_cur_branch_name().strip()
    assert 0 == subprocess.call(
        "git checkout {} && git reset origin/{} --hard".format(branch, branch),
        shell=True,
    ), "Sync branch failed"
    return (
        0 == subprocess.call("git checkout {}".format(cur_branch_name), shell=True),
        "checkout back failed",
    )


def is_branch_exist(branch):
    return len(os.popen("git branch -a | grep {}".format(branch)).read().strip()) > 0


def delete_branch(branch):
    if is_branch_exist(branch):
        return 0 == subprocess.call("git branch -D {}".format(branch), shell=True)
    return True


def split_commits(base, n_line_threshold):
    cur_branch_name = get_cur_branch_name().strip()
    # align base branch with origin
    assert sync_branch_with_origin(base), "Branch sync failed"

    # those branches that should be deleted after push the commits
    delete_target_branches = []
    try:
        # create temp branch
        tmp_branch_name = cur_branch_name + "_tmp"
        delete_target_branches.append(tmp_branch_name)
        assert 0 == subprocess.call(
            "git checkout -b {} {}".format(tmp_branch_name, base), shell=True
        ), "Creating branch failed"

        commit_list = get_new_commit_list(from_=base, to_=cur_branch_name)
        line_insertion_count = 0
        consume_commit_count = 0
        print("Total commit number: {}".format(len(commit_list)))
        for commit in commit_list:
            assert 0 == subprocess.call(
                "git cherry-pick {}".format(commit), shell=True
            ), "Cherry pick commit {} failed".format(commit)
            print("commit {} merged".format(commit))
            consume_commit_count += 1
            line_insertion_count += get_changed_line_count(base)
            if line_insertion_count >= n_line_threshold:
                if consume_commit_count > 1:
                    # more than 1 commit, then reset to last commit
                    assert 0 == subprocess.call(
                        "git reset HEAD^ --hard", shell=True
                    ), "Reset back failed"
                    consume_commit_count -= 1
                break

        # rename the branch
        expected_branch_name = cur_branch_name + "_{}_commit_remained".format(
            len(commit_list) - consume_commit_count
        )
        delete_target_branches.append(expected_branch_name)
        assert 0 == subprocess.call(
            "git branch -m {}".format(expected_branch_name), shell=True
        ), "branch rename failed"

        # push the branch to origin
        assert 0 == subprocess.call(
            "git push origin {}".format(expected_branch_name), shell=True
        ), "push to origin failed"

        # checkout origin branch
        assert 0 == subprocess.call(
            "git checkout {}".format(cur_branch_name), shell=True
        ), "back to origin branch failed"
    except Exception as e:
        print(str(e))
        assert 0 == subprocess.call(
            "git checkout {}".format(cur_branch_name), shell=True
        ), "Fatal error: cannot recover context"
        # recover branch
        assert all(
            [delete_branch(branch) for branch in delete_target_branches]
        ), "Fatal error: cannot delete temp or sub pr/mr branches"
        return 1  # fail status
    print("All done!")
    return 0  # success status


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Split your giant pr/mr into serveral small pr/mr"
    )
    parser.add_argument(
        "target_branch",
        metavar="target_branch",
        type=str,
        help="the target branch you want to merge into",
    )
    parser.add_argument("--per", nargs="?", const=500, type=int)
    args = parser.parse_args()

    target_branch = args.target_branch
    split_per = 500 if args.per is None else args.per
    sys.exit(split_commits(base=target_branch, n_line_threshold=split_per))
