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
        self.setup_tree(self.path_fnode_dict, self.finder)

    def setup_path_fnode_dict(self, root_path, gitignore=False):
        result = {}
        for root, _, fnames in os.walk(root_path):
            for fname in fnames:
                if fname.endswith(".py"):
                    path = os.path.join(root, fname)
                    result[path] = FNode(path)
        return result

    def setup_tree(self, path_fnode_dict, finder):
        for fnode in path_fnode_dict.values():
            for child_module in fnode.children_modules:
                child_fnode = finder.fnode_by_import(child_module)
                if child_fnode:
                    fnode.add_child(child_fnode)
                    child_fnode.add_parent(fnode)

    def query(self, module_path, class_or_func):
        def query_helper(module_path, class_or_func, seen):
            result = []
            start_fnode = self.path_fnode_dict.get(module_path, None)
            if start_fnode and start_fnode not in seen:
                seen.add(start_fnode)
                for parent_fnode in start_fnode.parents:
                    calling_func = parent_fnode.get_calling_func(
                        start_fnode, class_or_func
                    )
                    calling_class = parent_fnode.get_calling_class(
                        start_fnode, class_or_func
                    )
                    calling_item = (
                        calling_class if calling_class else calling_func
                    )
                    if calling_item:
                        result.append(parent_fnode)
                        seen.add(parent_fnode)
                        for grand_parent in parent_fnode.parents:
                            result.extend(
                                query_helper(
                                    parent_fnode.file_path, calling_item, seen
                                )
                            )
            return result

        seen_fnodes = set()
        return query_helper(module_path, class_or_func, seen_fnodes)


if __name__ == "__main__":
    tree = DepsTree("/home/pd/projects/backend")
    usage_fnodes = tree.query(
            "/home/pd/projects/backend/xkool_site/model/residence.py",
            "Residence",
        )
    print('\n'.join([fnode.file_path for fnode in usage_fnodes]))
