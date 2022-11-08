USE [ServerAnalysisDW];

-- CREATE TABLE
SELECT TOP (1000) [ID]
      ,[tHour]
      ,[tMin]
      ,[Time6]
      ,[Time6s]
      ,[Time4]
      ,[Time4s]
      ,[dtTime]
  FROM [ServerAnalysisDW].[dbo].[TimeTens]


  -- POPULATE TABLE
SET IDENTITY_INSERT [dbo].[TimeTens] ON ;

INSERT [dbo].[TimeTens] ([ID], [tHour], [tMin], [Time6], [Time6s], [Time4], [Time4s], [dtTime]) 
VALUES (1, 0, 0, N'000000', N'00:00:00', N'0000', N'00:00', CAST(N'1900-01-01T00:00:00.000' AS DateTime)),
(2, 0, 10, N'001000', N'00:10:00', N'0010', N'00:10', CAST(N'1900-01-01T00:10:00.000' AS DateTime)),
(3, 0, 20, N'002000', N'00:20:00', N'0020', N'00:20', CAST(N'1900-01-01T00:20:00.000' AS DateTime)),
(4, 0, 30, N'003000', N'00:30:00', N'0030', N'00:30', CAST(N'1900-01-01T00:30:00.000' AS DateTime)),
(5, 0, 40, N'004000', N'00:40:00', N'0040', N'00:40', CAST(N'1900-01-01T00:40:00.000' AS DateTime)),
(6, 0, 50, N'005000', N'00:50:00', N'0050', N'00:50', CAST(N'1900-01-01T00:50:00.000' AS DateTime)),
(7, 1, 0, N'010000', N'01:00:00', N'0100', N'01:00', CAST(N'1900-01-01T01:00:00.000' AS DateTime)),
 (8, 1, 10, N'011000', N'01:10:00', N'0110', N'01:10', CAST(N'1900-01-01T01:10:00.000' AS DateTime)),
 (9, 1, 20, N'012000', N'01:20:00', N'0120', N'01:20', CAST(N'1900-01-01T01:20:00.000' AS DateTime)),
 (10, 1, 30, N'013000', N'01:30:00', N'0130', N'01:30', CAST(N'1900-01-01T01:30:00.000' AS DateTime)),
 (11, 1, 40, N'014000', N'01:40:00', N'0140', N'01:40', CAST(N'1900-01-01T01:40:00.000' AS DateTime)),
 (12, 1, 50, N'015000', N'01:50:00', N'0150', N'01:50', CAST(N'1900-01-01T01:50:00.000' AS DateTime)),
 (13, 2, 0, N'020000', N'02:00:00', N'0200', N'02:00', CAST(N'1900-01-01T02:00:00.000' AS DateTime)),
 (14, 2, 10, N'021000', N'02:10:00', N'0210', N'02:10', CAST(N'1900-01-01T02:10:00.000' AS DateTime)),
 (15, 2, 20, N'022000', N'02:20:00', N'0220', N'02:20', CAST(N'1900-01-01T02:20:00.000' AS DateTime)),
 (16, 2, 30, N'023000', N'02:30:00', N'0230', N'02:30', CAST(N'1900-01-01T02:30:00.000' AS DateTime)),
 (17, 2, 40, N'024000', N'02:40:00', N'0240', N'02:40', CAST(N'1900-01-01T02:40:00.000' AS DateTime)),
 (18, 2, 50, N'025000', N'02:50:00', N'0250', N'02:50', CAST(N'1900-01-01T02:50:00.000' AS DateTime)),
 (19, 3, 0, N'030000', N'03:00:00', N'0300', N'03:00', CAST(N'1900-01-01T03:00:00.000' AS DateTime)),
 (20, 3, 10, N'031000', N'03:10:00', N'0310', N'03:10', CAST(N'1900-01-01T03:10:00.000' AS DateTime)),
 (21, 3, 20, N'032000', N'03:20:00', N'0320', N'03:20', CAST(N'1900-01-01T03:20:00.000' AS DateTime)),
 (22, 3, 30, N'033000', N'03:30:00', N'0330', N'03:30', CAST(N'1900-01-01T03:30:00.000' AS DateTime)),
 (23, 3, 40, N'034000', N'03:40:00', N'0340', N'03:40', CAST(N'1900-01-01T03:40:00.000' AS DateTime)),
 (24, 3, 50, N'035000', N'03:50:00', N'0350', N'03:50', CAST(N'1900-01-01T03:50:00.000' AS DateTime)),
 (25, 4, 0, N'040000', N'04:00:00', N'0400', N'04:00', CAST(N'1900-01-01T04:00:00.000' AS DateTime)),
 (26, 4, 10, N'041000', N'04:10:00', N'0410', N'04:10', CAST(N'1900-01-01T04:10:00.000' AS DateTime)),
 (27, 4, 20, N'042000', N'04:20:00', N'0420', N'04:20', CAST(N'1900-01-01T04:20:00.000' AS DateTime)),
 (28, 4, 30, N'043000', N'04:30:00', N'0430', N'04:30', CAST(N'1900-01-01T04:30:00.000' AS DateTime)),
 (29, 4, 40, N'044000', N'04:40:00', N'0440', N'04:40', CAST(N'1900-01-01T04:40:00.000' AS DateTime)),
 (30, 4, 50, N'045000', N'04:50:00', N'0450', N'04:50', CAST(N'1900-01-01T04:50:00.000' AS DateTime)),
 (31, 5, 0, N'050000', N'05:00:00', N'0500', N'05:00', CAST(N'1900-01-01T05:00:00.000' AS DateTime)),
 (32, 5, 10, N'051000', N'05:10:00', N'0510', N'05:10', CAST(N'1900-01-01T05:10:00.000' AS DateTime)),
 (33, 5, 20, N'052000', N'05:20:00', N'0520', N'05:20', CAST(N'1900-01-01T05:20:00.000' AS DateTime)),
 (34, 5, 30, N'053000', N'05:30:00', N'0530', N'05:30', CAST(N'1900-01-01T05:30:00.000' AS DateTime)),
 (35, 5, 40, N'054000', N'05:40:00', N'0540', N'05:40', CAST(N'1900-01-01T05:40:00.000' AS DateTime)),
 (36, 5, 50, N'055000', N'05:50:00', N'0550', N'05:50', CAST(N'1900-01-01T05:50:00.000' AS DateTime)),
 (37, 6, 0, N'060000', N'06:00:00', N'0600', N'06:00', CAST(N'1900-01-01T06:00:00.000' AS DateTime)),
 (38, 6, 10, N'061000', N'06:10:00', N'0610', N'06:10', CAST(N'1900-01-01T06:10:00.000' AS DateTime)),
 (39, 6, 20, N'062000', N'06:20:00', N'0620', N'06:20', CAST(N'1900-01-01T06:20:00.000' AS DateTime)),
 (40, 6, 30, N'063000', N'06:30:00', N'0630', N'06:30', CAST(N'1900-01-01T06:30:00.000' AS DateTime)),
 (41, 6, 40, N'064000', N'06:40:00', N'0640', N'06:40', CAST(N'1900-01-01T06:40:00.000' AS DateTime)),
 (42, 6, 50, N'065000', N'06:50:00', N'0650', N'06:50', CAST(N'1900-01-01T06:50:00.000' AS DateTime)),
 (43, 7, 0, N'070000', N'07:00:00', N'0700', N'07:00', CAST(N'1900-01-01T07:00:00.000' AS DateTime)),
 (44, 7, 10, N'071000', N'07:10:00', N'0710', N'07:10', CAST(N'1900-01-01T07:10:00.000' AS DateTime)),
 (45, 7, 20, N'072000', N'07:20:00', N'0720', N'07:20', CAST(N'1900-01-01T07:20:00.000' AS DateTime)),
 (46, 7, 30, N'073000', N'07:30:00', N'0730', N'07:30', CAST(N'1900-01-01T07:30:00.000' AS DateTime)),
 (47, 7, 40, N'074000', N'07:40:00', N'0740', N'07:40', CAST(N'1900-01-01T07:40:00.000' AS DateTime)),
 (48, 7, 50, N'075000', N'07:50:00', N'0750', N'07:50', CAST(N'1900-01-01T07:50:00.000' AS DateTime)),
 (49, 8, 0, N'080000', N'08:00:00', N'0800', N'08:00', CAST(N'1900-01-01T08:00:00.000' AS DateTime)),
 (50, 8, 10, N'081000', N'08:10:00', N'0810', N'08:10', CAST(N'1900-01-01T08:10:00.000' AS DateTime)),
 (51, 8, 20, N'082000', N'08:20:00', N'0820', N'08:20', CAST(N'1900-01-01T08:20:00.000' AS DateTime)),
 (52, 8, 30, N'083000', N'08:30:00', N'0830', N'08:30', CAST(N'1900-01-01T08:30:00.000' AS DateTime)),
 (53, 8, 40, N'084000', N'08:40:00', N'0840', N'08:40', CAST(N'1900-01-01T08:40:00.000' AS DateTime)),
 (54, 8, 50, N'085000', N'08:50:00', N'0850', N'08:50', CAST(N'1900-01-01T08:50:00.000' AS DateTime)),
 (55, 9, 0, N'090000', N'09:00:00', N'0900', N'09:00', CAST(N'1900-01-01T09:00:00.000' AS DateTime)),
 (56, 9, 10, N'091000', N'09:10:00', N'0910', N'09:10', CAST(N'1900-01-01T09:10:00.000' AS DateTime)),
 (57, 9, 20, N'092000', N'09:20:00', N'0920', N'09:20', CAST(N'1900-01-01T09:20:00.000' AS DateTime)),
 (58, 9, 30, N'093000', N'09:30:00', N'0930', N'09:30', CAST(N'1900-01-01T09:30:00.000' AS DateTime)),
 (59, 9, 40, N'094000', N'09:40:00', N'0940', N'09:40', CAST(N'1900-01-01T09:40:00.000' AS DateTime)),
 (60, 9, 50, N'095000', N'09:50:00', N'0950', N'09:50', CAST(N'1900-01-01T09:50:00.000' AS DateTime)),
 (61, 10, 0, N'100000', N'10:00:00', N'1000', N'10:00', CAST(N'1900-01-01T10:00:00.000' AS DateTime)),
 (62, 10, 10, N'101000', N'10:10:00', N'1010', N'10:10', CAST(N'1900-01-01T10:10:00.000' AS DateTime)),
 (63, 10, 20, N'102000', N'10:20:00', N'1020', N'10:20', CAST(N'1900-01-01T10:20:00.000' AS DateTime)),
 (64, 10, 30, N'103000', N'10:30:00', N'1030', N'10:30', CAST(N'1900-01-01T10:30:00.000' AS DateTime)),
 (65, 10, 40, N'104000', N'10:40:00', N'1040', N'10:40', CAST(N'1900-01-01T10:40:00.000' AS DateTime)),
 (66, 10, 50, N'105000', N'10:50:00', N'1050', N'10:50', CAST(N'1900-01-01T10:50:00.000' AS DateTime)),
 (67, 11, 0, N'110000', N'11:00:00', N'1100', N'11:00', CAST(N'1900-01-01T11:00:00.000' AS DateTime)),
 (68, 11, 10, N'111000', N'11:10:00', N'1110', N'11:10', CAST(N'1900-01-01T11:10:00.000' AS DateTime)),
 (69, 11, 20, N'112000', N'11:20:00', N'1120', N'11:20', CAST(N'1900-01-01T11:20:00.000' AS DateTime)),
 (70, 11, 30, N'113000', N'11:30:00', N'1130', N'11:30', CAST(N'1900-01-01T11:30:00.000' AS DateTime)),
 (71, 11, 40, N'114000', N'11:40:00', N'1140', N'11:40', CAST(N'1900-01-01T11:40:00.000' AS DateTime)),
 (72, 11, 50, N'115000', N'11:50:00', N'1150', N'11:50', CAST(N'1900-01-01T11:50:00.000' AS DateTime)),
 (73, 12, 0, N'120000', N'12:00:00', N'1200', N'12:00', CAST(N'1900-01-01T12:00:00.000' AS DateTime)),
 (74, 12, 10, N'121000', N'12:10:00', N'1210', N'12:10', CAST(N'1900-01-01T12:10:00.000' AS DateTime)),
 (75, 12, 20, N'122000', N'12:20:00', N'1220', N'12:20', CAST(N'1900-01-01T12:20:00.000' AS DateTime)),
 (76, 12, 30, N'123000', N'12:30:00', N'1230', N'12:30', CAST(N'1900-01-01T12:30:00.000' AS DateTime)),
 (77, 12, 40, N'124000', N'12:40:00', N'1240', N'12:40', CAST(N'1900-01-01T12:40:00.000' AS DateTime)),
 (78, 12, 50, N'125000', N'12:50:00', N'1250', N'12:50', CAST(N'1900-01-01T12:50:00.000' AS DateTime)),
 (79, 13, 0, N'130000', N'13:00:00', N'1300', N'13:00', CAST(N'1900-01-01T13:00:00.000' AS DateTime)),
 (80, 13, 10, N'131000', N'13:10:00', N'1310', N'13:10', CAST(N'1900-01-01T13:10:00.000' AS DateTime)),
 (81, 13, 20, N'132000', N'13:20:00', N'1320', N'13:20', CAST(N'1900-01-01T13:20:00.000' AS DateTime)),
 (82, 13, 30, N'133000', N'13:30:00', N'1330', N'13:30', CAST(N'1900-01-01T13:30:00.000' AS DateTime)),
 (83, 13, 40, N'134000', N'13:40:00', N'1340', N'13:40', CAST(N'1900-01-01T13:40:00.000' AS DateTime)),
 (84, 13, 50, N'135000', N'13:50:00', N'1350', N'13:50', CAST(N'1900-01-01T13:50:00.000' AS DateTime)),
 (85, 14, 0, N'140000', N'14:00:00', N'1400', N'14:00', CAST(N'1900-01-01T14:00:00.000' AS DateTime)),
 (86, 14, 10, N'141000', N'14:10:00', N'1410', N'14:10', CAST(N'1900-01-01T14:10:00.000' AS DateTime)),
 (87, 14, 20, N'142000', N'14:20:00', N'1420', N'14:20', CAST(N'1900-01-01T14:20:00.000' AS DateTime)),
 (88, 14, 30, N'143000', N'14:30:00', N'1430', N'14:30', CAST(N'1900-01-01T14:30:00.000' AS DateTime)),
 (89, 14, 40, N'144000', N'14:40:00', N'1440', N'14:40', CAST(N'1900-01-01T14:40:00.000' AS DateTime)),
 (90, 14, 50, N'145000', N'14:50:00', N'1450', N'14:50', CAST(N'1900-01-01T14:50:00.000' AS DateTime)),
 (91, 15, 0, N'150000', N'15:00:00', N'1500', N'15:00', CAST(N'1900-01-01T15:00:00.000' AS DateTime)),
 (92, 15, 10, N'151000', N'15:10:00', N'1510', N'15:10', CAST(N'1900-01-01T15:10:00.000' AS DateTime)),
 (93, 15, 20, N'152000', N'15:20:00', N'1520', N'15:20', CAST(N'1900-01-01T15:20:00.000' AS DateTime)),
 (94, 15, 30, N'153000', N'15:30:00', N'1530', N'15:30', CAST(N'1900-01-01T15:30:00.000' AS DateTime)),
 (95, 15, 40, N'154000', N'15:40:00', N'1540', N'15:40', CAST(N'1900-01-01T15:40:00.000' AS DateTime)),
 (96, 15, 50, N'155000', N'15:50:00', N'1550', N'15:50', CAST(N'1900-01-01T15:50:00.000' AS DateTime)),
 (97, 16, 0, N'160000', N'16:00:00', N'1600', N'16:00', CAST(N'1900-01-01T16:00:00.000' AS DateTime)),
 (98, 16, 10, N'161000', N'16:10:00', N'1610', N'16:10', CAST(N'1900-01-01T16:10:00.000' AS DateTime)),
 (99, 16, 20, N'162000', N'16:20:00', N'1620', N'16:20', CAST(N'1900-01-01T16:20:00.000' AS DateTime)),
 (100, 16, 30, N'163000', N'16:30:00', N'1630', N'16:30', CAST(N'1900-01-01T16:30:00.000' AS DateTime)),
 (101, 16, 40, N'164000', N'16:40:00', N'1640', N'16:40', CAST(N'1900-01-01T16:40:00.000' AS DateTime)),
 (102, 16, 50, N'165000', N'16:50:00', N'1650', N'16:50', CAST(N'1900-01-01T16:50:00.000' AS DateTime)),
 (103, 17, 0, N'170000', N'17:00:00', N'1700', N'17:00', CAST(N'1900-01-01T17:00:00.000' AS DateTime)),
 (104, 17, 10, N'171000', N'17:10:00', N'1710', N'17:10', CAST(N'1900-01-01T17:10:00.000' AS DateTime)),
 (105, 17, 20, N'172000', N'17:20:00', N'1720', N'17:20', CAST(N'1900-01-01T17:20:00.000' AS DateTime)),
 (106, 17, 30, N'173000', N'17:30:00', N'1730', N'17:30', CAST(N'1900-01-01T17:30:00.000' AS DateTime)),
 (107, 17, 40, N'174000', N'17:40:00', N'1740', N'17:40', CAST(N'1900-01-01T17:40:00.000' AS DateTime)),
 (108, 17, 50, N'175000', N'17:50:00', N'1750', N'17:50', CAST(N'1900-01-01T17:50:00.000' AS DateTime)),
 (109, 18, 0, N'180000', N'18:00:00', N'1800', N'18:00', CAST(N'1900-01-01T18:00:00.000' AS DateTime)),
 (110, 18, 10, N'181000', N'18:10:00', N'1810', N'18:10', CAST(N'1900-01-01T18:10:00.000' AS DateTime)),
 (111, 18, 20, N'182000', N'18:20:00', N'1820', N'18:20', CAST(N'1900-01-01T18:20:00.000' AS DateTime)),
 (112, 18, 30, N'183000', N'18:30:00', N'1830', N'18:30', CAST(N'1900-01-01T18:30:00.000' AS DateTime)),
 (113, 18, 40, N'184000', N'18:40:00', N'1840', N'18:40', CAST(N'1900-01-01T18:40:00.000' AS DateTime)),
 (114, 18, 50, N'185000', N'18:50:00', N'1850', N'18:50', CAST(N'1900-01-01T18:50:00.000' AS DateTime)),
 (115, 19, 0, N'190000', N'19:00:00', N'1900', N'19:00', CAST(N'1900-01-01T19:00:00.000' AS DateTime)),
 (116, 19, 10, N'191000', N'19:10:00', N'1910', N'19:10', CAST(N'1900-01-01T19:10:00.000' AS DateTime)),
 (117, 19, 20, N'192000', N'19:20:00', N'1920', N'19:20', CAST(N'1900-01-01T19:20:00.000' AS DateTime)),
 (118, 19, 30, N'193000', N'19:30:00', N'1930', N'19:30', CAST(N'1900-01-01T19:30:00.000' AS DateTime)),
 (119, 19, 40, N'194000', N'19:40:00', N'1940', N'19:40', CAST(N'1900-01-01T19:40:00.000' AS DateTime)),
 (120, 19, 50, N'195000', N'19:50:00', N'1950', N'19:50', CAST(N'1900-01-01T19:50:00.000' AS DateTime)),
 (121, 20, 0, N'200000', N'20:00:00', N'2000', N'20:00', CAST(N'1900-01-01T20:00:00.000' AS DateTime)),
 (122, 20, 10, N'201000', N'20:10:00', N'2010', N'20:10', CAST(N'1900-01-01T20:10:00.000' AS DateTime)),
 (123, 20, 20, N'202000', N'20:20:00', N'2020', N'20:20', CAST(N'1900-01-01T20:20:00.000' AS DateTime)),
 (124, 20, 30, N'203000', N'20:30:00', N'2030', N'20:30', CAST(N'1900-01-01T20:30:00.000' AS DateTime)),
 (125, 20, 40, N'204000', N'20:40:00', N'2040', N'20:40', CAST(N'1900-01-01T20:40:00.000' AS DateTime)),
 (126, 20, 50, N'205000', N'20:50:00', N'2050', N'20:50', CAST(N'1900-01-01T20:50:00.000' AS DateTime)),
 (127, 21, 0, N'210000', N'21:00:00', N'2100', N'21:00', CAST(N'1900-01-01T21:00:00.000' AS DateTime)),
 (128, 21, 10, N'211000', N'21:10:00', N'2110', N'21:10', CAST(N'1900-01-01T21:10:00.000' AS DateTime)),
 (129, 21, 20, N'212000', N'21:20:00', N'2120', N'21:20', CAST(N'1900-01-01T21:20:00.000' AS DateTime)),
 (130, 21, 30, N'213000', N'21:30:00', N'2130', N'21:30', CAST(N'1900-01-01T21:30:00.000' AS DateTime)),
 (131, 21, 40, N'214000', N'21:40:00', N'2140', N'21:40', CAST(N'1900-01-01T21:40:00.000' AS DateTime)),
 (132, 21, 50, N'215000', N'21:50:00', N'2150', N'21:50', CAST(N'1900-01-01T21:50:00.000' AS DateTime)),
 (133, 22, 0, N'220000', N'22:00:00', N'2200', N'22:00', CAST(N'1900-01-01T22:00:00.000' AS DateTime)),
 (134, 22, 10, N'221000', N'22:10:00', N'2210', N'22:10', CAST(N'1900-01-01T22:10:00.000' AS DateTime)),
 (135, 22, 20, N'222000', N'22:20:00', N'2220', N'22:20', CAST(N'1900-01-01T22:20:00.000' AS DateTime)),
 (136, 22, 30, N'223000', N'22:30:00', N'2230', N'22:30', CAST(N'1900-01-01T22:30:00.000' AS DateTime)),
 (137, 22, 40, N'224000', N'22:40:00', N'2240', N'22:40', CAST(N'1900-01-01T22:40:00.000' AS DateTime)),
 (138, 22, 50, N'225000', N'22:50:00', N'2250', N'22:50', CAST(N'1900-01-01T22:50:00.000' AS DateTime)),
 (139, 23, 0, N'230000', N'23:00:00', N'2300', N'23:00', CAST(N'1900-01-01T23:00:00.000' AS DateTime)),
 (140, 23, 10, N'231000', N'23:10:00', N'2310', N'23:10', CAST(N'1900-01-01T23:10:00.000' AS DateTime)),
 (141, 23, 20, N'232000', N'23:20:00', N'2320', N'23:20', CAST(N'1900-01-01T23:20:00.000' AS DateTime)),
 (142, 23, 30, N'233000', N'23:30:00', N'2330', N'23:30', CAST(N'1900-01-01T23:30:00.000' AS DateTime)),
 (143, 23, 40, N'234000', N'23:40:00', N'2340', N'23:40', CAST(N'1900-01-01T23:40:00.000' AS DateTime)),
 (144, 23, 50, N'235000', N'23:50:00', N'2350', N'23:50', CAST(N'1900-01-01T23:50:00.000' AS DateTime))

