const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Image = sequelize.define("Image", {
	path: {
		type: DataTypes.STRING,
		allowNull: false,
	},
});

sequelize.sync();

module.exports = Image;
