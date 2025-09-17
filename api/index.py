import subprocess
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler
import tempfile
import shutil

def handler(request, response):
    # Build the MkDocs site
    subprocess.run(['pip', 'install', '-r', 'requirements.txt'], check=True)
    subprocess.run(['mkdocs', 'build'], check=True)
    
    # Serve the built site
    os.chdir('site')
    return SimpleHTTPRequestHandler.do_GET(request)