SET IDENTITY_INSERT [dbo].[TimeTens] OFF;


GO


USE [ServerAnalysisDW]
GO
/****** Object:  View [Analysis].[pcv_bi_overview_today]    Script Date: 11/8/2022 10:57:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE OR ALTER VIEW [Analysis].[pcv_bi_overview_today]
AS

	SELECT L.LocationID, L.ClusterID, L.ClusterName, 
			CONCAT(ClusterName,' (',
						(CASE L.LocationID	WHEN 101874 THEN 'CBG-US'
											WHEN 211098 THEN 'CBG-EU'
											WHEN 211874 THEN 'CBG-EU'
											WHEN 301035 THEN 'UPIC IMPL'
											WHEN 301166 THEN 'UPIC DEV'
											WHEN 301463 THEN 'UPIC PROD'
											ELSE 'Undefined' END)    ,')') AS ClusterFullName,
	
			t.Time4s, 
			MAX(cpu.iValResult) AS CpuPercent, 
			MAX(sig.SignalWaits) AS SignalWaits, 
			MAX(lat.DiscLatencyMs) AS DiscLatencyMs, 
			MAX(mem.MemoryInstPercentInUse) AS MemoryInstPercentInUse,
			MAX(du.DiskSpacePercentInUse) AS DiskSpacePercentInUse, 
			MAX(bat.BatchRequestsSec) as BatchRequestsSec, 
			MAX(ps.PageSplitSec) AS PageSplitSec, 
			MAX(fs.FullScansSec) AS FullScansSec, 
			MAX(comp.SqlCompilationsSec) AS SqlCompilationsSec, 
			MAX(rcomp.SqlReCompilationsSec) AS SqlReCompilationsSec
	FROM Analysis.PerfLocation L WITH(NOLOCK) CROSS JOIN  dbo.TimeTens t WITH(NOLOCK)
	LEFT JOIN [Analysis].[pcv_CpuUsagePercent_10] cpu ON L.LocationID = cpu.LocationID and L.ClusterID = cpu.ClusterID and cpu.DateKey = 20221101 and t.Time6 = cpu.Timekey
	LEFT JOIN [Analysis].[pcv_SignalWaits_10] sig ON L.LocationID = sig.LocationID and L.ClusterID = sig.ClusterID and sig.DateKey = 20221101 and t.Time6 = sig.Timekey
	LEFT JOIN  [Analysis].[pcv_IoDiskLatencyTotal_10] lat ON L.LocationID = lat.LocationID and L.ClusterID = lat.ClusterID and lat.DateKey = 20221101 and t.Time6 = lat.Timekey
	LEFT JOIN  [Analysis].[pcv_MemoryInstUsage_10] mem  ON L.LocationID = mem.LocationID and L.ClusterID = mem.ClusterID and mem.DateKey = 20221101 and t.Time6 = mem.Timekey
	LEFT JOIN [Analysis].[pcv_DiskUsage_10] du ON L.LocationID = du.LocationID and L.ClusterID = du.ClusterID and du.DateKey = 20221101 and t.Time6 = du.Timekey -- Only for overview chart uses 60 days
	LEFT JOIN  [Analysis].[pcv_BatchRequestsSec_10] bat ON L.LocationID = bat.LocationID and L.ClusterID = bat.ClusterID and bat.DateKey = 20221101 and t.Time6 = bat.Timekey
	LEFT JOIN [Analysis].[pcv_PageSpiltsSec_10] ps ON L.LocationID = ps.LocationID and L.ClusterID = ps.ClusterID and ps.DateKey = 20221101 and t.Time6 = ps.Timekey
	LEFT JOIN  [Analysis].[pcv_FullScansSec_10] fs ON L.LocationID = fs.LocationID and L.ClusterID = fs.ClusterID and fs.DateKey = 20221101 and t.Time6 = fs.Timekey
	LEFT JOIN [Analysis].[pcv_SqlCompilationsSec_10] comp  ON L.LocationID = comp.LocationID and L.ClusterID = comp.ClusterID and comp.DateKey = 20221101 and t.Time6 = comp.Timekey
	LEFT JOIN [Analysis].[pcv_SqlReCompilationsSec_10] rcomp  ON L.LocationID = rcomp.LocationID and L.ClusterID = rcomp.ClusterID and rcomp.DateKey = 20221101 and t.Time6 = rcomp.Timekey
	WHERE L.IsActive = 1 and L.ServerID = 1
	and  CONVERT(TIME, t.dtTime) <  CONVERT(TIME, getutcdate())
	GROUP BY L.LocationID, L.ClusterID,  L.ClusterName, t.Time4s;
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Bi_DatabaseProperties]    Script Date: 11/8/2022 10:57:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- =============================================
CREATE OR ALTER PROCEDURE [Analysis].[PerfCounter_Bi_DatabaseProperties]
AS
BEGIN

		DECLARE @id as TABLE (ID int identity(1,1), LocationID int, ClusterID int, ClusterName varchar(150))
		DECLARE @dB as TABLE (	ID int identity(1,1), 
								LocationID int, 
								ClusterID int, 
								LocationName varchar(250),
								ClusterName varchar(250),
								ClusterFullName varchar(250), 
								DatabaseName varchar(150), 
								MdfFileName varchar(150), 							
								MdfMBs varchar(24),
								LdfMBs varchar(24),
								IOpcnt varchar(8),
								Model varchar(12),  --  1 = FULL, 2 = BULK_LOGGED, 3 = SIMPLE
								SqlVersion varchar(8),  -- 70,80,90.100,110,20,130, 140, 150
								DbState varchar(20),  -- 0 = ONLINE, 1 = RESTORING, 2 = RECOVERING, 3 = RECOVERY_PENDING, 4 = SUSPECT, 5 = EMERGENC, 6 = OFFLINE, 7 = COPYING, 10 = OFFLINE_SECONDARY 
								LastBackup varchar(24),
								DailyGrowth int);
		DECLARE @iLoopP INT;
		DECLARE @cLocationID INT;
		DECLARE @cClusterID INT;
		DECLARE @cLocationName varchar(250); 
		DECLARE @cClusterName varchar(250); 
		DECLARE @cClusterFullName varchar(250); 

		INSERT INTO @Id (LocationID, ClusterID, ClusterName)
		SELECT LocationID, ClusterID, ClusterName
		FROM Analysis.PerfLocation 
		WHERE IsActive = 1 and ServerID = 1
		ORDER BY LocationID DESC, ClusterID DESC;

		SELECT @iLoopP = MAX(ID) FROM @id;

		WHILE @iLoopP > 0
		BEGIN

			SELECT	@cLocationID = LocationID, 
					@cClusterID = ClusterID,
					@cLocationName = (CASE LocationID	WHEN 101874 THEN 'CBG-US'
													WHEN 211098 THEN 'CBG-EU'
													WHEN 211874 THEN 'CBG-EU'
													WHEN 301035 THEN 'UPIC IMPL'
													WHEN 301166 THEN 'UPIC DEV'
													WHEN 301463 THEN 'UPIC PROD'
													ELSE 'Undefined' END),
					@cClusterName = ClusterName,
					@cClusterFullName = CONCAT(ClusterName,' (',
								(CASE LocationID	WHEN 101874 THEN 'CBG-US'
													WHEN 211098 THEN 'CBG-EU'
													WHEN 211874 THEN 'CBG-EU'
													WHEN 301035 THEN 'UPIC IMPL'
													WHEN 301166 THEN 'UPIC DEV'
													WHEN 301463 THEN 'UPIC PROD'
													ELSE 'Undefined' END)    ,')') 
			FROM @id
			WHERE ID = @iLoopP;

			INSERT INTO @dB (DatabaseName,MdfFileName,MdfMBs,LdfMBs,IOpcnt,Model,SqlVersion,DbState,LastBackup,DailyGrowth)
			EXEC [Analysis].[PerfCounter_Rpt_Database_Properties]  @cLocationID, @cClusterID;

			UPDATE @dB
			SET LocationID = @cLocationID, 
				ClusterID = @cClusterID,
				LocationName = @cLocationName,
				ClusterName = @cClusterName,
				ClusterFullName = @cClusterFullName
			WHERE LocationID IS NULL;

			SELECT	@cLocationID = 0, 
					@cClusterID = 0,  
					@cLocationName = '',
					@cClusterName = '',
					@cClusterFullName = '', 
					@iLoopP = @iLoopP-1
		END;

		SELECT * FROM @dB ORDER BY LocationID, ClusterID;

END
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Bi_ServerProperties]    Script Date: 11/8/2022 10:57:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- =============================================
CREATE OR ALTER PROCEDURE [Analysis].[PerfCounter_Bi_ServerProperties]
AS
BEGIN


		DECLARE @id as TABLE (ID int identity(1,1), LocationID int, ClusterID int, ClusterName varchar(150))
		DECLARE @d as TABLE (	ID int identity(1,1), 
								LocationID int, 
								ClusterID int, 
								LocationName varchar(250),
								ClusterName varchar(250),
								ClusterFullName varchar(250), 
								Property varchar(250), 
								DataVal varchar(250))
		DECLARE @iLoopP INT;
		DECLARE @cLocationID INT;
		DECLARE @cClusterID INT;
		DECLARE @cLocationName varchar(250); 
		DECLARE @cClusterName varchar(250); 
		DECLARE @cClusterFullName varchar(250); 

		INSERT INTO @Id (LocationID, ClusterID, ClusterName)
		SELECT LocationID, ClusterID, ClusterName
		FROM Analysis.PerfLocation 
		WHERE IsActive = 1 and ServerID = 1
		ORDER BY LocationID DESC, ClusterID DESC;

		SELECT @iLoopP = MAX(ID) FROM @id;

		WHILE @iLoopP > 0
		BEGIN

			SELECT	@cLocationID = LocationID, 
					@cClusterID = ClusterID,
					@cLocationName = (CASE LocationID	WHEN 101874 THEN 'CBG-US'
													WHEN 211098 THEN 'CBG-EU'
													WHEN 211874 THEN 'CBG-EU'
													WHEN 301035 THEN 'UPIC IMPL'
													WHEN 301166 THEN 'UPIC DEV'
													WHEN 301463 THEN 'UPIC PROD'
													ELSE 'Undefined' END),
					@cClusterName = ClusterName,
					@cClusterFullName = CONCAT(ClusterName,' (',
								(CASE LocationID	WHEN 101874 THEN 'CBG-US'
													WHEN 211098 THEN 'CBG-EU'
													WHEN 211874 THEN 'CBG-EU'
													WHEN 301035 THEN 'UPIC IMPL'
													WHEN 301166 THEN 'UPIC DEV'
													WHEN 301463 THEN 'UPIC PROD'
													ELSE 'Undefined' END)    ,')') 
			FROM @id
			WHERE ID = @iLoopP;

			INSERT INTO @d (Property, DataVal)
			EXEC [Analysis].[PerfCounter_Rpt_Server_Properties]  @cLocationID, @cClusterID;

			UPDATE @d
			SET LocationID = @cLocationID, 
				ClusterID = @cClusterID,
				LocationName = @cLocationName,
				ClusterName = @cClusterName,
				ClusterFullName = @cClusterFullName
			WHERE LocationID IS NULL;

			SELECT	@cLocationID = 0, 
					@cClusterID = 0,  
					@cLocationName = '',
					@cClusterName = '',
					@cClusterFullName = '', 
					@iLoopP = @iLoopP-1
		END;

		SELECT * FROM @d ORDER BY LocationID, ClusterID;

END
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Overview]    Script Date: 11/8/2022 10:57:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- =============================================
CREATE OR ALTER PROCEDURE [Analysis].[PerfCounter_Rpt_Overview]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		DECLARE @results as TABLE (	LocationID INT, 
								ClusterID INT, 
								ClusterName VARCHAR(250), 
								ClusterFullName VARCHAR(500),
								ClusterStatus VARCHAR(8),
								CpuPercent INT,
								SignalWaits INT,
								DiscLatencyMs INT,
								MemoryInstPercentInUse INT,
								DiskSpacePercentInUse INT,
								RunDuration VARCHAR(36),
								DiscWatchList VARCHAR(50))

	INSERT INTO @results (LocationID, CLusterID, ClusterName, ClusterFullName,
	ClusterStatus, CpuPercent, SignalWaits, DiscLatencyMs, MemoryInstPercentInUse, DiskSpacePercentInUse, RunDuration, DiscWatchList)
	SELECT	L.LocationID, 
			L.ClusterID, 
			L.ClusterName, 
			CONCAT(L.ClusterName,' (',
						(CASE L.LocationID	WHEN 101874 THEN 'CBG-US'
											WHEN 211098 THEN 'CBG-EU'
											WHEN 211874 THEN 'CBG-EU'
											WHEN 301035 THEN 'UPIC IMPL'
											WHEN 301166 THEN 'UPIC DEV'
											WHEN 301463 THEN 'UPIC PROD'
						ELSE 'Undefined' END)    			,')') 	AS ClusterFullName,
			'DOWN',0,0,0,0,0,'',''
	FROM	Analysis.PerfLocation as L WITH(NOLOCK)
	WHERE L.IsActive = 1
	GROUP BY L.LocationID, L.ClusterID, L.ClusterName;

	-- CPU
	UPDATE r
	SET CpuPercent = ISNULL(cpu.iValResult,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_CpuUsagePercent_Latest AS cpu on cpu.locationID = r.LocationID and cpu.ClusterID = r.ClusterID;

	-- Signnal Waits
	UPDATE r
	SET SignalWaits = ISNULL(sig.SignalWaits,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_SignalWaits_Latest sig  on sig.locationID = r.LocationID and sig.ClusterID = r.ClusterID;

	-- DiscLatency Ms
	UPDATE r
	SET DiscLatencyMs =  ISNULL(dlat.DiscLatencyMs,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_IoDiskLatencyTotal_Latest dlat on dlat.locationID = r.LocationID and dlat.ClusterID = r.ClusterID;
	
	--MemoryInstPercentInUse
	UPDATE r
	SET MemoryInstPercentInUse = ISNULL(mem.MemoryInstPercentInUse,0) 
	FROM @results AS r
	INNER JOIN Analysis.pcv_MemoryInstUsage_Latest mem on mem.locationID = r.LocationID and mem.ClusterID = r.ClusterID;

	--DiskSpacePercentInUse
	UPDATE r
	SET DiskSpacePercentInUse = ISNULL(dsk.DiskSpacePercentInUse,0) 
	FROM @results AS r
	INNER JOIN Analysis.pcv_DiskUsage_Latest dsk on dsk.locationID = r.LocationID and dsk.ClusterID = r.ClusterID;

	--RunDuration
	UPDATE r
	SET RunDuration = ISNULL(rst.RunDuration,'') 
	FROM @results AS r
	INNER JOIN Analysis.pcv_InstanceLastRestart rst on rst.locationID = r.LocationID and rst.ClusterID = r.ClusterID;

	--DiscWatchList
	UPDATE r
	SET DiscWatchList = ISNULL(duw.DiscWatchList,'')
	FROM @results AS r
	INNER JOIN Analysis.pcv_DiskUsage_WatchList duw on duw.locationID = r.LocationID and duw.ClusterID = r.ClusterID

	-- Cluster Status
	UPDATE @results
	SET ClusterStatus = 'UP'
	WHERE (LEN(RunDuration) > 1 AND CpuPercent > 0) or ((SignalWaits + DiscLatencyMs + MemoryInstPercentInUse) > 0);

	SELECT		LocationID, 
				ClusterID, 
				ClusterName, 
				ClusterFullName,
				ClusterStatus,
				CpuPercent,
				SignalWaits,
				DiscLatencyMs,
				MemoryInstPercentInUse,
				DiskSpacePercentInUse,
				RunDuration,
				DiscWatchList
	FROM		@results
	ORDER BY	(CASE LocationID	WHEN 301035 THEN 999901			-- Place IMPL ande DEV last in list
									WHEN 301166 THEN 999902
									ELSE LocationID END),	
				ClusterID, 
				ClusterName;


END


GO



