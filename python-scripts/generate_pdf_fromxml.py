import pyodbc
import subprocess
import tempfile
import os
import datetime
import xml.etree.ElementTree as ET

print(datetime.datetime.now())

# Create the connection string
conn_str = (
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=CH-DB\\ERP;'
    'DATABASE=NIRO;'
    'UID=sa;'
    'PWD=eRp-NiR0;'
    'Timeout=30'
)

conn = pyodbc.connect(conn_str)
print("Connection successful!")

# Create a cursor object
cursor = conn.cursor()

# Example query: select all rows from a table
query = '''
    select * from EfXml
'''

# Execute the query
cursor.execute(query)

# Fetch all the results
rows = cursor.fetchall()

# Iterate through rows and execute curl command for each row
for index, row in enumerate(rows):
    # Extract the XML data (assuming it is the first column in the result set)
    xml_data = row[0]   # Invoice
    xml_partner = row[1]   # PartnerName
    xml_uploadId = row[2]       # ExternalUploadId

    # Parse the XML data
    root = ET.fromstring(xml_data)

    # Define the namespace
    namespaces = {'cbc': 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'}

    # Find the IssueDate element
    issue_date = root.find('cbc:IssueDate', namespaces)
    date_obj = datetime.datetime.strptime(issue_date.text, '%Y-%m-%d')
    formatted_date = date_obj.strftime('%Y %B')

    print(formatted_date)

    # Define the output file name based on the index
    #output_file_name = f"factura_{index}.pdf"
    output_file_name = f"factura_{xml_uploadId}.pdf"

    current_date = datetime.datetime.now()
    date_str = current_date.strftime('%Y-%m-%d')

    # Define the directory structure
    output_dir = os.path.join(formatted_date, 'Niro', xml_partner)
    os.makedirs(output_dir, exist_ok=True)
    output_file_path = os.path.join(output_dir, output_file_name)


    # Create a temporary file to hold the XML data
    with tempfile.NamedTemporaryFile(delete=False, mode='w', encoding='utf-8') as temp_file:
        temp_file.write(xml_data)
        temp_file_path = temp_file.name

    print(output_file_path)

    # Build the complete curl command
    curl_command = [
        "curl", "--location", "https://webservicesp.anaf.ro/prod/FCTEL/rest/transformare/FACT1/DA",
        "--header", "Content-Type: text/plain",
        "--header", "Cookie: f5avraaaaaaaaaaaaaaaa_session_=KIEPMOPINLDCNNPMGBKKAGLGGGBDIHJDIMHJHFNLIJBJKGLOILHPBCIGAEAJHFDNONADJEJGHFPLHBOEMNOACOJJBPCLKJPNEBLLGIHPBIILODMBCJKDLDKLIKFPPJIB; TS01a203a4=01a05af4ae705067fa8c82a762ca75e1d2769c3958d1862a5fe1978cc2dde3d9a38ac7f99c2be381b04b47497127538019ad73c5fd",
        "--data-binary", f"@{temp_file_path}",
        "--output", output_file_path
    ]

    try:
        # Run the curl command
        result = subprocess.run(curl_command, capture_output=True, text=True)

        # Print the result or any error
        print(f"Index {index}:")
        print("Output:", result.stdout)
        if result.stderr:
            print("Error:", result.stderr)
   
    except Exception as e:
        print(f"Exception occurred for index {index}: {e}")

    finally:
        # Clean up the temporary file
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)