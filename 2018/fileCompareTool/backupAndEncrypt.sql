/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50505
Source Host           : localhost:3306
Source Database       : DATABASE

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2018-07-03 00:22:11
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `TABLE_NAME`
-- ----------------------------
DROP TABLE IF EXISTS `TABLE_NAME`;
CREATE TABLE `test` (
  `execution_date` int(11) NOT NULL,
  `backup_time` int(11) NOT NULL,
  `file_modification_time` int(11) NOT NULL,
  `filesize_in_bytes` int(11) NOT NULL,
  `md5` text COLLATE utf8_unicode_ci NOT NULL,
  `path` text COLLATE utf8_unicode_ci NOT NULL,
  `filename` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of TABLE_NAME
-- ----------------------------
/* INSERT INTO `TABLE_NAME` VALUES ('20180702', '1478379160', '1478379160', '123', '86969dde5ce945bed5919529ab33088f', 'test/','makedumpfile.conf.sample'); */

