import os
from fnode import FNode
from finder import Finder


class DepsTree:
    def __init__(self, root_path, gitignore=False):
        self.root_path = root_path
        self.path_fnode_dict = self.setup_path_fnode_dict(
            self.root_path, gitignore
        )
        self.finder = Finder(self.root_path, self.path_fnode_dict)

    def setup_path_fnode_dict(self, root_path, gitignore=False):
        result = {}
        for root, _, fnames in os.walk(root_path):
            for fname in fnames:
                if fname.endswith(".py"):
                    path = os.path.join(root, fname)
                    result[path] = FNode(path)
        return result


if __name__ == "__main__":
    tree = DepsTree("/Users/pd1024/Documents/xkool/backend")
    print(tree.path_fnode_dict)
