
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle
from reportlab.lib.units import mm

# Create the PDF document
invoice_pdf = SimpleDocTemplate("Invoice.pdf", pagesize=A4)

# Container for PDF elements
elements = []

# Sample data for the invoice
invoice_data = {
    'company_name': 'My Company',
    'company_address': '123 Business St, City, Country',
    'client_name': 'John Doe',
    'client_address': '456 Client St, City, Country',
    'invoice_number': 'INV-0001',
    'invoice_date': '2024-09-17',
    'due_date': '2024-09-24',
    'items': [
        ['Item', 'Description', 'Quantity', 'Unit Price', 'Total', 'Test','Infos'],
        ['Item 1', 'Product description 1', '2', '$50.00', '$100.00','c1',';ak;dka;slkd;ask;dlksa;kd;sakd;lka;kl;ads;kl'],
        ['Item 2', 'Product description 2', '1', '$75.00', '$75.00','c2','adlk;laskd;daks;kd;alkd'],
        ['Item 3', 'Product description 3', '13', '$3375.00', '$75.00','c3','alkasjdklaskjd'],
    ],
    'total': '$175.00'
}

# Define a style for the document
styles = getSampleStyleSheet()

# Add title
title = Paragraph(f"Invoice #{invoice_data['invoice_number']}", styles['Title'])
elements.append(title)

# Company and Client Information
company_info = Paragraph(f"<b>{invoice_data['company_name']}</b><br/>"
                         f"{invoice_data['company_address']}", styles['Normal'])
client_info = Paragraph(f"<b>Bill To:</b><br/>"
                        f"{invoice_data['client_name']}<br/>"
                        f"{invoice_data['client_address']}", styles['Normal'])

# Add company and client info to elements
elements.append(company_info)
elements.append(Paragraph("<br/><br/>", styles['Normal']))  # Add space
elements.append(client_info)
elements.append(Paragraph("<br/><br/>", styles['Normal']))

# Invoice Date and Due Date
dates = Paragraph(f"<b>Invoice Date:</b> {invoice_data['invoice_date']}<br/>"
                  f"<b>Due Date:</b> {invoice_data['due_date']}", styles['Normal'])
elements.append(dates)
elements.append(Paragraph("<br/><br/>", styles['Normal']))

# Invoice Table (Items)
table_data = invoice_data['items']
invoice_table = Table(table_data)

# Style for the invoice table
table_style = TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
    ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
    ('GRID', (0, 0), (-1, -1), 1, colors.black),
])
invoice_table.setStyle(table_style)

# Add the invoice table to the elements
elements.append(invoice_table)

# Add the total at the bottom
elements.append(Paragraph(f"<b>Total:</b> {invoice_data['total']}", styles['Normal']))

# Generate the PDF
invoice_pdf.build(elements)

print("Invoice PDF generated successfully xxx!")
