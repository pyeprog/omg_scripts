import os
from collections import defaultdict


class Finder:
    def __init__(self, root_path, path_fnode_dict):
        self.root_path = root_path
        self.path_tree = self.setup_path_tree(self.root_path)
        self.path_fnode_dict = path_fnode_dict

    def setup_path_tree(root_path):
        # path_tree = defaultdict(list)
        # for name in os.listdir(root_path):
        #     if os.path.isfile(os.path.join(root_path, name)):
        #         path_tree[root_path].appendkkk
        pass


    def fnode_by_import(import_content):
        modules = import_content.split('.')
