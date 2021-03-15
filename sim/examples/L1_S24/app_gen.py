#!/usr/bin/python
import sys

active_app = sys.argv[1]

template = """
### App: {0}
**H_{0}_U1.app.disable  = {1}
**H_{0}_U1.app.msgSQ = {2}
**H_{0}_U1.app.msg2msgGap = {3}ns
**H_{0}_U1.app.msgLength = {4}B
##-------------------------------------
"""
class App:
    def __init__(self, id, sq, gap, length):
        self.id = id
        self.sq = sq
        self.gap = gap
        self.length = length
    def __str__(self):
        return "id: {}, sq: {}, gap: {}, length: {}".format(self.id, self.sq, self.gap, self.length)

gaps = [1, 100, 1000, 10000]
lengths = [512, 512*32, 512*128, 512*512, 512*1024, 512*2048]


apps = []
id = 1
sq = 1

for gap in gaps:
    for length in lengths:
        apps.append(App(id, sq, gap, length))
        id += 1
with open('results/app_table.csv', 'w') as table:
    table.write("{},{},{}\n".format("App", "Computation", "Communication"))
    for app in apps:
        disable = 1
        if str(app.id) == active_app or active_app == "-1":
            disable = 0
        print(template.format(app.id, disable, app.sq, app.gap, app.length))
        table.write("{},{},{}\n".format(app.id, app.gap, app.length))

