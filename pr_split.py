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
        os.popen("git rev-list {}..{}".format(from_, to_)).read().split()[::-1]
    )


def get_cur_branch_name():
    branch_name = os.popen("git branch -a | grep '*' | cut -c3-").read()
    if branch_name.startswith("origin/"):
        branch_name = branch_name[7:]
    return branch_name


def get_changed_line_count(base, branch):
    extract_num = lambda info_str: info_str.split()[0]
    stat_result = (
        os.popen("git diff --stat {}..{}".format(base, branch)).read().split("\n")
    )
    if len(stat_result) == 1 and stat_result[0] == '':
        return 0  # means no difference
    str_info_list = stat_result[-2].split(",")
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
    return len(os.popen("git branch -a | grep '^[\* ] {}'".format(branch)).read().strip()) > 0


def delete_branch(branch):
    if is_branch_exist(branch):
        return 0 == subprocess.call("git branch -D {}".format(branch), shell=True)
    return True


def checkout_and_push(checkout_branch_name, push_branch_name):
    return (
        0 == subprocess.call(
            "git checkout -b {} {} && git push origin {}".format(
                push_branch_name, checkout_branch_name, push_branch_name), shell=True))


def split_commits(base, n_line_threshold):
    cur_branch_name = get_cur_branch_name().strip()
    # align base branch with origin
    assert sync_branch_with_origin(base), "Branch sync failed"
    commit_list = get_new_commit_list(from_=base, to_=cur_branch_name)
    index = 0
    try:
        while index < len(commit_list):
            insertion_cumulation = 0
            commit_count = 0
            for i in range(index, len(commit_list)):
                if i == 0:
                    last_commit = base
                else:
                    last_commit = commit_list[i - 1]
                insertion_cumulation += get_changed_line_count(last_commit, commit_list[i])
                commit_count += 1
                if i == len(commit_list) - 1:
                    index = len(commit_list)
                    assert checkout_and_push(
                        commit_list[i], "{}_{}/{}".format(
                            cur_branch_name, i + 1, len(commit_list))), "checkout and push failed"
                    break
                if insertion_cumulation > n_line_threshold:
                    if commit_count > 1:
                        # new round start from i
                        index = i
                    else:
                        # new round start from i + 1
                        index = i + 1
                    assert checkout_and_push(
                        commit_list[index - 1], "{}_{}/{}".format(
                            cur_branch_name, index + 1, len(commit_list))), "checkout and push failed"
                    break

    except Exception as e:
        print(str(e))
        assert 0 == subprocess.call(
                "git checkout {} -f".format(cur_branch_name), shell=True
                ), "Fatal error: checkout back to {} failed".format(cur_branch_name)
        assert 0 == subprocess.call(
            "git branch -a | grep '^  {}'".format(cur_branch_name + "_") + " | xargs -I {} git branch -D {}",
            shell=True), "Fatal error: recovery failed"
        return 1  # fail status
    print("All done!")
    assert 0 == subprocess.call(
            "git checkout {} -f".format(cur_branch_name), shell=True
            ), "Fatal error: checkout back to {} failed".format(cur_branch_name)
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
