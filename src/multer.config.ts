import { MulterOptions } from '@nestjs/platform-express/multer/interfaces/multer-options.interface';
import { diskStorage } from 'multer';

// const folderPath = path.join(__dirname, 'upload');


const storage: MulterOptions['storage'] = diskStorage({
  destination: '/Users/razvanmustata/Projects/contracts/backend/Uploads', // Specify the directory where files will be saved
  filename(req, file, callback) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    callback(null, file.fieldname + '-' + uniqueSuffix + '.' + file.originalname.split('.').pop());
  },
});

export const multerConfig: MulterOptions = {
  storage,
};