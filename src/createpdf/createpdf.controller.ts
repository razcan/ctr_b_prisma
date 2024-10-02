import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Res,
} from '@nestjs/common';
import { CreatepdfService } from './createpdf.service';
import { CreateCreatepdfDto } from './dto/create-createpdf.dto';
import { UpdateCreatepdfDto } from './dto/update-createpdf.dto';
import fontkit from '@pdf-lib/fontkit'; // Import fontkit
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';
import * as fs from 'fs';
import * as path from 'path';
import { Response } from 'express';

@Controller('createpdf')
export class CreatepdfController {
  constructor(private readonly createpdfService: CreatepdfService) {}

  @Post()
  create(@Body() createCreatepdfDto: CreateCreatepdfDto) {
    return this.createpdfService.create(createCreatepdfDto);
  }

  @Post('file')
  async createPDF(@Body() createCreatepdfDto: CreateCreatepdfDto) {
    const pdfDoc = await PDFDocument.create();
    pdfDoc.registerFontkit(fontkit);

    const timesRomanFont = await pdfDoc.embedFont(StandardFonts.TimesRoman);

    const page = pdfDoc.addPage();
    const { width, height } = page.getSize();
    const fontSize = 30;
    page.drawText('Creating PDFs in JavaScript is awesome!', {
      x: 50,
      y: height - 4 * fontSize,
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0, 0.53, 0.71),
    });

    const pdfBytes = await pdfDoc.save();

    // Specify the filename and path where the PDF will be saved
    const filename = `invoice_${new Date()}_${Date.now()}.pdf`;
    const filepath = path.join(__dirname, 'invoices', filename);

    // Ensure the directory exists
    fs.mkdirSync(path.dirname(filepath), { recursive: true });

    // Write the PDF to the file
    fs.writeFileSync(filepath, pdfBytes);

