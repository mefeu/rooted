import http.server
import socketserver
from urllib.parse import urlparse
from urllib.parse import parse_qs
from lxml import etree as ET
import svgling
from svgling.figure import Caption, SideBySide, RowByRow


def treeWidth(tree):
    if len(tree.getchildren()) == 0:
        return 1
    else:
        count = len(tree.getchildren())
        it = 0
        width = 0
        while it < count:
            width = width + treeWidth(tree.getchildren()[it])
            it += 1
        return width


def treeDepth(node):
    depth = -1
    while node is not None:
        depth += 1
        node = node.getparent()
    return depth


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


class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Sending an '200 OK' response
        self.send_response(200)

        query_components = parse_qs(urlparse(self.path).query)
        if query_components != None:
            print(query_components)
        tree = ET.parse('tree.xml')
        name = None
        addAs = None
        ref = None
        if 'addAs' in query_components:
            addAs = query_components["addAs"][0]
        if 'name' in query_components:
            name = query_components["name"][0]
        if 'ref' in query_components:
            ref = query_components["ref"][0]
        if 'delete' in query_components:
            for elem in tree.iter():
                if 'text' in elem.attrib:
                    if elem.attrib['text'] == name:
                        parent = elem.getparent()
                        children = elem.getchildren()
                        parent.remove(elem)
                        it = 0
                        while it < len(children):
                            parent.append(children[it])
                            it += 1
                        with open('./tree.xml', 'w') as f:
                            f.write('<?xml version="1.0" encoding="utf-8"?>\n')
                        with open('./tree.xml', 'a') as f:
                            f.write(ET.tostring(
                                tree, pretty_print=True).decode("utf-8"))
                        self.send_header("Content-type", "text/html")
                        self.end_headers()
                        html = f'<html><head><meta http-equiv="refresh" content="0.1; url=https://rooted.ddnss.de/tree.xml" /></head><body><h1>Deleting...</h1></body></html>'
                        self.wfile.write(bytes(html, "utf8"))
                        print("feddisch delete")
                        return

        for elem in tree.iter():
            if 'text' in elem.attrib:
                if name == elem.attrib['text']:
                    self.send_header("Content-type", "text/html")
                    self.end_headers()
                    html = f'<html><head><meta http-equiv="refresh" content="10; url=https://rooted.ddnss.de/tree.xml" /></head><body>Species <b>' + name + \
                        '</b> already in tree.<br/><a href="https://rooted.ddnss.de/tree.xml?delete=true&name=' + \
                        name + '"><button>Delete ' + name + '</button></a></body></html>'
                    self.wfile.write(bytes(html, "utf8"))
                    return

        for elem in tree.iter():
            # print(treeDepth(elem))
            # print(elem.attrib)
            # print(treeWidth(elem))
            if 'text' in elem.attrib:
                if addAs == 'child':
                    if elem.attrib['text'] == ref:
                        new = ET.fromstring('<node text="' + name + '"/>')
                        print(new)
                        elem.append(new)
                        self.send_header("Content-type", "text/html")
                        self.end_headers()
                        html = f'<html><head><meta http-equiv="refresh" content="0.1; url=https://rooted.ddnss.de/tree.xml" /></head><body><h1>Processing... ' + addAs + '<br/>' + \
                            name + ' as ' + addAs + ' from ' + ref + '</h1></body></html>'
                        self.wfile.write(bytes(html, "utf8"))
                        # for elem in tree.iter():
                        #   elem.set('width', value=str(treeWidth(elem)).encode("utf-8").decode("utf-8"))
                        #   elem.set('depth', value=str(treeDepth(elem)).encode("utf-8").decode("utf-8"))
                        with open('./tree.xml', 'w') as f:
                            f.write('<?xml version="1.0" encoding="utf-8"?>\n')
                        with open('./tree.xml', 'a') as f:
                            f.write(ET.tostring(
                                tree, pretty_print=True).decode("utf-8"))
                        return
                elif addAs == 'parent':
                    if elem.attrib['text'] == ref:
                        x = 0
                        parent = elem.getparent()
                        while x < len(parent.getchildren()):
                            print(ref)
                            print(parent.getchildren()[x].attrib['text'])
                            if parent.getchildren()[x].attrib['text'] == ref:
                                print('found')
                                tmp = parent.getchildren()[x]
                                parent.remove(parent.getchildren()[x])
                                new = ET.fromstring(
                                    '<node text="' + name + '"/>')
                                new.append(tmp)
                                parent.append(new)
                            x = x + 1
                        self.send_header("Content-type", "text/html")
                        self.end_headers()
                        html = f'<html><head><meta http-equiv="refresh" content="0.1; url=https://rooted.ddnss.de/tree.xml" /></head><body><h1>Processing... ' + addAs + '<br/>' + \
                            name + ' as ' + addAs + ' from ' + ref + '</h1></body></html>'
                        self.wfile.write(bytes(html, "utf8"))
                    # for elem in tree.iter():
                    #   elem.set('width', value=str(treeWidth(elem)).encode("utf-8").decode("utf-8"))
                    #   elem.set('depth', value=str(treeDepth(elem)).encode("utf-8").decode("utf-8"))
                        with open('./tree.xml', 'w') as f:
                            f.write('<?xml version="1.0" encoding="utf-8"?>\n')
                        with open('./tree.xml', 'a') as f:
                            f.write(ET.tostring(
                                tree, pretty_print=True).decode("utf-8"))
                        return

        # for elem in tree.iter():
        #    elem.set('width', value=str(treeWidth(elem)).encode("utf-8").decode("utf-8"))
        #    elem.set('depth', value=str(treeDepth(elem)).encode("utf-8").decode("utf-8"))
        with open('./tree.xml', 'w') as f:
            f.write('<?xml version="1.0" encoding="utf-8"?>\n')
        with open('./tree.xml', 'a') as f:
            f.write(ET.tostring(tree, pretty_print=True).decode("utf-8"))

        # Setting the header
        self.send_header("Content-type", "text/xml")
        #self.send_header('Access-Control-Allow-Origin', 'https://rooted.ddnss.de/')
        # Whenever using 'send_header', you also have to call 'end_headers'
        self.end_headers()

        # Extract query param
        #name = 'World'
        for elem in tree.iter():
            if 'text' in elem.attrib:
                if elem.attrib['text'] == 'Life':
                    t = svgling.draw_tree(eval(treeForEval(elem)))
                    t.get_svg().saveas("tree.svg")
        with open('/var/www/rooted/tree.xml', 'rb') as file:
            self.wfile.write(file.read())
            # print(file.read().decode())
        return


# Create an object of the above class
handler_object = MyHttpRequestHandler

PORT = 8000
my_server = socketserver.TCPServer(("", PORT), handler_object)
my_server.allow_reuse_address = True

# Star the server
my_server.serve_forever()
