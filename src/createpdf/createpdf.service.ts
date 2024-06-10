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

    // Draw total
    page.drawText(`Total: $${total}`, { x: 50, y: 120, size: 20, font });

    // Serialize the PDF document to bytes (a Uint8Array)
    const pdfBytes = await pdfDoc.save();

    return Buffer.from(pdfBytes);


    return 'This action adds a new createpdf';

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
