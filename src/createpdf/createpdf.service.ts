import { Injectable } from '@nestjs/common';
import { CreateCreatepdfDto } from './dto/create-createpdf.dto';
import { UpdateCreatepdfDto } from './dto/update-createpdf.dto';
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';

import * as fs from 'fs';
import * as path from 'path';



@Injectable()
export class CreatepdfService {
  async create(createCreatepdfDto: CreateCreatepdfDto) {


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

    // Draw the logo image
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

    // Set response headers and send the PDF
    // const res: any = [];
    // res.setHeader('Content-Type', 'application/pdf');
    // res.setHeader('Content-Disposition', 'attachment; filename=invoice.pdf');
    // res.send(Buffer.from(pdfBytes));

    return Buffer.from(pdfBytes);
    // return 'This action adds a new createpdf';

  }

  findAll() {
    return `This action returns all createpdf`;
  }

  findOne(id: number) {
    return `This action returns a #${id} createpdf`;
  }

  update(id: number, updateCreatepdfDto: UpdateCreatepdfDto) {
    return `This action updates a #${id} createpdf`;
  }

  remove(id: number) {
    return `This action removes a #${id} createpdf`;
  }
}
