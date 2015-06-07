#!/usr/bin/env python

import glob
import re


def morphgnt():
    FIELDS = ["bcv", "pos", "parse", "robinson", "text", "word", "norm", "lemma"]

    for filename in glob.glob("*-morphgnt.txt"):
        with open(filename) as f:
            for line in f:
                yield dict(zip(FIELDS, line.strip().split()))


class RuleList:

    def __init__(self, filename):
        rulelist = []
        with open(filename) as f:
            for line in f:
                rule = line.split("#")[0].strip()
                if rule:
                    rulelist.append(re.compile(rule))
        self.rulelist = rulelist

    def match(self, data):
        for rule in self.rulelist:
            if rule.match(" ".join(data)):
                return True
        return False


class Counter:
    def __init__(self, show_all=False):
        self.show_all = show_all
        self.success_count = 0
        self.skip_count = 0
        self.fail_count = 0
        self.first_fail = None
        self.first_skip = None

    def success(self):
        self.success_count += 1

    def skip(self, message):
        self.skip_count += 1
        if self.first_skip is None:
            self.first_skip = message

    def fail(self, message):
        if self.show_all:
            print(message)
        self.fail_count += 1
        if self.first_fail is None:
            self.first_fail = message

    def results(self):
        print("{} success; {} fail; {} skipped".format(self.success_count, self.fail_count, self.skip_count))
        if self.first_fail:
            print("first fail: {}".format(self.first_fail))
        if self.first_skip:
            print("first skip: {}".format(self.first_skip))


counter = Counter()


rulelist = RuleList("rulelist.txt")
for row in morphgnt():
    data = [row["pos"], row["parse"], row["robinson"], row["norm"], row["lemma"]]
    if rulelist.match(data):
        counter.success()
    else:
        counter.fail("{}: {}".format(row["bcv"], " ".join(data)))

counter.results()
