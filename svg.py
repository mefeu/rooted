from  lxml import etree as ET
import svgling
from svgling.figure import Caption, SideBySide, RowByRow

tree = ET.parse('tree.xml')

def treeForEval(tree):
	if len(tree.getchildren()) == 0:
		out = '"' + tree.attrib['text'] + '"'
		return out
	else:
		count = len(tree.getchildren())
		it = 0
		out = '"' + tree.attrib['text'] + '"'
		while it < count:
			out += ", (" + treeForEval(tree.getchildren()[it]) + ")"
			it += 1
	return out

for elem in tree.iter():
	if 'text' in elem.attrib:
		if elem.attrib['text'] == 'Life':
			t = svgling.draw_tree(eval(treeForEval(elem)))
			t.get_svg().saveas("tree.svg")
