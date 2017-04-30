#!/bin/env/python3.5
# This program generates an HTML page for content for other CGI's to use


class HTMLPage:
   def __init__(self):
      print('Content-Type: text/html;charset=utf-8\n')
      print('<!DOCTYPE HTML>\n<html>\n<head>\n<title>NBA Tools</title>\n', 
            '<link rel="stylesheet" type="text/css" href="../../css/homepage.css">\n', 
            '</head>\n<body>\n')
   def generateMenu(self):
      print('<ul class="menubar">\n', 
            '<li class="menubar-list"><a class="menubar-link" href="../..">Home</a></li>\n', 
            '<li class="menubar-list"><a class="menubar-link" href="About Link">About</a></li>\n', 
            '<!-- begin dropdown -->\n', 
            '<li class="menubar-list dropdown-col">\n', 
            '<a class="dropdown-title" href="link to tools">Tools</a>\n', 
            '<div class="dropdown-content">\n' 
            '<a class="dropdown-content-link" href="../../cgi-bin/draft">Tool 1</a>\n', 
            '<a class="dropdown-content-link" href="../../cgi-bin/tool2">Tool 2</a>\n', 
            '<a class="dropdown-content-link" href="../../cgi-bin/tool3">Tool 3</a>\n', 
            '</div>', 
            '</li>', 
            '<!-- end dropdown -->', 
            '</ul>')
