import os

# Set the directory path where the HTML files are located
dir_path = './docs/'
html_path = 'slides/'

# page title
TITLE = 'Fun with Science Blog'
AUTHOR = 'Ehsan Shaghaei'
# Create a list of all the HTML files in the directory
files = os.listdir(dir_path+html_path)
html_files = [f for f in files if f.endswith('.html')]
print(html_files)
# Initialize the HTML string
html = '<html><head><style>table, th, td {border: 1px solid black;}</style></head>'
html += f'<title>{TITLE}</title><body>'
html += f'<h1>{TITLE}</h1>'
html += f'<h2>{AUTHOR}</h2>'
# Create a table with thumbnails and captions for each HTML file
html += '<table>'
for file in html_files:
    print(file)
    with open(dir_path + html_path + file, 'r') as f:
        html_data = f.read()

    # Get the title of the first slide
    title_start = html_data.find('<title>') + 7
    title_end = html_data.find('</title>')
    title = html_data[title_start:title_end].replace('_',' ')
    

    # Get the thumbnail of the first slide
    thumb_start = html_data.find('<img src="') + 10
    thumb_end = html_data.find('"', thumb_start)
    thumb = html_data[thumb_start:thumb_end]

    # Add a row to the table for the HTML file
    html += f'<tr><td><a href="{html_path+file}" target="_blank"><img src="{thumb}" width="100" height="100"></a></td><td>{title}</td></tr>'

html += '</table></body></html>'

# Write the HTML string to a file
with open(dir_path+'index.html', 'w') as f:
    f.write(html)
