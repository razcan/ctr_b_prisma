import { Controller, Get, Post, Body, Patch, Param, Delete, Res } from '@nestjs/common';
import { CreatepdfService } from './createpdf.service';
import { CreateCreatepdfDto } from './dto/create-createpdf.dto';
import { UpdateCreatepdfDto } from './dto/update-createpdf.dto';
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';
import * as fs from 'fs';
import * as path from 'path';
import { Response } from 'express';


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


  getFormatDate(date): string {
    const today = new Date(date);
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0'); // Adding 1 because January is 0
    const day = today.getDate().toString().padStart(2, '0');

    return `${year}-${month}-${day}`;
  }


  @Post('file3')
  async findAll3(
    @Body() all_data: any[],
    @Res() res: Response,
  ) {

    const data = all_data[0]

    console.log(all_data[0], "data1")

    // Create a new PDF document
    const pdfDoc = await PDFDocument.create();

    // Add a page to the document
    // const page = pdfDoc.addPage([600, 400]);

    // Define A4 page size in points
    const A4_WIDTH = 595.28;
    const A4_HEIGHT = 841.89;
    const MARGIN_TOP = 50;
    const MARGIN_BOTTOM = 50;
    const ITEM_HEIGHT = 20;

    // Calculate number of items that fit on one page
    const itemsPerPage = Math.floor((A4_HEIGHT - MARGIN_TOP - MARGIN_BOTTOM) / ITEM_HEIGHT);

    // Calculate total number of pages
    const totalPages = Math.ceil(all_data[1].length / itemsPerPage);

    console.log(totalPages, "totalPages")

    let currentIndex = 0;


    for (let pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      // Add a blank page with A4 dimensions
      const page = pdfDoc.addPage([A4_WIDTH, A4_HEIGHT]);

      // Calculate text width and height for centering
      // const textWidth = page.getWidth() / 2 - 30 * 2;
      // const textHeight = page.getHeight() / 2;

      // Set up fonts
      const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

      // Draw text
      page.drawText('Factura Fiscala', { x: 400, y: 820, size: 16, font, color: rgb(0, 0, 0) });
      page.drawText(`Total de plata: ${data.totalPayment}`, { x: 400, y: 780, size: 12, font });
      page.drawText(`Data: ${this.getFormatDate(data.date)}`, { x: 400, y: 760, size: 12, font });
      page.drawText(`Numar: ${data.number}`, { x: 400, y: 740, size: 12, font });


      // // Draw table details
      page.drawText('#', { x: 10, y: 700, size: 10, font });
      page.drawText('Articol', { x: 20, y: 700, size: 10, font });
      page.drawText('UM', { x: 400, y: 700, size: 10, font });
      page.drawText('Cantitate', { x: 440, y: 700, size: 10, font });
      page.drawText('Pret', { x: 500, y: 700, size: 10, font });
      page.drawText('Valoare', { x: 520, y: 700, size: 10, font });

      page.drawLine({
        start: { x: 10, y: 690 },
        end: { x: 590, y: 690 },
        thickness: 2,
        color: rgb(0.42, 0.102, 0.58),
        opacity: 0.75,
      })

      let y_details = 0;
      // // Draw table content
      all_data[1].forEach((item: any, index: number) => {
        const y = 670 - index * 20;
        page.drawText((1 + index).toString(), { x: 10, y, size: 10, font });
        page.drawText(item.itemId.name, { x: 20, y, size: 10, font });
        page.drawText(item.measuringUnit, { x: 400, y, size: 10, font });
        page.drawText(item.qtty.toString(), { x: 440, y, size: 10, font });
        page.drawText(item.price.toString(), { x: 500, y, size: 10, font });
        page.drawText(item.lineValue.toString(), { x: 520, y, size: 10, font });
        y_details = y - 40;
      });


      page.drawText(`Total valoare: ${data.totalAmount}`, { x: 400, y: y_details, size: 12, font, color: rgb(0.42, 0.102, 0.58) });
      page.drawText(`Total TVA: ${data.vatAmount}`, { x: 400, y: y_details - 20, size: 12, font, color: rgb(0.42, 0.102, 0.58) });
      page.drawText(`Total : ${data.totalPayment}`, { x: 400, y: y_details - 40, size: 12, font, color: rgb(0.42, 0.102, 0.58) });

    }

    // Serialize the PDF document to bytes (a Uint8Array)
    const pdfBytes = await pdfDoc.save();

    // Specify the filename and path where the PDF will be saved
    const filename = `invoice_${data.number}_${this.getFormatDate(data.date)}_${new Date()}.pdf`;

    // const filepath = path.join(__dirname, 'invoices', filename);

    const filepath = path.join(`/Users/razvanmustata/Projects/contracts/backend`, 'Invoices_PDF', filename)

    // Ensure the directory exists
    fs.mkdirSync(path.dirname(filepath), { recursive: true });

    // Write the PDF to the file
    fs.writeFileSync(filepath, pdfBytes);

    // Respond with the file location
    console.log("filepath", filepath);


    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
    res.send(Buffer.from(pdfBytes));

  }



  @Post('file2')
  async findAll(
    @Res() res: Response
  ) {

    const { customerName, date, items, total } = {
      customerName: "SoftHub", date: "2024-06-06",
      items: [
        { name: "Branza", quantity: "1", price: "10" },
        { name: "Carne", quantity: "2", price: "30" },
        { name: "Carnati", quantity: "3", price: "310" },
      ]

      , total: "200"
    };




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
    items.forEach((item: any, index: number) => {
      const y = 220 - index * 20;
      page.drawText(item.name, { x: 50, y, size: 15, font });
      page.drawText(item.quantity.toString(), { x: 250, y, size: 15, font });
      page.drawText(item.price, { x: 400, y, size: 15, font });
    });

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
    // return filepath;

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