from  lxml import etree as ET

tree = ET.parse('tree_bak.xml')
root = ET.Element("top")
cnt = 0
#print(ET.tostring(tree, pretty_print=True))

def treeWidth(tree):
    if len(tree.getchildren()) == 0:
        return 1
    else:
        count = len(tree.getchildren())
        it = 0
        width = 0
        while it < count:
            width = width + treeWidth(tree.getchildren()[it])
            it = it + 1
        return width

def treeDepth(node):
    depth = 0
    while node is not None:
        depth += 1
        node = node.getparent()
    return depth
#print(ET.tostring(tree.getroot()))

#print(treeWidth(tree.getroot()))
for elem in tree.iter():
    print(treeDepth(elem))
    #print(elem.attrib)
    print(treeWidth(elem))
    elem.set('width', value=str(treeWidth(elem)).encode("utf-8").decode("utf-8"))
    elem.set('depth', value=str(treeDepth(elem)).encode("utf-8").decode("utf-8"))
#    print(ET.tostring(elem))
hallo="""
    if 'id' in elem.attrib:
        if elem.attrib['id'] == '200000':
        #print(elem.tag)
            #print(ET.tostring(elem))
            parent = elem.getparent()
            #print(len(parent.getchildren()))
            #print(parent.getchildren())
            #print(parent.getchildren()[0])
            x = 0
            while x < len(parent.getchildren()):
                if parent.getchildren()[x].attrib['id'] == '200000':
                    #print("if true")
                    #print(x)
                    #print(ET.tostring(parent.getchildren()[x]))
                    tmp = parent.getchildren()[x]
                    parent.remove(parent.getchildren()[x])
                    #print('--------------------------')
                    #print('removed')
                    #print(ET.tostring(parent.getchildren()[0]))
                    parent.append(tmp)
                    #print('--------------------------')
                    #print(ET.tostring(parent))
                x = x + 1
            parent.remove(parent.getchildren()[0])
            #print(parent.getchildren())
            #print(ET.tostring(tree, pretty_print=True)) 
"""
print(ET.tostring(tree, pretty_print=True))
with open('./tree.xml', 'w') as f:
    f.write(ET.tostring(tree, pretty_print=True).decode("utf-8"))
