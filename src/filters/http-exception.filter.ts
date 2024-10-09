import {
  Catch,
  ExceptionFilter,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

export interface PrismaError {
  code: string;
  message: string;
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    // console.log(exception, 'exception este aici');

    const prismaErrors: PrismaError[] = [
      {
        code: 'P1000',
        message:
          'Authentication failed against the database server, the provided database credentials are not valid. Please make sure to provide valid database credentials for the database server.',
      },
      {
        code: 'P1001',
        message:
          "Can't reach database server. Please make sure your database server is running.",
      },
      {
        code: 'P1002',
        message:
          'The database server was reached but timed out. Please try again. Please make sure your database server is running.',
      },
      {
        code: 'P1003',
        message:
          'The database server was reached, but the connection was refused. Please make sure your database server is running.',
      },
      {
        code: 'P1008',
        message: 'Operations timed out after ms. Retry the transaction.',
      },
      {
        code: 'P1009',
        message: 'Database already exists.',
      },
      {
        code: 'P1010',
        message: 'User was denied access on the database.',
      },
      {
        code: 'P1011',
        message: 'Error opening a TLS connection.',
      },
      {
        code: 'P1012',
        message: 'Error creating a database connection pool.',
      },
      {
        code: 'P1013',
        message: 'The provided database string is invalid.',
      },
      {
        code: 'P1014',
        message: 'The underlying connection was terminated unexpectedly.',
      },
      {
        code: 'P2000',
        message:
          "The provided value for the column is too long for the column's type.",
      },
      {
        code: 'P2001',
        message:
          'The record searched for in the where condition does not exist.',
      },
      {
        code: 'P2002',
        message: 'Unique constraint failed.',
      },
      {
        code: 'P2003',
        message: 'Foreign key constraint failed on the field.',
      },
      {
        code: 'P2004',
        message: 'A constraint failed on the database.',
      },
      {
        code: 'P2005',
        message:
          "The value stored in the database for the field is invalid for the field's type.",
      },
      {
        code: 'P2006',
        message: 'The provided value for the field is not valid.',
      },
      {
        code: 'P2007',
        message: 'Data validation error.',
      },
      {
        code: 'P2008',
        message: 'Failed to parse the query.',
      },
      {
        code: 'P2009',
        message: 'Failed to validate the query.',
      },
      {
        code: 'P2010',
        message: 'Raw query failed.',
      },
      {
        code: 'P2011',
        message: 'Null constraint violation.',
      },
      {
        code: 'P2012',
        message: 'Missing a required value.',
      },
      {
        code: 'P2013',
        message: 'Missing the required argument for field.',
      },
      {
        code: 'P2014',
        message:
          'The change you are trying to make would violate the required relation between the models.',
      },
      {
        code: 'P2015',
        message: 'A related record could not be found.',
      },
      {
        code: 'P2016',
        message: 'Query interpretation error.',
      },
      {
        code: 'P2017',
        message:
          'The records for relation between the models are not connected.',
      },
      {
        code: 'P2018',
        message: 'The required connected records were not found.',
      },
      {
        code: 'P2019',
        message: 'Input error.',
      },
      {
        code: 'P2020',
        message: 'Value out of range for the type.',
      },
      {
        code: 'P2021',
        message: 'The table does not exist in the current database.',
      },
      {
        code: 'P2022',
        message: 'The column does not exist in the current database.',
      },
      {
        code: 'P2023',
        message: 'Inconsistent column data.',
      },
      {
        code: 'P2024',
        message:
          'Timed out fetching a new connection from the connection pool.',
      },
      {
        code: 'P2025',
        message:
          'An operation failed because it depends on one or more records that were required but not found.',
      },
      {
        code: 'P2026',
        message:
          "The current database provider doesn't support a feature that the query used.",
      },
      {
        code: 'P2027',
        message:
          'Multiple errors occurred on the database during query execution.',
      },
      {
        code: 'P2030',
        message:
          'Cannot find a fulltext index to use for the search, try adding a @@fulltext([Fields...]) index to your schema.',
      },
      {
        code: 'P2031',
        message:
          'Prisma needs to perform transactions, which requires your MongoDB server to be run as a replica set.',
      },
      {
        code: 'P2033',
        message:
          'A number used in the query does not fit into a 64-bit signed integer.',
      },
    ];
    const error = prismaErrors.find((error) => error.code === exception);

    // console.log(error, 'eroare prisma');

    // Send the response
    if (error) {
      // console.log(error);

      const ctx = host.switchToHttp();
      const response = ctx.getResponse<Response>();

      response.status(HttpStatus.BAD_REQUEST).send({
        statusCode: HttpStatus.BAD_REQUEST,
        message: error.message,
        errorCode: error.code,
      });
    } else {
      const ctx = host.switchToHttp();
      const response = ctx.getResponse<Response>();

      let status = HttpStatus.INTERNAL_SERVER_ERROR;
      let message = 'An internal server error occurred';

      // Check if the exception is a known Prisma error
      if (exception instanceof Error) {
        const errorMessage = exception.message;
        if (errorMessage.includes('Unique constraint failed')) {
          status = HttpStatus.CONFLICT; // HTTP 409
          message = 'Unique constraint violation';
        } else if (errorMessage.includes('Foreign key constraint failed')) {
          status = HttpStatus.BAD_REQUEST; // HTTP 400
          message = 'Foreign key constraint violation';
        } else if (errorMessage.includes('Invalid data provided')) {
          status = HttpStatus.BAD_REQUEST; // HTTP 400
          message = 'Invalid data provided';
        }
      }

      response.status(status).json({
        statusCode: status,
        message,
      });
    }
  }
}
