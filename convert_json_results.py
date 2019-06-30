import json
import os
from json2html import *


def transformer(input_json):
    """ converts input json into output HTML table """
    return json2html.convert(json=input_json)


def read_json(file):
    """ getting json from the file """
    if file:
        if os.path.getsize(file) > 0:
            with open(file, 'r') as f:
                data = json.load(f)
            return data
        else:
            raise Exception('The input JSON file is empty')


def write_html(file, data):
    """ dumping converted table HTML into the file """
    with open(file, 'w') as f:
        f.write(data)


def main():
    try:
        # building header of HTML file
        data = '<h1>Docker Security Scanning Report</h1>'

        # styling the table
        data += """<style>
        body {
          font-family: "Helvetica Neue", Helvetica, Arial;
          font-size: 14px;
          line-height: 20px;
          font-weight: 400;
          color: #FFFFFF;
          font-weight: bold;
          -webkit-font-smoothing: antialiased;
          font-smoothing: antialiased;
          background: #2b2b2b;
        }

        tr {
          color: #3b3b3b;
          display: table-row;
          background: #f6f6f6;
        }

        tr:nth-of-type(odd) {
          background: #e9e9e9;
        }

        th {
          font-weight: 900;
          color: #ffffff;
          background: #ea6153;
        }

        /* Inner tables */ 
        td table {
          font-size: 14px;
        }
        </style>
        """

        # getting list of the files to convert to HTML
        json_files = ['./json/hadolint_results.json', './json/dockle_results.json', './json/trivy_results.json']

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

        print('[+] Clean exit ' + '=' * 60)

    except Exception as exception_message:
        print('[-] Something went wrong: %s' % exception_message)

    
    except KeyboardInterrupt:
        print('[X] Exiting ...')


if __name__ == "__main__":
    print('[+] Starting the main module ' + '=' * 60)
    main()
