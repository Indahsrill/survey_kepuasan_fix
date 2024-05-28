const express = require("express");
const multer = require("multer");
const path = require("path");
// const Image = require("./models");

const app = express();
const PORT = 3000;

// Konfigurasi multer untuk menyimpan file di folder uploads
const storage = multer.diskStorage({
	destination: (req, file, cb) => {
		cb(null, "public//");
	},
	filename: (req, file, cb) => {
		cb(null, `${file.originalname}`);
	},
});

const upload = multer({ storage });

app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "public")));

// Endpoint untuk upload gambar
app.post("/upload", upload.single("image"), async (req, res) => {
	try {
		const imagePath = req.file.path;

		// Simpan path gambar ke database
		// const image = await Image.create({ path: imagePath });

		res.status(201).json({
			message: "Image uploaded successfully",
		});
		console.log("success");
	} catch (error) {
		res.status(500).json({ error: "Something went wrong" });
		console.log("error", error);
	}
});

app.listen(PORT, () => {
	console.log(`Server is running on http://localhost:${PORT}`);
});
