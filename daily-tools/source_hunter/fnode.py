import os
from uuid import uuid4
from typing import List

from constant import postfix_mapping
from parser import Parser


class FNode:
    def __init__(self, file_path):
        self.id = uuid4()
        self.file_path = file_path
        self.parser = Parser(postfix_mapping[self.file_path.split(".")[-1]])
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

    def parse_children_modules(self, content_list: List[str]):
        return self.parser.parse_children_modules(content_list)

    def get_calling_func(self, child_fnode, child_class_or_func: str):
        return self.parser.get_calling_func(self, child_fnode, child_class_or_func)

    def get_calling_class(self, child_fnode, child_class_or_func: str):
        return self.parser.get_calling_class(self, child_fnode, child_class_or_func)
