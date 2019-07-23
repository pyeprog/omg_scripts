import os
import re


class FNode:
    def __init__(self, file_path, finder=None):
        self.file_path = file_path
        self.finder = finder
        self.content_lines = self.load(self.file_path)
        self.parent_node_set = set()
        self.children_node_set = set()
        self.parse_children_modules(self.content_lines)

    @staticmethod
    def load(file_path):
        assert os.path.isfile(file_path)

        lines = []
        with open(file_path, "r") as fp:
            lines.extend(fp.readlines())
        return lines

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
        print(modules)
        return modules


if __name__ == "__main__":
    node = FNode(
        (
            "/Users/pd1024/Documents/xkool/backend/"
            "xkool_site/controller/residence_controller.py"
        )
    )
