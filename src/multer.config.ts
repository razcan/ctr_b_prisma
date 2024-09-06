import { MulterOptions } from '@nestjs/platform-express/multer/interfaces/multer-options.interface';
import { diskStorage } from 'multer';
import { join } from 'path';

// const folderPath = path.join(__dirname, 'upload');

const storage: MulterOptions['storage'] = diskStorage({
  // destination: '/Users/razvanmustata/Projects/contracts/backend/Uploads', // Specify the directory where files will be saved
  destination: (req, file, callback) => {
    // if (req.originalUrl.includes('/contracts/file/')) {
    //   const uploadPath = join(__dirname, '..', 'Uploads/Contracts');
    //   callback(null, uploadPath);
    // } else if (req.originalUrl.includes('/nomenclatures/partnerlogo/')) {
    //   const uploadPath = join(__dirname, '..', 'Uploads/Logos');
    //   callback(null, uploadPath);
    // } else if (req.originalUrl.includes('/nomenclatures/user/')) {
    //   const uploadPath = join(__dirname, '..', 'Uploads/Avatars');
    //   callback(null, uploadPath);
    // } else {
    //   const uploadPath = join(__dirname, '..', 'Uploads/Avatars');
    //   callback(null, uploadPath);
    // }
    const uploadPath = join(__dirname, '..', 'Uploads'); // Creates a path relative to the current file
    callback(null, uploadPath);
  },
  filename(req, file, callback) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    callback(
      null,
      file.fieldname +
        '-' +
        uniqueSuffix +
        '.' +
        file.originalname.split('.').pop(),
    );
  },
});

export const multerConfig: MulterOptions = {
  storage,
};
