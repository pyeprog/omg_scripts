from collections import defaultdict


class Result:
    def __init__(self):
        self.relationship = []
        self.root = None

    def add(self, parent_fnode, child_fnode):
        self.relationship.append((parent_fnode, child_fnode))

    def __repr__(self):
        tree = defaultdict(defaultdict)
        parent_to_children = defaultdict(list)
        child_belonging = {}
        for parent, child in self.relationship:
            parent_to_children[parent].append(child)
            child_belonging[child] = parent


