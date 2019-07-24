import os
import re


class FNode:
    def __init__(self, file_path):
        self.file_path = file_path
        self.content_lines = self.load(self.file_path)
        self.content_str = "\n".join(self.content_lines)
        self.parent_node_set = set()
        self.children_node_set = set()
        self.children_modules = self.parse_children_modules(self.content_lines)

    @staticmethod
    def load(file_path):
        assert os.path.isfile(file_path)

        lines = []
        with open(file_path, "r") as fp:
            lines.extend(fp.readlines())
        return lines

    @property
    def parents(self):
        return list(self.parent_node_set)

    @property
    def children(self):
        return list(self.children_node_set)

    def add_parent(self, node):
        self.parent_node_set.add(node)

    def add_child(self, node):
        self.children_node_set.add(node)

    def parse_children_modules(self, content: str):
        import_patterns = []
        import_patterns.append(re.compile("import (.*)"))
        import_patterns.append(re.compile("from (.*) import (.*)"))
        modules = []
        for line in self.content_lines:
            for pattern in import_patterns:
                match = re.match(pattern, line)
                if match:
                    groups = match.groups()
                    if len(groups) > 1:  # pattern: from abc import Abc
                        for module_name in groups[1].split(","):
                            modules.append(
                                ".".join([groups[0], module_name.strip()])
                            )
                    else:  # pattern: import Abc
                        modules.append(groups[0])
        return modules

    def get_calling_func(self, child_fnode, child_class_of_func):
        calling_func = None
        if child_fnode in self.children_node_set:
            pattern = re.compile(
                "def (\w*?)\(.*?\):.*?{}".format(child_class_of_func),
                re.DOTALL,
            )
            matches = re.findall(pattern, self.content_str)
            if matches:
                calling_func = matches[0]
        return calling_func

    def get_calling_class(self, child_fnode, child_class_of_func):
        calling_class = None
        if child_fnode in self.children_node_set:
            pattern = re.compile(
                "class (\w*?):.*?{}".format(child_class_of_func),
                re.DOTALL,
            )
            matches = re.findall(pattern, self.content_str)
            if matches:
                calling_class = matches[0]
        return calling_class

    def get_calling_class(self, child_fnode, child_class_of_func):

        if __name__ == "__main__":
            node = FNode(
                (
                    "//home/pd/projects/backend/"
                    "xkool_site/controller/residence_controller.py"
                )
            )