    return filepath;
  }

  getFormatDate(date): string {
    const today = new Date(date);
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0'); // Adding 1 because January is 0
    const day = today.getDate().toString().padStart(2, '0');

    return `${year}-${month}-${day}`;
  }

  // Format the number with commas as thousand separators
  formatNumber(number: number) {
    const formattedNumber = new Intl.NumberFormat('en-US', {
      minimumFractionDigits: 2, // Ensure two decimal places
      maximumFractionDigits: 2, // Prevent extra decimal places
    }).format(number);
    return formattedNumber;
  }

  @Post('invoice')
  async findAll3(@Body() all_data: any[], @Res() res: Response) {
    const data = all_data[0];
    // console.log(all_data[0], all_data[1], 'data');

    // Create a new PDF document
    const pdfDoc = await PDFDocument.create();
    pdfDoc.registerFontkit(fontkit);

    const boldFont = await pdfDoc.embedFont(StandardFonts.HelveticaBold); // Load a bold font
    const regularFont = await pdfDoc.embedFont(StandardFonts.Helvetica); // Load a regular font
    const romanianFont = fs.readFileSync(
      '/Users/razvanmustata/Projects/contracts/backend/src/createpdf/fonts/Roboto/Roboto-Black.ttf',
    ); // Load your font file
    const customFont = await pdfDoc.embedFont(romanianFont);

    // Add a page to the document
    // const page = pdfDoc.addPage([600, 400]);

    // Define A4 page size in points
    const A4_WIDTH = 595.28;
    const A4_HEIGHT = 841.89;
    const MARGIN_TOP = 50;
    const MARGIN_BOTTOM = 50;
    const ITEM_HEIGHT = 20;

    // Calculate number of items that fit on one page
    const itemsPerPage = Math.floor(
      (A4_HEIGHT - MARGIN_TOP - MARGIN_BOTTOM) / ITEM_HEIGHT,
    );

    // Calculate total number of pages
    const totalPages = Math.ceil(all_data[1].length / itemsPerPage);

    //console.log(totalPages, 'totalPages');

    let currentIndex = 0;

    for (let pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      // Add a blank page with A4 dimensions
      const page = pdfDoc.addPage([A4_WIDTH, A4_HEIGHT]);

      // Calculate text width and height for centering
      // const textWidth = page.getWidth() / 2 - 30 * 2;
      // const textHeight = page.getHeight() / 2;

      // Set up fonts
      const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
      const font_size = 12;
      const x_size = 150;

      // Build the dynamic path based on the provided image name
      const imagePath = path.join(
        __dirname,
        '..',
        'Uploads',
        data.entity_picture,
      );
      const finalPath = imagePath.replace('dist/', '');

      const imageBytes = fs.readFileSync(
        finalPath,
        // '/Users/razvanmustata/Projects/contracts/backend/Uploads/logo-1717750739986-367764145.jpeg',
      ); // Load your image file

      // Embed the image in the PDF document
      // const pngImage = await pdfDoc.embedPng(imageBytes); // Use `embedPng` for PNG images
      const jpegImage = await pdfDoc.embedJpg(imageBytes); // Use `embedJpg` for JPG images

      // Get the dimensions of the image
      const imageDims = jpegImage.scale(0.3); // Scale the image (optional)

      // Draw the image on the page at the specified location (x, y)
      page.drawImage(jpegImage, {
        x: 20,
        y: 740,
        width: 100, // Fixed width
        height: 50, // Fixed height
      });

      page.drawText('Factura Fiscala', {
        x: x_size,
        y: 820,
        size: 16,
        font: customFont,
        color: rgb(0.6, 0.6, 0.6),
      });

      //entity
      page.drawText(`${data.entity_name}`, {
        x: x_size,
        y: 780,
        size: font_size,
        font: customFont,
      });
      page.drawText(`CIF: ${data.entity_fiscal_reg}`, {
        x: x_size,
        y: 770,
        size: font_size,
        font: customFont,
      });
      page.drawText(`Reg. Com.: ${data.entity_commercial_reg}`, {
        x: x_size,
        y: 760,
        size: font_size,
        font: customFont,
      });
      page.drawText(`Adresa: ${data.entity_address}`, {
        x: x_size,
        y: 750,
        size: font_size,
        font: customFont,
      });
      //entity

      page.drawText(`Numar: ${data.serialNumber}`, {
        x: 440,
        y: 780,
        size: font_size,
        font: customFont,
      });
      page.drawText(`Data: ${this.getFormatDate(data.date)}`, {
        x: 440,
        y: 770,
        size: font_size,
        font: customFont,
      });
      page.drawText(`Scadenta: ${this.getFormatDate(data.duedate)}`, {
        x: 440,
        y: 760,
        size: font_size,
        font: customFont,
      });

      page.drawText(`Moneda: ${this.getFormatDate(data.duedate)}`, {
        x: 440,
        y: 750,
        size: font_size,
        font: customFont,
      });

      page.drawLine({
        start: { x: 10, y: 720 },
        end: { x: 590, y: 720 },
        thickness: 1,
        color: rgb(0, 0, 0),
        opacity: 0.2,
      });

      page.drawText(`Client: ${data.partner_name}`, {
        x: 10,
        y: 700,
        size: font_size,
        font: customFont,
      });

      page.drawText(`Adresa: ${data.partner_address}`, {
        x: 10,
        y: 690,
        size: font_size,
        font: customFont,
      });

      page.drawText(`Cif: ${data.partner_fiscal_reg}`, {
        x: 10,
        y: 680,
        size: font_size,
        font: customFont,
      });
      page.drawText(`Reg. Com.: ${data.partner_commercial_reg}`, {
        x: 10,
        y: 670,
        size: font_size,
        font: customFont,
      });

      const yy_size = 640;
      // // Draw table details
      page.drawText('#', { x: 10, y: yy_size, size: 10, font });
      page.drawText('Articol', { x: 24, y: yy_size, size: 10, font });
      page.drawText('UM', { x: 260, y: yy_size, size: 10, font });
      page.drawText('Cantitate', { x: 320, y: yy_size, size: 10, font });
      page.drawText('Pret', { x: 380, y: yy_size, size: 10, font });
      page.drawText('TVA', { x: 440, y: yy_size, size: 10, font });
      page.drawText('Total', { x: 500, y: yy_size, size: 10, font });

      page.drawLine({
        start: { x: 10, y: 630 },
        end: { x: 590, y: 630 },
        thickness: 1,
        color: rgb(0, 0, 0),
        opacity: 0.2,
      });

      let y_details = 0;
      // // Draw table content
      all_data[1].forEach((item: any, index: number) => {
        const y = 610 - index * 20;
        page.drawText((1 + index).toString() + '. ', {
          x: 10,
          y,
          size: font_size,
          font: customFont,
        });

        page.drawText(item.itemId.name, {
          x: 24,
          y,
          size: font_size,
          font: customFont,
        });

        page.drawText(item.itemId.measuringUnit.name, {
          x: 260,
          y,
          size: font_size,
          font: customFont,
        });
        page.drawText(this.formatNumber(item.qtty).toString(), {
          x: 320,
          y,
          size: font_size,
          font: customFont,
        });
        page.drawText(this.formatNumber(item.price).toString(), {
          x: 380,
          y,
          size: font_size,
          font: customFont,
        });
        page.drawText(this.formatNumber(item.vatAmount).toString(), {
          x: 440,
          y,
          size: font_size,
          font: customFont,
        });
        page.drawText(this.formatNumber(item.totalValue).toString(), {
          x: 500,
          y,
          size: font_size,
          font: customFont,
        });
        y_details = y - 60;
      });

      const x_val = 400;
      page.drawText(`Total valoare: ${this.formatNumber(data.totalAmount)}`, {
        x: x_val,
        y: y_details,
        size: 12,
        font: customFont,
        color: rgb(0.42, 0.102, 0.58),
      });
      page.drawText(`Total TVA: ${this.formatNumber(data.vatAmount)}`, {
        x: x_val,
        y: y_details - 20,
        size: 12,
        font: customFont,
        color: rgb(0.42, 0.102, 0.58),
      });
      page.drawText(`Total : ${this.formatNumber(data.totalPayment)}`, {
        x: x_val,
        y: y_details - 40,
        size: 12,
        font: customFont,
        color: rgb(0.42, 0.102, 0.58),
      });
    }

    // Serialize the PDF document to bytes (a Uint8Array)
    const pdfBytes = await pdfDoc.save();

    // Specify the filename and path where the PDF will be saved
    // const filename = `invoice_${data.number}_${this.getFormatDate(
    //   data.date,
    // )}_${new Date()}.pdf`;

    const filename = `invoice_${this.getFormatDate(data.date)}_${
      data.number
    }.pdf`;

    // const filepath = path.join(__dirname, 'invoices', filename);

    const filepath = path.join(
      `/Users/razvanmustata/Projects/contracts/backend`,
      'Invoices_PDF',
      filename,
    );

    // Ensure the directory exists
    fs.mkdirSync(path.dirname(filepath), { recursive: true });

    // Write the PDF to the file
    fs.writeFileSync(filepath, pdfBytes);

    // Respond with the file location
    // console.log('filepath', filepath);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
    res.send(Buffer.from(pdfBytes));
  }

  // @Post('file2')
  // async findAll(
  //   @Res() res: Response
  // ) {

  //   const { customerName, date, items, total } = {
  //     customerName: "SoftHub", date: "2024-06-06",
  //     items: [
  //       { name: "Branza", quantity: "1", price: "10" },
  //       { name: "Carne", quantity: "2", price: "30" },
  //       { name: "Carnati", quantity: "3", price: "310" },
  //     ]

  //     , total: "200"
  //   };

  //   // Create a new PDF document
  //   const pdfDoc = await PDFDocument.create();

  //   // Add a page to the document
  //   const page = pdfDoc.addPage([600, 400]);

  //   // Load the logo image
  //   // const logoPath = path.join(__dirname, 'assets', 'logo.png');
  //   // const logoImageBytes = fs.readFileSync(logoPath);
  //   // const logoImage = await pdfDoc.embedPng(logoImageBytes);
  //   // const logoDims = logoImage.scale(0.5);

  //   // // Draw the logo image
  //   // page.drawImage(logoImage, {
  //   //   x: page.getWidth() / 2 - logoDims.width / 2,
  //   //   y: page.getHeight() - logoDims.height - 20,
  //   //   width: logoDims.width,
  //   //   height: logoDims.height,
  //   // });

  //   // Set up fonts
  //   const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

  //   // Draw text
  //   page.drawText('Invoice', { x: 50, y: 350, size: 30, font, color: rgb(0, 0, 0) });
  //   page.drawText(`Customer Name: ${customerName}`, { x: 50, y: 300, size: 20, font });
  //   page.drawText(`Date: ${date}`, { x: 50, y: 270, size: 20, font });

  //   // Draw table headers
  //   page.drawText('Item', { x: 50, y: 240, size: 15, font });
  //   page.drawText('Quantity', { x: 250, y: 240, size: 15, font });
  //   page.drawText('Price', { x: 400, y: 240, size: 15, font });

  //   // Draw table content
  //   items.forEach((item: any, index: number) => {
  //     const y = 220 - index * 20;
  //     page.drawText(item.name, { x: 50, y, size: 15, font });
  //     page.drawText(item.quantity.toString(), { x: 250, y, size: 15, font });
  //     page.drawText(item.price, { x: 400, y, size: 15, font });
  //   });

  //   // Draw total
  //   // page.drawText(`Total: $${total.toFixed(2)}`, { x: 50, y: 120, size: 20, font });

  //   // Serialize the PDF document to bytes (a Uint8Array)
  //   const pdfBytes = await pdfDoc.save();

  //   // Specify the filename and path where the PDF will be saved
  //   const filename = `invoice_${customerName}_${Date.now()}.pdf`;
  //   const filepath = path.join(__dirname, 'invoices', filename);

  //   // Ensure the directory exists
  //   fs.mkdirSync(path.dirname(filepath), { recursive: true });

  //   // Write the PDF to the file
  //   fs.writeFileSync(filepath, pdfBytes);

  //   // Respond with the file location
  //   // return filepath;

  // }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.createpdfService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateCreatepdfDto: UpdateCreatepdfDto,
  ) {
    return this.createpdfService.update(+id, updateCreatepdfDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.createpdfService.remove(+id);
  }
}
