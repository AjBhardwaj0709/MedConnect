const multer = require("multer");

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB

const allowedMimeTypes = [
    // Images
    "image/jpeg",
    "image/png",
    "image/webp",

    // PDF
    "application/pdf",

    // Documents
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
];

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
    if (!allowedMimeTypes.includes(file.mimetype)) {
        return cb(
            new Error(
                "Only JPG, JPEG, PNG, WEBP, PDF, DOC and DOCX files are allowed"
            )
        );
    }

    cb(null, true);
};

const upload = multer({
    storage,
    limits: {
        fileSize: MAX_FILE_SIZE,
    },
    fileFilter,
});

module.exports = upload;