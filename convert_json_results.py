import json
from json2html import *


def transformer(input_json):
    """ converts input json into output HTML table"""
    return json2html.convert(json=input_json)


def read_json(file):
    """ getting json from the file """
    if file:
        with open(file, 'r') as f:
            data = json.load(f)
        return data


def write_html(file, data):
    """ dumping converted table HTML into the file """
    with open(file, 'w') as f:
        f.write(data)


def main():
    try:
        # building header of HTML file
        data = '<h1>Docker Security Scanning Report</h1>'
        data += '<link rel="stylesheet" href="./style.css">'

        # getting list of the files to convert to HTML
        json_files = ['./json/trivy_results.json', './json/dockle_results.json', './json/hadolint_results.json']

        # converting each file and adding some textual info into resulting HTML
        print('[+] Converting JSON results')
        for file in json_files:
            json_content = read_json(file)
            data += '<br>'
            data += 'Issues found in %s' % file
            data += '<br><br>'
            data += transformer(json_content)

        print('[+] Writing results HTML')
        write_html('results.html', data)

    except KeyboardInterrupt:
        print('[X] Exiting ...')


if __name__ == "__main__":
    print('[+] Starting the main module ' + '=' * 60)
    main()
