import os
import sys
from deps_tree import DepsTree
from query import Query


if __name__ == "__main__":
    root = os.path.abspath(sys.argv[1])
    module = os.path.abspath(sys.argv[2])
    class_or_func = sys.argv[3]

    tree = DepsTree(root)
    query = Query(tree)
    calling_tree = query.find_caller(module, class_or_func)
    print(calling_tree)
