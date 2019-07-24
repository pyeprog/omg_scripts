import re
from typing import List


class Parser:
    def __init__(self, lang="python"):
        self.lang = lang

    def parse_children_modules(self, content_lines: List[str]):
        return getattr(self, "{}_{}".format(self.lang, "parse_children_modules"))(content_lines)

    def get_calling_func(self, parent_fnode, child_fnode, child_class_or_func: str):
        return getattr(self, "{}_{}".format(self.lang, "get_calling_func"))(parent_fnode, child_fnode,
                                                                            child_class_or_func)

    def get_calling_class(self, parent_fnode, child_fnode, child_class_or_func: str):
        return getattr(self, "{}_{}".format(self.lang, "get_calling_class"))(parent_fnode, child_fnode,
                                                                             child_class_or_func)

    @staticmethod
    def python_parse_children_modules(content_lines: List[str]):
        import_patterns = []
        import_patterns.append(re.compile("import (.*)"))
        import_patterns.append(re.compile("from (.*) import (.*)"))
        modules = []
        for line in content_lines:
            for pattern in import_patterns:
                match = re.match(pattern, line)
                if match:
                    groups = match.groups()
                    if len(groups) > 1:  # pattern: from abc import Abc
                        for module_name in groups[1].split(","):
                            modules.append(".".join([groups[0], module_name.strip()]))
                    else:  # pattern: import Abc
                        modules.append(groups[0])
        return modules

    @staticmethod
    def python_get_calling_func(parent_fnode, child_fnode, child_class_or_func: str):
        calling_func = None
        if child_fnode in parent_fnode.children_node_set:
            pattern = re.compile("def (\w*?)\(.*?\):.*?{}".format(child_class_or_func), re.DOTALL)
            matches = re.findall(pattern, parent_fnode.content_str)
            if matches:
                calling_func = matches[0]
        return calling_func

    @staticmethod
    def python_get_calling_class(parent_fnode, child_fnode, child_class_or_func: str):
        calling_class = None
        if child_fnode in parent_fnode.children_node_set:
            pattern = re.compile("class (\w*?):.*?{}".format(child_class_or_func), re.DOTALL)
            matches = re.findall(pattern, parent_fnode.content_str)
            if matches:
                calling_class = matches[0]
        return calling_class
