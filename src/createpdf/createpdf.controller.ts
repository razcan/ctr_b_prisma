import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { CreatepdfService } from './createpdf.service';
import { CreateCreatepdfDto } from './dto/create-createpdf.dto';
import { UpdateCreatepdfDto } from './dto/update-createpdf.dto';
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';
import * as fs from 'fs';
import * as path from 'path';

@Controller('createpdf')
export class CreatepdfController {
  constructor(private readonly createpdfService: CreatepdfService) { }

  @Post()
  create(@Body() createCreatepdfDto: CreateCreatepdfDto) {
    return this.createpdfService.create(createCreatepdfDto);
  }

  @Post('file')
  async createPDF(@Body() createCreatepdfDto: CreateCreatepdfDto) {
    const pdfDoc = await PDFDocument.create()
    const timesRomanFont = await pdfDoc.embedFont(StandardFonts.TimesRoman)

    const page = pdfDoc.addPage()
    const { width, height } = page.getSize()
    const fontSize = 30
    page.drawText('Creating PDFs in JavaScript is awesome!', {
      x: 50,
      y: height - 4 * fontSize,
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0, 0.53, 0.71),
    })

    const pdfBytes = await pdfDoc.save();

    // Specify the filename and path where the PDF will be saved
    const filename = `invoice_${new Date()}_${Date.now()}.pdf`;
    const filepath = path.join(__dirname, 'invoices', filename);

    // Ensure the directory exists
    fs.mkdirSync(path.dirname(filepath), { recursive: true });

    // Write the PDF to the file
    fs.writeFileSync(filepath, pdfBytes);

    return filepath

  }



  @Post('file2')
  async findAll() {

    const { customerName, date, items, total } = { customerName: "SoftHub", date: "2024-06-06", items: "Branza", total: "200" };

    // Create a new PDF document
    const pdfDoc = await PDFDocument.create();

    // Add a page to the document
    const page = pdfDoc.addPage([600, 400]);

    // Load the logo image
    // const logoPath = path.join(__dirname, 'assets', 'logo.png');
    // const logoImageBytes = fs.readFileSync(logoPath);
    // const logoImage = await pdfDoc.embedPng(logoImageBytes);
    // const logoDims = logoImage.scale(0.5);

    // // Draw the logo image
    // page.drawImage(logoImage, {
    //   x: page.getWidth() / 2 - logoDims.width / 2,
    //   y: page.getHeight() - logoDims.height - 20,
    //   width: logoDims.width,
    //   height: logoDims.height,
    // });

    // Set up fonts
    const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

    // Draw text
    page.drawText('Invoice', { x: 50, y: 350, size: 30, font, color: rgb(0, 0, 0) });
    page.drawText(`Customer Name: ${customerName}`, { x: 50, y: 300, size: 20, font });
    page.drawText(`Date: ${date}`, { x: 50, y: 270, size: 20, font });

    // Draw table headers
    page.drawText('Item', { x: 50, y: 240, size: 15, font });
    page.drawText('Quantity', { x: 250, y: 240, size: 15, font });
    page.drawText('Price', { x: 400, y: 240, size: 15, font });

    // Draw table content
    // items.forEach((item: any, index: number) => {
    //   const y = 220 - index * 20;
    //   page.drawText(item.name, { x: 50, y, size: 15, font });
    //   page.drawText(item.quantity.toString(), { x: 250, y, size: 15, font });
    //   page.drawText(item.price.toFixed(2), { x: 400, y, size: 15, font });
    // });

    // Draw total
    // page.drawText(`Total: $${total.toFixed(2)}`, { x: 50, y: 120, size: 20, font });

    // Serialize the PDF document to bytes (a Uint8Array)
    const pdfBytes = await pdfDoc.save();

    // Specify the filename and path where the PDF will be saved
    const filename = `invoice_${customerName}_${Date.now()}.pdf`;
    const filepath = path.join(__dirname, 'invoices', filename);

    // Ensure the directory exists
    fs.mkdirSync(path.dirname(filepath), { recursive: true });

    // Write the PDF to the file
    fs.writeFileSync(filepath, pdfBytes);

    // Respond with the file location
    return filepath;

  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.createpdfService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateCreatepdfDto: UpdateCreatepdfDto) {
    return this.createpdfService.update(+id, updateCreatepdfDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.createpdfService.remove(+id);
  }
}
