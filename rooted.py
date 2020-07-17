import http.server
import socketserver
from urllib.parse import urlparse
from urllib.parse import parse_qs
import xml.etree.ElementTree as ET

class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Sending an '200 OK' response
        self.send_response(200)

        # Setting the header
        self.send_header("Content-type", "text/xml")
        #self.send_header('Access-Control-Allow-Origin', 'https://rooted.ddnss.de/')
        # Whenever using 'send_header', you also have to call 'end_headers'
        self.end_headers()

        # Extract query param
        #name = 'World'
        query_components = parse_qs(urlparse(self.path).query)
        print(query_components)
        #if 'name' in query_components:
        #    name = query_components["name"][0]

#        tree = ET.parse('tree.xml')
#        for elem in tree.iter():
#            print(elem.attrib)
#            print(elem.tag)
#            print(elem.tag['id'])

        with open('/var/www/rooted/tree.xml', 'rb') as file:
            self.wfile.write(file.read())
            print(file.read().decode())
        return

# Create an object of the above class
handler_object = MyHttpRequestHandler

PORT = 8000
my_server = socketserver.TCPServer(("", PORT), handler_object)
my_server.allow_reuse_address = True

# Star the server
my_server.serve_forever()
